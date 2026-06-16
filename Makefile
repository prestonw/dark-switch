APP_NAME = DarkSwitch
BUNDLE   = $(APP_NAME).app
LAUNCHD  = $(HOME)/Library/LaunchAgents/com.prestonw.dark-switch.plist

.PHONY: build bundle run install launchd uninstall clean

build:
	swift build -c release

bundle: build
	mkdir -p $(BUNDLE)/Contents/MacOS
	cp .build/release/$(APP_NAME) $(BUNDLE)/Contents/MacOS/$(APP_NAME)
	cp Info.plist $(BUNDLE)/Contents/Info.plist

run: build
	.build/release/$(APP_NAME)

install: bundle
	cp -r $(BUNDLE) /Applications/$(BUNDLE)
	@echo "Installed → /Applications/$(BUNDLE)"
	@echo "Run: open /Applications/$(BUNDLE)"

launchd: bundle
	cp -r $(BUNDLE) /Applications/$(BUNDLE)
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n\
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n\
<plist version="1.0"><dict>\n\
  <key>Label</key><string>com.prestonw.dark-switch</string>\n\
  <key>ProgramArguments</key><array><string>/Applications/DarkSwitch.app/Contents/MacOS/DarkSwitch</string></array>\n\
  <key>RunAtLoad</key><true/>\n\
  <key>KeepAlive</key><false/>\n\
</dict></plist>\n' > $(LAUNCHD)
	launchctl load $(LAUNCHD)
	@echo "LaunchAgent loaded — DarkSwitch will start at login"

uninstall:
	-launchctl unload $(LAUNCHD) 2>/dev/null
	-rm -f $(LAUNCHD)
	-rm -rf /Applications/$(BUNDLE)
	@echo "Uninstalled"

clean:
	rm -rf .build $(BUNDLE)
