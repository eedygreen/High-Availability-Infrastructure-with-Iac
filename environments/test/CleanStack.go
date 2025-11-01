package test

import (
	"os/exec"
	"path/filepath"
	"testing"
)

func CleanStack(t *testing.T, StackDir string) error {
	t.Logf("Cleaning Terragrunt Stack Directory in: %s", StackDir)

	// Check if .terragrunt-stack directory exists before cleaning
	stackPath := filepath.Join(StackDir, ".terragrunt-stack")
	t.Logf("Checking for stack directory at: %s", stackPath)

	cmd := exec.Command("terragrunt", "stack", "clean", "--working-dir", StackDir)
	cmd.Dir = StackDir

	output, err := cmd.CombinedOutput()
	t.Logf("Terragrunt clean output: %s", string(output))

	if err != nil {
		t.Logf("Error during cleaning: %v", err)
		return err
	}

	// Verify if .terragrunt-stack directory was actually removed
	if _, err := exec.Command("ls", "-la", stackPath).CombinedOutput(); err == nil {
		t.Logf("WARNING: .terragrunt-stack directory still exists after cleanup!")
	} else {
		t.Logf("SUCCESS: .terragrunt-stack directory was removed!")
	}

	t.Logf("Cache cleaned Successfully!")
	return nil
}
