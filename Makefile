APP_NAME  = dark-switch
BUNDLE    = DarkSwitch.app
BINARY    = $(BUNDLE)/Contents/MacOS/$(APP_NAME)
PLIST     = $(BUNDLE)/Contents/Info.plist
LAUNCHD   = $(HOME)/Library/LaunchAgents/com.prestonw.dark-switch.plist

.PHONY: build bundle run install uninstall clean

build:
	go build -o $(APP_NAME) .

bundle: build
	mkdir -p $(BUNDLE)/Contents/MacOS
	cp $(APP_NAME) $(BINARY)
	cp Info.plist $(PLIST)

run: build
	./$(APP_NAME)

install: bundle
	cp -r $(BUNDLE) /Applications/$(BUNDLE)
	@echo "Installed → /Applications/$(BUNDLE)"
	@echo "Run: open /Applications/$(BUNDLE)"

# Install as a login item via LaunchAgent (auto-start on login)
launchd: bundle
	cp -r $(BUNDLE) /Applications/$(BUNDLE)
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n\
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n\
<plist version="1.0"><dict>\n\
  <key>Label</key><string>com.prestonw.dark-switch</string>\n\
  <key>ProgramArguments</key><array><string>/Applications/DarkSwitch.app/Contents/MacOS/dark-switch</string></array>\n\
  <key>RunAtLoad</key><true/>\n\
  <key>KeepAlive</key><false/>\n\
</dict></plist>\n' > $(LAUNCHD)
	launchctl load $(LAUNCHD)
	@echo "LaunchAgent loaded — dark-switch will start at login"

uninstall:
	-launchctl unload $(LAUNCHD) 2>/dev/null
	-rm -f $(LAUNCHD)
	-rm -rf /Applications/$(BUNDLE)
	@echo "Uninstalled"

clean:
	rm -rf $(APP_NAME) $(BUNDLE)
