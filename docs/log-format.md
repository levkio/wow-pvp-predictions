# Combat log format (Midnight)

Status: not filled in. This file gets real example lines from phase 0.

## How to record a test log

1. Open Options, System, Network, and turn on Advanced Combat Logging.
2. Before each match, type `/combatlog` in chat. The game confirms that combat logging is on.
3. Write down the clock time when you enter the instance, when the gates open, and when the match ends. Write down the result. For Solo Shuffle, write down the time and the result of each round.
4. After the match, type `/combatlog` again to stop the log.
5. The files are in `World of Warcraft\_retail_\Logs\`.

Record one match per mode: 2v2 or 3v3, Solo Shuffle, skirmish, random battleground, epic battleground, rated battleground or Blitz. If possible, also record one match with a leave or a disconnect.

## Questions this file must answer

1. Does patch 12.1.7 write the file, and how long is the delay before a line appears?
2. Does `ARENA_MATCH_START` appear on entry or when the gates open? Which line marks the gates opening?
3. How does `winningTeam` in `ARENA_MATCH_END` map to your own team?
4. Which lines mark the start, the end and the winner of each Solo Shuffle round?
5. Which lines mark the start, the end and the winner of a battleground?
6. What does the log show for a disconnect, a leave or a draw?

## Known from older documentation (not confirmed for Midnight)

warcraft.wiki.gg documents these lines:

```
ARENA_MATCH_START,instanceID,unk,matchType,teamId
ARENA_MATCH_END,winningTeam,matchDuration,newRatingTeam1,newRatingTeam2
```
