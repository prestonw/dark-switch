//go:build darwin

package main

import "time"

type Watcher struct {
	interval time.Duration
	onChange func(appName string)
	lastApp  string
	stopCh   chan struct{}
}

func NewWatcher(interval time.Duration, onChange func(string)) *Watcher {
	return &Watcher{
		interval: interval,
		onChange: onChange,
		stopCh:   make(chan struct{}),
	}
}

func (w *Watcher) Start() {
	go func() {
		ticker := time.NewTicker(w.interval)
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				app := getFrontmostApp()
				if app != w.lastApp {
					w.lastApp = app
					w.onChange(app)
				}
			case <-w.stopCh:
				return
			}
		}
	}()
}

func (w *Watcher) Stop() {
	close(w.stopCh)
}
