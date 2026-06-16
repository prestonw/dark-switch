//go:build darwin

package main

import (
	"fmt"
	"sort"
	"sync"
	"time"

	"fyne.io/systray"
)

const maxRuleSlots = 20
const pollInterval = 300 * time.Millisecond

type state struct {
	mu            sync.Mutex
	cfg           *Config
	effectiveMode AppMode
	frontApp      string
	ruleApps      [maxRuleSlots]string // slot index → app name, guarded by mu
}

var s state

// menu items — package-level so goroutines can reference them
var (
	mStatusLine  *systray.MenuItem
	mToggle      *systray.MenuItem
	mFrontInfo   *systray.MenuItem
	mSetLight    *systray.MenuItem
	mSetDark     *systray.MenuItem
	mClearRule   *systray.MenuItem
	mRulesHeader *systray.MenuItem
	mRuleItems   [maxRuleSlots]*systray.MenuItem
)

func main() {
	systray.Run(onReady, nil)
}

func onReady() {
	s.cfg = loadConfig()
	s.effectiveMode = getCurrentMode()
	s.frontApp = getFrontmostApp()

	systray.SetTitle("◐")
	systray.SetTooltip("Dark Switch")

	// Status + toggle
	mStatusLine = systray.AddMenuItem("", "Click to toggle the default mode")
	mToggle = systray.AddMenuItem("Toggle Default Mode", "")
	systray.AddSeparator()

	// Frontmost app controls
	mFrontInfo = systray.AddMenuItem("", "")
	mFrontInfo.Disable()
	mSetLight = systray.AddMenuItem("  Set Light for this app", "")
	mSetDark = systray.AddMenuItem("  Set Dark for this app", "")
	mClearRule = systray.AddMenuItem("  Clear rule for this app", "")
	systray.AddSeparator()

	// Rules list
	mRulesHeader = systray.AddMenuItem("", "")
	mRulesHeader.Disable()
	for i := range mRuleItems {
		mRuleItems[i] = systray.AddMenuItem("", "Click to remove this rule")
		mRuleItems[i].Hide()
	}

	systray.AddSeparator()
	mQuit := systray.AddMenuItem("Quit Dark Switch", "")

	updateMenu()

	// Start frontmost app watcher
	w := NewWatcher(pollInterval, func(app string) {
		s.mu.Lock()
		s.frontApp = app
		mode := effectiveModeFor(app, s.cfg)
		s.effectiveMode = mode
		s.mu.Unlock()
		setMode(mode)
		updateMenu()
	})
	w.Start()

	// Main menu click handler
	go func() {
		for {
			select {
			case <-mStatusLine.ClickedCh:
				toggleDefault()
			case <-mToggle.ClickedCh:
				toggleDefault()
			case <-mSetLight.ClickedCh:
				setRuleForFront(ModeLight)
			case <-mSetDark.ClickedCh:
				setRuleForFront(ModeDark)
			case <-mClearRule.ClickedCh:
				clearRuleForFront()
			case <-mQuit.ClickedCh:
				systray.Quit()
				return
			}
		}
	}()

	// Rule slot click handlers
	for i := range mRuleItems {
		i := i
		go func() {
			for range mRuleItems[i].ClickedCh {
				removeRule(i)
			}
		}()
	}
}

func effectiveModeFor(app string, cfg *Config) AppMode {
	if app != "" {
		if rule, ok := cfg.AppRules[app]; ok {
			return rule
		}
	}
	return cfg.DefaultMode
}

func updateMenu() {
	s.mu.Lock()
	cfg := s.cfg
	frontApp := s.frontApp
	effectiveMode := s.effectiveMode
	s.mu.Unlock()

	// Menu bar title reflects active mode
	if effectiveMode == ModeDark {
		systray.SetTitle("●")
	} else {
		systray.SetTitle("○")
	}

	// Status line
	rule, hasRule := cfg.AppRules[frontApp]
	if hasRule {
		mStatusLine.SetTitle(fmt.Sprintf("Default: %s  |  Active: %s (override)", cfg.DefaultMode, effectiveMode))
	} else {
		mStatusLine.SetTitle(fmt.Sprintf("Default: %s  |  Active: %s", cfg.DefaultMode, effectiveMode))
	}

	// Frontmost app section
	if frontApp == "" {
		mFrontInfo.SetTitle("Front: (unknown)")
		mSetLight.Hide()
		mSetDark.Hide()
		mClearRule.Hide()
	} else {
		if hasRule {
			mFrontInfo.SetTitle(fmt.Sprintf("Front: %s  →  %s", frontApp, rule))
			mClearRule.Show()
		} else {
			mFrontInfo.SetTitle(fmt.Sprintf("Front: %s  (no rule)", frontApp))
			mClearRule.Hide()
		}
		mSetLight.Show()
		mSetDark.Show()
	}

	// Rules section
	appNames := make([]string, 0, len(cfg.AppRules))
	for name := range cfg.AppRules {
		appNames = append(appNames, name)
	}
	sort.Strings(appNames)

	if len(appNames) == 0 {
		mRulesHeader.SetTitle("Rules: none")
	} else {
		mRulesHeader.SetTitle(fmt.Sprintf("Rules (%d)  —  click to remove", len(appNames)))
	}

	s.mu.Lock()
	for i := range mRuleItems {
		if i < len(appNames) {
			name := appNames[i]
			s.ruleApps[i] = name
			mRuleItems[i].SetTitle(fmt.Sprintf("  %s  →  %s", name, cfg.AppRules[name]))
			mRuleItems[i].Show()
		} else {
			s.ruleApps[i] = ""
			mRuleItems[i].Hide()
		}
	}
	s.mu.Unlock()
}

func toggleDefault() {
	s.mu.Lock()
	if s.cfg.DefaultMode == ModeDark {
		s.cfg.DefaultMode = ModeLight
	} else {
		s.cfg.DefaultMode = ModeDark
	}
	mode := effectiveModeFor(s.frontApp, s.cfg)
	s.effectiveMode = mode
	cfg := s.cfg
	s.mu.Unlock()

	setMode(mode)
	saveConfig(cfg)
	updateMenu()
}

func setRuleForFront(mode AppMode) {
	s.mu.Lock()
	app := s.frontApp
	if app != "" {
		s.cfg.AppRules[app] = mode
	}
	s.effectiveMode = mode
	cfg := s.cfg
	s.mu.Unlock()

	setMode(mode)
	saveConfig(cfg)
	updateMenu()
}

func clearRuleForFront() {
	s.mu.Lock()
	app := s.frontApp
	delete(s.cfg.AppRules, app)
	mode := effectiveModeFor(app, s.cfg)
	s.effectiveMode = mode
	cfg := s.cfg
	s.mu.Unlock()

	setMode(mode)
	saveConfig(cfg)
	updateMenu()
}

func removeRule(slot int) {
	s.mu.Lock()
	app := s.ruleApps[slot]
	if app != "" {
		delete(s.cfg.AppRules, app)
	}
	mode := effectiveModeFor(s.frontApp, s.cfg)
	s.effectiveMode = mode
	cfg := s.cfg
	s.mu.Unlock()

	setMode(mode)
	saveConfig(cfg)
	updateMenu()
}
