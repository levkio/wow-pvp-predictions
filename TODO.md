# TODO: tests before we build

This list covers what we must test before the parser and the Twitch client are final. Details of each confirmed log format go to [docs/log-format.md](docs/log-format.md). Open Twitch questions are in [docs/open-questions.md](docs/open-questions.md).

## Before each test match

1. Make sure that the PvP Predictions Companion addon is on (`/pvppc status`). As an alternative, AutoCombatLogger with "Yes" for Arenas and Battlegrounds and a delay of about 30 seconds also works. Do not use both at the same time.
2. Make sure that Advanced Combat Logging is on (Options, Game, System, Network).
3. After the match, tell Claude the mode and the result. For Solo Shuffle, also give the result of each round. If you do not remember it, that is no problem.

## Companion addon tests

- [ ] Install the addon: copy `addon/PvPPredictionsCompanion` to `World of Warcraft\_retail_\Interface\AddOns\`, turn off AutoCombatLogger, and type `/reload`.
- [ ] Enter an arena. The chat shows "Combat logging started." A new `WoWCombatLog` file appears.
- [ ] Leave the arena. After 30 seconds, the chat shows "Combat logging stopped."
- [ ] Type `/pvppc status` in Solo Shuffle, in a battleground and in Blitz. Write down the zone type. The addon logs only for "arena" and "pvp".
- [ ] Type `/reload` during a match. After the match, the addon still stops the log.
- [ ] Play a rated match with RatedTracker on. Make sure that the log has the full match.

## In-game tests (phase 0)

| Done | Mode | Result | What we learn |
| --- | --- | --- | --- |
| [x] | Arena skirmish 3v3 | Win | Entry, gates, end and winner lines. Confirmed on 2026-10-31. |
| [ ] | Arena skirmish or rated arena | Loss | The winner mapping also works for a loss. |
| [ ] | Rated 2v2 | Any | `matchType` value and rating fields in `ARENA_MATCH_END`. |
| [ ] | Rated 3v3 | Any | Same as 2v2. Also: RatedTracker and AutoCombatLogger both control the log. Make sure that no lines are lost. |
| [x] | Solo Shuffle | 3-3 | Round start, round end and round winner. Confirmed on 2026-10-31. |
| [ ] | Solo Shuffle | Round ends by time limit | What the log shows when nobody dies. You cannot plan it, so we test it when it occurs. |
| [x] | Random battleground | Loss | Entry and gates confirmed. No end line and no winner in the combat log. Tested on 2026-10-31. |
| [ ] | Random battleground with chat log on | Any | End message and winner in `WoWChatLog.txt`. |
| [ ] | Epic battleground | Any | Same as random battleground. |
| [ ] | Battleground Blitz | Any | Same as random battleground. Does AutoCombatLogger start the log? |
| [ ] | Rated battleground | Any | Same as random battleground. Lower priority, because it needs a premade group. |
| [ ] | Any arena | You leave early | What the log shows. The prediction must be canceled. |
| [ ] | Any match | Disconnect or `/reload` during the match | What the log shows. Does the log continue? |
| [ ] | Any arena | Draw (timer runs out) | Value of `winningTeam` for a draw. You cannot plan a draw, so we test it when it occurs. |
| [ ] | Two matches in a row without leaving the queue system | Any | The tool must not mix up the two matches. |

## Timing tests

- [ ] Measure the write delay of the log file. Claude watches the file while you fight a training dummy and compares the line times with the file write times.
- [x] Solo Shuffle: measure the break between rounds. Result: 35 to 36 seconds. Decide if this is enough time for viewers to bet.
- [ ] Battlegrounds: measure the time between entry and start.

## Twitch tests (phase 3, needs a Twitch app)

- [ ] Register a Twitch application with client type "Public".
- [ ] Log in with the Device Code Grant Flow.
- [ ] Create a test prediction and cancel it at once. Find the maximum title length and the limits of `prediction_window`.
- [ ] Lock a prediction early with status `LOCKED`.
- [ ] Resolve a prediction. Find out which input End Prediction takes: query parameters or a JSON body.
- [ ] Receive `channel.prediction.*` events over EventSub WebSocket.
- [ ] Restart the tool while a prediction is open. The tool must find the open prediction again.
- [ ] Refresh the access token after 4 hours. Make sure that the new refresh token is stored.

## Replay tests (no game needed)

- [ ] Build a replay mode that plays a saved log at real speed into the parser.
- [ ] Add an anonymized fixture for every mode in the table above.
- [ ] Run the state machine against every fixture in CI.

## Release on CurseForge (phase 5)

- [ ] Ask CurseForge support if a WoW project can contain a Windows desktop program, or if the project can name a download on GitHub. Their policy says: "External download links for files are not allowed."
- [ ] Read the CurseForge Mod Author Terms: https://legal.overwolf.com/docs/curseforge/mod-authors-terms
- [x] Decide if we publish a small companion addon on CurseForge. Decision on 2026-10-31: yes.
- [ ] Set up packaging for CurseForge (for example the BigWigs packager in GitHub Actions).
