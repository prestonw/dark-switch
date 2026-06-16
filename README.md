# dark-switch

A macOS menu bar utility that automatically switches between light and dark mode based on whichever app is in the foreground. Set per-app rules so certain apps always open in light or dark mode, while everything else follows your default.

## Requirements

- macOS (Sonoma or later recommended)
- Go 1.22 or later

## Install

```bash
git clone https://github.com/prestonw/dark-switch.git
cd dark-switch
make install
open /Applications/DarkSwitch.app
```

To start automatically at login:

```bash
make launchd
```

## Uninstall

```bash
make uninstall
```

This removes the app from `/Applications` and unloads the LaunchAgent if present.

## Usage

Click the menu bar icon to:

- Toggle your default mode between light and dark
- Set a rule for the current foreground app
- Clear a rule for the current foreground app
- View and remove all active rules

Rules are stored at `~/.config/dark-switch/config.json`.

## How it works

dark-switch polls the frontmost application every 300ms. When it detects a change, it checks for a per-app rule and applies the matching appearance. If no rule exists, it falls back to your configured default.

## Building from source

```bash
make build   # produces ./dark-switch binary
make bundle  # produces ./DarkSwitch.app
make run     # build and run directly
```

## License

MIT. See [LICENSE](LICENSE).
