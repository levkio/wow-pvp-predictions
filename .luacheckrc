std = "lua51"
max_line_length = 120
exclude_files = { "node_modules/**" }
globals = {
    "PvPPredictionsCompanionDB",
    "SLASH_PVPPREDICTIONSCOMPANION1",
    "SlashCmdList",
}
read_globals = {
    "C_CVar", "C_Timer", "CreateFrame", "GetCVar", "SetCVar",
    "InCombatLockdown", "IsInInstance", "LoggingCombat",
    "C_PvP", "GetBattlefieldStatus", "GetBattlefieldWinner", "GetBattlefieldArenaFaction",
    "UnitFactionGroup", "issecretvalue", "date",
}
