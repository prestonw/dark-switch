//go:build darwin

package main

import (
	"fmt"
	"os/exec"
	"strings"
)

func getCurrentMode() AppMode {
	out, err := exec.Command("osascript", "-e",
		`tell app "System Events" to tell appearance preferences to return dark mode`).Output()
	if err != nil {
		return ModeDark
	}
	if strings.TrimSpace(string(out)) == "true" {
		return ModeDark
	}
	return ModeLight
}

func setMode(mode AppMode) {
	val := "false"
	if mode == ModeDark {
		val = "true"
	}
	cmd := fmt.Sprintf(`tell app "System Events" to tell appearance preferences to set dark mode to %s`, val)
	_ = exec.Command("osascript", "-e", cmd).Run()
}

func getFrontmostApp() string {
	out, err := exec.Command("osascript", "-e",
		`tell application "System Events" to get name of first application process whose frontmost is true`).Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}
