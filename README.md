# wow-pvp-predictions

This tool starts a Twitch Prediction when you enter a World of Warcraft arena or battleground. Viewers bet channel points on a win or a loss. The tool locks the prediction when the match starts and pays out when the match ends. In Solo Shuffle, each of the six rounds gets its own prediction. An OBS browser source shows the live bets, the match info and the result.

Status: early development. The tool does not work yet. See [docs/roadmap.md](docs/roadmap.md).

## How it works

The tool has two parts:

- A desktop app. It reads the combat log file that World of Warcraft writes to disk (`WoWCombatLog.txt`), and it controls the Twitch Prediction and the overlay.
- A small companion addon, [PvP Predictions Companion](addon/PvPPredictionsCompanion). It turns on combat logging when you enter an arena or a battleground. It sends no data.

The app does not read the screen. Since patch 12.0.0 (Midnight), addons cannot read combat events or chat during a PvP match, and they cannot send data out of the game. The log file is outside of the game, so these limits do not apply to it.

## Companion addon commands

```
/pvppc status        show the addon state and the zone type
/pvppc on | off      turn the addon on or off
/pvppc arena | bg    turn logging for arenas or battlegrounds on or off
/pvppc delay 30      seconds of logging after you leave the match
/pvppc verbose       turn the chat messages on or off
```

## Requirements

- Windows with World of Warcraft retail (Midnight).
- A Twitch channel with Affiliate or Partner status. Twitch Predictions are not available to other channels.
- Node.js 22 or later (for development).

## Supported modes

Rated 2v2 and 3v3, Solo Shuffle, arena skirmish, random and epic battlegrounds, rated battlegrounds and Battleground Blitz. You can turn off each mode in the configuration.

## Development

```
npm install
npm test
npm run lint
npm run typecheck
```

## Disclaimer

You use this tool at your own risk. Read the Blizzard terms of use and the Twitch terms of service before you use it on your channel. This project has no connection to Blizzard Entertainment or Twitch.

## License

MIT. See [LICENSE](LICENSE).
