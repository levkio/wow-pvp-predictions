-- PvP Predictions Companion
-- Turns on combat logging when the player enters an arena or a battleground,
-- and turns it off again after a delay when the player leaves.
-- The desktop app reads Logs\WoWCombatLog*.txt. This addon sends no data.

local ADDON_NAME, ns = ...

local DEFAULTS = {
    enabled = true,
    arena = true,
    battleground = true,
    stopDelay = 30, -- seconds after leaving, so that the last match lines get written
    verbose = true,
    startedByUs = false, -- kept across /reload so that we still stop our own log
}

local MAX_RETRIES = 10
local RETRY_SECONDS = 2

local db
local stopToken = 0
local retries = 0

local function Print(message)
    print("|cff4fc3f7PvP Predictions:|r " .. message)
end

ns.Print = Print
ns.GetDB = function()
    return db
end

-- LoggingCombat is rate limited to 5 calls per 10 seconds, shared by all addons.
-- When the limit is hit, it returns nil. Keep the number of calls small.
local function QueryLogging()
    local ok, state = pcall(LoggingCombat)
    if not ok then
        return nil
    end
    return state
end

local function SetLogging(on)
    local ok = pcall(LoggingCombat, on)
    return ok
end

local function GetCVarValue(name)
    if C_CVar and C_CVar.GetCVar then
        return C_CVar.GetCVar(name)
    end
    return GetCVar(name)
end

local function SetCVarValue(name, value)
    if C_CVar and C_CVar.SetCVar then
        return pcall(C_CVar.SetCVar, name, value)
    end
    return pcall(SetCVar, name, value)
end

local function EnsureAdvancedLogging()
    if GetCVarValue("advancedCombatLogging") == "1" then
        return
    end
    if InCombatLockdown() then
        return
    end
    SetCVarValue("advancedCombatLogging", "1")
    if GetCVarValue("advancedCombatLogging") == "1" then
        Print("Advanced Combat Logging was off. It is on now.")
    else
        Print("Advanced Combat Logging is off. Turn it on in Options, System, Network.")
    end
end

-- Returns "arena" or "pvp" when logging must run in the current zone, else nil.
local function WantedInstanceType()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return nil
    end
    if instanceType == "arena" and db.arena then
        return instanceType
    end
    if instanceType == "pvp" and db.battleground then
        return instanceType
    end
    return nil
end

local Update

local function ScheduleRetry()
    retries = retries + 1
    if retries > MAX_RETRIES then
        Print("Could not turn on combat logging. Type /combatlog to start it yourself.")
        return
    end
    C_Timer.After(RETRY_SECONDS, Update)
end

local function StartLogging()
    local state = QueryLogging()
    if state == nil then
        ScheduleRetry()
        return
    end
    retries = 0
    if state then
        -- Logging is already on (the player or another addon started it). Do not take ownership.
        return
    end
    if SetLogging(true) then
        db.startedByUs = true
        if db.verbose then
            Print("Combat logging started.")
        end
    else
        ScheduleRetry()
    end
end

local function ScheduleStop()
    stopToken = stopToken + 1
    local token = stopToken
    C_Timer.After(db.stopDelay, function()
        if token ~= stopToken or not db.startedByUs or WantedInstanceType() then
            return
        end
        if SetLogging(false) then
            db.startedByUs = false
            if db.verbose then
                Print("Combat logging stopped.")
            end
        end
    end)
end

Update = function()
    if not db or not db.enabled then
        return
    end
    if WantedInstanceType() then
        stopToken = stopToken + 1 -- cancel a pending stop
        EnsureAdvancedLogging()
        if not db.startedByUs then
            StartLogging()
        end
    elseif db.startedByUs then
        ScheduleStop()
    end
end

local function PrintStatus()
    local inInstance, instanceType = IsInInstance()
    local logging = QueryLogging()
    Print(("enabled=%s arena=%s battleground=%s delay=%ds"):format(
        tostring(db.enabled), tostring(db.arena), tostring(db.battleground), db.stopDelay))
    Print(("zone type=%s (in instance=%s) logging=%s started by addon=%s advanced=%s"):format(
        tostring(instanceType), tostring(inInstance),
        logging == nil and "unknown (rate limit)" or tostring(logging),
        tostring(db.startedByUs), tostring(GetCVarValue("advancedCombatLogging"))))
end

local function HandleSlash(input)
    local command, argument = (input or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    if command == "on" or command == "off" then
        db.enabled = command == "on"
        Print("Addon " .. (db.enabled and "enabled." or "disabled."))
        Update()
    elseif command == "arena" or command == "bg" then
        local key = command == "arena" and "arena" or "battleground"
        db[key] = not db[key]
        Print(key .. " logging " .. (db[key] and "on." or "off."))
        Update()
    elseif command == "delay" and tonumber(argument) then
        db.stopDelay = math.max(0, math.min(120, math.floor(tonumber(argument))))
        Print("Stop delay set to " .. db.stopDelay .. " seconds.")
    elseif command == "verbose" then
        db.verbose = not db.verbose
        Print("Chat messages " .. (db.verbose and "on." or "off."))
    elseif command == "probe" then
        ns.ToggleProbe()
    elseif command == "status" or command == "" then
        PrintStatus()
    else
        Print("Commands: /pvppc status | on | off | arena | bg | delay <0-120> | verbose | probe")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then
            return
        end
        PvPPredictionsCompanionDB = PvPPredictionsCompanionDB or {}
        db = PvPPredictionsCompanionDB
        for key, value in pairs(DEFAULTS) do
            if db[key] == nil then
                db[key] = value
            end
        end
        self:UnregisterEvent("ADDON_LOADED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        SLASH_PVPPREDICTIONSCOMPANION1 = "/pvppc"
        SlashCmdList.PVPPREDICTIONSCOMPANION = HandleSlash
        ns.InitProbe()
    else
        Update()
    end
end)
