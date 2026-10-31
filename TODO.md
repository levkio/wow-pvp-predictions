# TODO: tests before we build

This list covers what we must test before the parser and the Twitch client are final. Details of each confirmed log format go to [docs/log-format.md](docs/log-format.md). Open Twitch questions are in [docs/open-questions.md](docs/open-questions.md).

## Before each test match

1. Make sure that AutoCombatLogger has "Yes" for Arenas and Battlegrounds, with a delay of about 30 seconds.
2. Make sure that Advanced Combat Logging is on (Options, Game, System, Network).
3. After the match, tell Claude the mode and the result. For Solo Shuffle, also give the result of each round. If you do not remember it, that is no problem.

## In-game tests (phase 0)

| Done | Mode | Result | What we learn |
| --- | --- | --- | --- |
| [x] | Arena skirmish 3v3 | Win | Entry, gates, end and winner lines. Confirmed on 2026-10-31. |
| [ ] | Arena skirmish or rated arena | Loss | The winner mapping also works for a loss. |
| [ ] | Rated 2v2 | Any | `matchType` value and rating fields in `ARENA_MATCH_END`. |
| [ ] | Rated 3v3 | Any | Same as 2v2. Also: RatedTracker and AutoCombatLogger both control the log. Make sure that no lines are lost. |
| [ ] | Solo Shuffle | Any | Lines for the start, the end and the winner of each of the 6 rounds. Time between rounds. |
| [ ] | Random battleground | Any | Lines for entry, start and end, and the winner. The wiki documents none. |
| [ ] | Epic battleground | Any | Same as random battleground. |
| [ ] | Battleground Blitz | Any | Same as random battleground. Does AutoCombatLogger start the log? |
| [ ] | Rated battleground | Any | Same as random battleground. Lower priority, because it needs a premade group. |
| [ ] | Any arena | You leave early | What the log shows. The prediction must be canceled. |
| [ ] | Any match | Disconnect or `/reload` during the match | What the log shows. Does the log continue? |
| [ ] | Any arena | Draw (timer runs out) | Value of `winningTeam` for a draw. You cannot plan a draw, so we test it when it occurs. |
| [ ] | Two matches in a row without leaving the queue system | Any | The tool must not mix up the two matches. |

## Timing tests

- [ ] Measure the write delay of the log file. Claude watches the file while you fight a training dummy and compares the line times with the file write times.
- [ ] Solo Shuffle: measure the break between rounds. If it is too short, viewers cannot bet. Then we decide again how Solo Shuffle works.
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
- [ ] Decide if we publish a small companion addon on CurseForge. It can turn on combat logging in PvP and replace AutoCombatLogger.
