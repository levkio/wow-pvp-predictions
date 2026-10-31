# Combat log format (Midnight)

Status: arena skirmish and rated Solo Shuffle confirmed. Battlegrounds: the combat log has no end line and no winner. Rated 2v2 and 3v3 are still open.

## Confirmed: arena skirmish (3v3, win)

Recorded on 2026-10-31 with AutoCombatLogger. The log reports `BUILD_VERSION,12.1.5`. The anonymized excerpt is in [test/fixtures/skirmish-3v3-win.txt](../test/fixtures/skirmish-3v3-win.txt).

```
18:57:00.9751  COMBAT_LOG_VERSION,22,ADVANCED_LOG_ENABLED,1,BUILD_VERSION,12.1.5,PROJECT_ID,1
18:57:00.9751  ZONE_CHANGE,980,"Tol'viron Arena",0
18:57:56.3361  ARENA_MATCH_START,980,42,Skirmish,0
18:57:56.3361  COMBATANT_INFO,Player-0000-00000001,1,...
18:59:21.0761  ARENA_MATCH_END,1,84,0,0
18:59:25.4541  ZONE_CHANGE,0,"The Cape of Stranglethorn",0
```

What each line means for the prediction:

| Line | Moment | Prediction action |
| --- | --- | --- |
| `ZONE_CHANGE` to an arena zone | You enter the arena | Open |
| `ARENA_MATCH_START` | The gates open, 56 seconds after entry | Lock |
| `ARENA_MATCH_END` | The match ends | Resolve |

How the tool finds your own team:

1. Find your own character. Its unit flags have the "mine" bit (`0x1`), for example `0x511`.
2. Find the `COMBATANT_INFO` line with your GUID. The second field is your team (0 or 1).
3. Compare it with the first field of `ARENA_MATCH_END` (`winningTeam`). If they are equal, you won.

The last field of `ARENA_MATCH_START` was `0`, but your team was `1`. That field is not your team ID, so the tool does not use it. Confirmed by the player: the match was a win, and two enemies died.

AutoCombatLogger restarted the log on entry. A new `COMBAT_LOG_VERSION` line appears at the same time as the `ZONE_CHANGE`, so no match line is lost.

## Confirmed: rated Solo Shuffle (3-3)

Recorded on 2026-10-31. The anonymized excerpt is in [test/fixtures/solo-shuffle-3-3.txt](../test/fixtures/solo-shuffle-3-3.txt). The RatedTracker addon showed the result L, L, W, W, L, W. The rules below give the same six results and the same round lengths from the log alone.

```
21:28:42.5791  ZONE_CHANGE,1505,"Nagrand Arena",0
21:29:26.1881  ARENA_MATCH_START,1505,42,Rated Solo Shuffle,0      round 1 starts
21:29:26.1881  COMBATANT_INFO,...                                   6 lines, teams for this round
21:29:43.9971  UNIT_DIED,...,"Player3-Realm-EU",0x10548,0x80000000,1   feign death, ignore
21:32:27.2311  UNIT_DIED,...,"Player2-Realm-EU",0x10512,0x80000020,0   real death, round 1 ends
21:33:02.7321  ARENA_MATCH_START,1505,42,Rated Solo Shuffle,0      round 2 starts
...
21:44:51.2051  ARENA_MATCH_END,-1,84,2831,2805                     match ends
```

Rules for Solo Shuffle:

1. Each round starts with its own `ARENA_MATCH_START` line, with `matchType` `Rated Solo Shuffle`. There is no line for the end of a round.
2. After each `ARENA_MATCH_START`, there are 6 new `COMBATANT_INFO` lines. The teams change every round, so read your team again each round.
3. The first `UNIT_DIED` of a player with last field `0` ends the round. If the dead player is on your team, you lost the round. Otherwise you won it.
4. A `UNIT_DIED` with last field `1` is not a real death (for example Feign Death). Ignore it.
5. There is only one `ARENA_MATCH_END`, after round 6. Its `winningTeam` is `-1`, and its duration is the length of round 6 only. Do not use it for the round result.

Timing:

| Interval | Measured |
| --- | --- |
| Entry to round 1 start | 44 seconds |
| End of a round to start of the next round | 35 to 36 seconds |

So viewers have about 35 seconds to bet on rounds 2 to 6, minus the stream delay.

Still open for Solo Shuffle: a round that ends by the time limit without a death, and a player who leaves during the match.

## Tested: random battleground (Seething Shore, loss)

Recorded on 2026-10-31 with the companion addon. `/pvppc status` showed zone type `pvp`, and the addon started the log.

