//go:build darwin

package main

import (
	"encoding/json"
	"os"
	"path/filepath"
)

type AppMode string

const (
	ModeDark  AppMode = "dark"
	ModeLight AppMode = "light"
)

type Config struct {
	DefaultMode AppMode            `json:"defaultMode"`
	AppRules    map[string]AppMode `json:"appRules"`
}

func configPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".config", "dark-switch", "config.json")
}

func loadConfig() *Config {
	cfg := &Config{
		DefaultMode: ModeDark,
		AppRules:    make(map[string]AppMode),
	}
	data, err := os.ReadFile(configPath())
	if err != nil {
		return cfg
	}
	if err := json.Unmarshal(data, cfg); err != nil {
		return cfg
	}
	if cfg.AppRules == nil {
		cfg.AppRules = make(map[string]AppMode)
	}
	return cfg
}

func saveConfig(cfg *Config) {
	path := configPath()
	_ = os.MkdirAll(filepath.Dir(path), 0755)
	data, err := json.MarshalIndent(cfg, "", "  ")
	if err != nil {
		return
	}
	_ = os.WriteFile(path, data, 0644)
}
