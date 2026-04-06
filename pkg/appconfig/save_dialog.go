package appconfig

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

func ChooseSavePath(defaultPath string, title string) (string, error) {
	switch runtime.GOOS {
	case "darwin":
		return chooseSavePathMac(defaultPath, title)
	case "windows":
		return chooseSavePathWindows(defaultPath, title)
	default:
		return defaultPath, nil
	}
}

func chooseSavePathMac(defaultPath string, title string) (string, error) {
	defaultDir := filepath.Dir(defaultPath)
	defaultName := filepath.Base(defaultPath)

	script := fmt.Sprintf(
		`set chosenFile to choose file name with prompt "%s" default location POSIX file "%s" default name "%s"
POSIX path of chosenFile`,
		escapeAppleScript(title),
		escapeAppleScript(defaultDir),
		escapeAppleScript(defaultName),
	)

	out, err := exec.Command("osascript", "-e", script).Output()
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(string(out)), nil
}

func chooseSavePathWindows(defaultPath string, title string) (string, error) {
	defaultName := filepath.Base(defaultPath)
	initialDir := filepath.Dir(defaultPath)
	extension := strings.TrimPrefix(filepath.Ext(defaultPath), ".")

	script := fmt.Sprintf(
		`Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.SaveFileDialog
$dialog.Title = '%s'
$dialog.FileName = '%s'
$dialog.InitialDirectory = '%s'
$dialog.DefaultExt = '%s'
$dialog.AddExtension = $true
if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $dialog.FileName }`,
		escapePowerShell(title),
		escapePowerShell(defaultName),
		escapePowerShell(initialDir),
		escapePowerShell(extension),
	)

	out, err := exec.Command("powershell", "-NoProfile", "-Command", script).Output()
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(string(out)), nil
}

func escapeAppleScript(value string) string {
	return strings.ReplaceAll(value, `"`, `\"`)
}

func escapePowerShell(value string) string {
	return strings.ReplaceAll(value, `'`, `''`)
}