```
22:17:06.8801  ZONE_CHANGE,1803,"Zul'Aman",0
22:17:09.2551  ZONE_CHANGE,1803,"Seething Shore",0
22:17:07.5161  SPELL_AURA_APPLIED,<self>,...,44521,"Preparation",...
22:19:14.5161  SPELL_AURA_REMOVED,<self>,...,44521,"Preparation",...
22:27:25.3811  ZONE_CHANGE,0,"Zul'Aman",0          you leave the battleground
22:27:54.8601  (last line, the addon stops the log 30 seconds after you leave)
```

The first analysis read the file at 22:27:36 and saw lines only up to 22:27:17. The game wrote the rest to disk at 22:29:56. The results below come from the complete file.

Results:

- Entry: `ZONE_CHANGE` to the battleground zone. The first `ZONE_CHANGE` can name the wrong zone, so the tool uses the zone type from the addon or the last `ZONE_CHANGE`.
- Gates open: your own `Preparation` aura (spell 44521) is removed, 2 minutes and 5 seconds after entry. This is a usable lock signal.
- Leave: `ZONE_CHANGE` back to the open world.
- End and winner: no line. There is no `ARENA_MATCH_END`, no `COMBATANT_INFO`, no battleground event between the gates and the leave. The combat log alone cannot resolve a battleground prediction.

## Chat log file (WoWChatLog.txt)

The folder also had a `WoWChatLog.txt` from an earlier session. The game writes it after `/chatlog` or `LoggingChat(true)`. It contains system messages during a PvP match, for example:

```
10/31 18:57:26.501  Thirty seconds until the Arena battle begins!
10/31 18:57:56.334  The Arena battle has begun!
10/31 18:59:22.090  You have been awarded 90 Honor.
```

So the Midnight limit on reading chat applies to addons, not to this file. Not tested yet: the battleground end message and whether it names the winner in a way the tool can map to your side. The file also contains whispers and guild chat. The tool must read only system messages and must never store or send the rest.

## Reading the file while the game writes it

The game keeps the log file open. A reader must open it with shared read and write access. A normal exclusive open fails with "The process cannot access the file because it is being used by another process."

The file size in a directory listing is not reliable while the file is open. During the battleground, the listing showed 0 bytes for minutes. The tool must read the size from its own open file handle. Measured with an open file handle during the battleground:

| Clock time of the check | Newest line in the file |
| --- | --- |
| 22:17:39 | none (file empty, entry was at 22:17:06) |
| 22:28:07 | 22:27:17.9 |
| 22:32:12 | 22:27:54.9 (written at 22:29:56) |

The game writes the log in large blocks, not line by line. A line can reach the disk more than 30 seconds after it happened. This is a risk for live predictions: the lock and the result can arrive late. In Solo Shuffle, the break between rounds is only 35 seconds. We must measure the delay exactly before we build the state machine.

## How to record a test log

1. Open Options, System, Network, and turn on Advanced Combat Logging.
2. Turn on combat logging with one of these two methods:
   - Install the companion addon from `addon/PvPPredictionsCompanion`. It starts the log when you enter an arena or a battleground.
   - Install the addon [AutoCombatLogger](https://www.curseforge.com/wow/addons/autocombatlogger) and set logging for arenas and battlegrounds to "Yes". The addon starts the log when you enter an arena or a battleground.
   - Before each match, type `/combatlog` in chat. The game confirms that combat logging is on.
3. Write down the clock time when you enter the instance, when the gates open, and when the match ends. Write down the result. For Solo Shuffle, write down the time and the result of each round.
4. If you use `/combatlog`, type it again after the match to stop the log.
5. The files are in `World of Warcraft\_retail_\Logs\`.

Record one match per mode: 2v2 or 3v3, Solo Shuffle, skirmish, random battleground, epic battleground, rated battleground or Blitz. If possible, also record one match with a leave or a disconnect.

## Questions this file must answer

1. Does patch 12.1.7 write the file, and how long is the delay before a line appears?
2. Does `ARENA_MATCH_START` appear on entry or when the gates open? Which line marks the gates opening?
3. How does `winningTeam` in `ARENA_MATCH_END` map to your own team?
4. Which lines mark the start, the end and the winner of each Solo Shuffle round?
5. Which lines mark the start, the end and the winner of a battleground?
6. What does the log show for a disconnect, a leave or a draw?
7. If you use AutoCombatLogger: does the log start early enough to contain the first match line? The addon waits 1 to 4 seconds after you enter the zone. Does it start the log in Solo Shuffle and in Blitz?

## Known from older documentation (not confirmed for Midnight)

warcraft.wiki.gg documents these lines:

```
ARENA_MATCH_START,instanceID,unk,matchType,teamId
ARENA_MATCH_END,winningTeam,matchDuration,newRatingTeam1,newRatingTeam2
```
