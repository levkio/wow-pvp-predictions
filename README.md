# wow-pvp-predictions

This tool starts a Twitch Prediction when you enter a World of Warcraft arena or battleground. Viewers bet channel points on a win or a loss. The tool locks the prediction when the match starts and pays out when the match ends. In Solo Shuffle, each of the six rounds gets its own prediction. An OBS browser source shows the live bets, the match info and the result.

Status: early development. The tool does not work yet. See [docs/roadmap.md](docs/roadmap.md).

## How it works

The tool reads the combat log file that World of Warcraft writes to disk (`WoWCombatLog.txt`). It does not use an addon and it does not read the screen. Since patch 12.0.0 (Midnight), addons cannot read combat events or chat during a PvP match. The log file is outside of the game, so these limits do not apply to it.

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
