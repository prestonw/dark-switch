# dark-switch

A macOS menu bar utility that automatically switches between light and dark mode based on whichever app is in the foreground. Set per-app rules so certain apps always open in light or dark mode, while everything else follows your default.

## Download

Grab the latest `DarkSwitch.zip` from the [Releases](https://github.com/prestonw/dark-switch/releases) page, unzip it, and drag `DarkSwitch.app` to your `/Applications` folder.

## Requirements

- macOS 13 (Ventura) or later
- Xcode Command Line Tools (for building from source only)

## Install from source

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

Rules are stored in `~/Library/Application Support/DarkSwitch/config.json`.

On first launch, macOS will ask permission for Dark Switch to control System Events. This is required to switch the system appearance.

## How it works

Dark Switch listens for `NSWorkspace.didActivateApplicationNotification`. When you switch apps it checks for a per-app rule and applies the matching appearance. If no rule exists it falls back to your configured default.

## Building from source

```bash
make build   # compile only
make bundle  # produce ./DarkSwitch.app
make zip     # produce DarkSwitch.zip for distribution
make run     # build and run directly
```

## License

MIT. See [LICENSE](LICENSE).
