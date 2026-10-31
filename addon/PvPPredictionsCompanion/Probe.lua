-- Probe mode: records what the addon can see about PvP matches in Midnight.
-- It is off by default. Turn it on with /pvppc probe.
-- Each entry goes to the chat and to PvPPredictionsCompanionDB.probeLog.
-- The game writes SavedVariables to disk only on /reload or logout.

local _, ns = ...

local MAX_ENTRIES = 300

local EVENTS = {
    "UPDATE_BATTLEFIELD_STATUS",
    "PVP_MATCH_ACTIVE",
    "PVP_MATCH_STATE_CHANGED",
    "PVP_MATCH_COMPLETE",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
}

local probeFrame = CreateFrame("Frame")

-- Returns a printable form of a value, or "<secret>" for a secret value.
local function Show(value)
    if issecretvalue and issecretvalue(value) then
        return "<secret>"
    end
    return tostring(value)
end

-- Calls a function in protected mode and returns its first values as text.
local function Try(func, ...)
    if type(func) ~= "function" then
        return "n/a"
    end
    local results = { pcall(func, ...) }
    if not results[1] then
        return "error"
    end
    local parts = {}
    for index = 2, math.min(#results, 6) do
        parts[#parts + 1] = Show(results[index])
    end
    return table.concat(parts, "/")
end

local function MatchState()
    return Try(C_PvP and C_PvP.GetActiveMatchState)
end

local function Record(text)
    local db = ns.GetDB()
    local entry = date("%H:%M:%S") .. " " .. text
    db.probeLog = db.probeLog or {}
    table.insert(db.probeLog, entry)
    while #db.probeLog > MAX_ENTRIES do
        table.remove(db.probeLog, 1)
    end
    ns.Print("probe " .. entry)
end

local function OnEvent(_, event, ...)
    local inInstance, instanceType = IsInInstance()
    local zone = ("zone=%s/%s state=%s"):format(Show(inInstance), Show(instanceType), MatchState())
    if event == "UPDATE_BATTLEFIELD_STATUS" then
        local index = ...
        Record(("%s index=%s status=%s %s"):format(event, Show(index), Try(GetBattlefieldStatus, index), zone))
    elseif event == "PVP_MATCH_COMPLETE" then
        local winner, duration = ...
        Record(("%s winner=%s duration=%s %s"):format(event, Show(winner), Show(duration), zone))
        Record(("  GetBattlefieldWinner=%s ArenaFaction=%s PlayerFaction=%s SoloShuffle=%s Rated=%s"):format(
            Try(GetBattlefieldWinner), Try(GetBattlefieldArenaFaction), Try(UnitFactionGroup, "player"),
            Try(C_PvP and C_PvP.IsSoloShuffle), Try(C_PvP and C_PvP.IsRatedMap)))
    else
        Record(("%s args=%s %s"):format(event, Show(select("#", ...) > 0 and (...) or nil), zone))
    end
end

local function SetProbe(on)
    for _, event in ipairs(EVENTS) do
        if on then
            if not pcall(probeFrame.RegisterEvent, probeFrame, event) then
                ns.Print("probe: event not available: " .. event)
            end
        else
            probeFrame:UnregisterEvent(event)
        end
    end
    probeFrame:SetScript("OnEvent", on and OnEvent or nil)
end

function ns.ToggleProbe()
    local db = ns.GetDB()
    db.probe = not db.probe
    SetProbe(db.probe)
    ns.Print("Probe mode " .. (db.probe and "on. Type /reload after the match to save the log." or "off."))
end

function ns.InitProbe()
    if ns.GetDB().probe then
        SetProbe(true)
    end
end
