package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
	"github.com/stretchr/testify/assert"
)

func TestVPC(t *testing.T) {
	t.Parallel()

	terragruntDir := "../us-west-1/"

	unitDir := filepath.Join(terragruntDir, "vpc")

	expected := map[string]string{
		"env":                 "dev",
		"region":              "us-west-1",
		"cidr":                "192.168.0.0/16",
		"public_subnets":      "192.168.1.0/24",
		"private_subnets":     "192.168.2.0/24",
		"database_subnets":    "192.168.3.0/24",
		"elasticache_subnets": "192.168.4.0/24",
	}

	t.Log("terragrunt stack clean running...")
	err := CleanStack(t, terragruntDir)
	if err != nil {
		t.Logf("Warning! Cache cleaning failed: %v", err)
	}

	t.Log("terragrunt plan running...")
	terragruntPlanOptions := &terragrunt.Options{
		TerragruntBinary: "terragrunt",
		TerragruntDir:    unitDir,
		TerragruntArgs:   []string{"plan"},
	}

	terragrunt.TgStackRunE(t, terragruntPlanOptions)

	defer func() {
		DestroyOptions := &terragrunt.Options{
			TerragruntBinary: "terragrunt",
			TerragruntDir:    unitDir,
			TerragruntArgs:   []string{"destroy"},
		}

		terragrunt.TgStackRun(t, DestroyOptions)
	}()

	t.Log("terragrunt apply running...")
	terragruntApplyOptions := &terragrunt.Options{
		TerragruntBinary: "terragrunt",
		TerragruntDir:    unitDir,
		TerragruntArgs:   []string{"apply"},
	}

	terragrunt.TgStackRunE(t, terragruntApplyOptions)

	OutPutOtions := &terragrunt.Options{
		TerragruntBinary: "terragrunt",
		TerragruntDir:    unitDir,
	}
	vpc_name := terragrunt.TgOutput(t, OutPutOtions, "env")
	assert.Equal(t, expected["env"], vpc_name)
}
