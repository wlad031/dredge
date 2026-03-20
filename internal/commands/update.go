package commands

import (
	"context"
	"fmt"
	"runtime"

	"github.com/creativeprojects/go-selfupdate"
)

const updateDevSentinel = "dev"

func HandleUpdate(currentVersion, repo string) error {
	if currentVersion == updateDevSentinel {
		fmt.Println("Development build — skipping update")
		return nil
	}

	fmt.Printf("Current version: %s\n", currentVersion)
	fmt.Println("Checking for updates...")

	latest, found, err := selfupdate.DetectLatest(context.Background(), selfupdate.ParseSlug(repo))
	if err != nil {
		return fmt.Errorf("failed to check for updates: %w", err)
	}
	if !found {
		return fmt.Errorf("no release found for %s/%s", runtime.GOOS, runtime.GOARCH)
	}

	if latest.LessOrEqual(currentVersion) {
		fmt.Println("Already up to date")
		return nil
	}

	fmt.Printf("Updating to %s...\n", latest.Version())

	exe, err := selfupdate.ExecutablePath()
	if err != nil {
		return fmt.Errorf("could not locate executable path: %w", err)
	}

	if err := selfupdate.UpdateTo(context.Background(), latest.AssetURL, latest.AssetName, exe); err != nil {
		return fmt.Errorf("update failed: %w", err)
	}

	fmt.Printf("Updated to %s — restart dredge to use the new version\n", latest.Version())
	return nil
}
