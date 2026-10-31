# Roadmap

## Phase 0: In-game check (blocks phase 2)

You play one match per mode with combat logging on. We keep the logs as test data and write [log-format.md](log-format.md). If battlegrounds or Solo Shuffle rounds do not show in the log, we stop and decide again.

## Phase 1: Repository and project skeleton

TypeScript, ESLint, Vitest, GitHub Actions, README, i18n (German and English). Done.

## Phase 2: Log parser and state machine

Follow the log file, read only the lines that phase 0 confirms, and run one state machine per mode. Tests use the real log excerpts.

## Phase 3: Twitch

Device Code Grant Flow with a public client. Create the prediction on entry, lock it when the gates open, resolve or cancel it at the end. Find an open prediction again after a restart.

## Phase 4: Overlay and dashboard

OBS browser source and a setup wizard. We agree on a design before we build it.

## Phase 5: Packaging and release

Windows installer or single executable, setup documentation, GitHub Releases.
