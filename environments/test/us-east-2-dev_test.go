package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
	"github.com/stretchr/testify/assert"
)

func TestUsEast2Cluster(t *testing.T) {

	terragruntDir := "../us-east-2/cluster/"

	testCases := []struct {
		unitName string
		expected map[string]string
	}{

		{
			unitName: "dev",
			expected: map[string]string{
				"cluster_name":    "test-cluster-dev-1",
				"cluster_version": "1.21.14",
				"listen_address":  "0.0.0.0:8080",
				"environment":     "dev",
				"ingress_ready":   "true",
				"cluster_context": "us-east-2-dev",
			},
		},
		{

			unitName: "prod",
			expected: map[string]string{
				"cluster_name":    "test-cluster-prod-1",
				"cluster_version": "1.21.12",
				"listen_address":  "0.0.0.0:8080",
				"environment":     "prod",
				"ingress_ready":   "true",
				"cluster_context": "us-east-2-prod",
			},
		},
	}

	terragruntCleanExistingStackOptions := &terragrunt.Options{
		TerragruntDir:    terragruntDir,
		TerragruntBinary: "terragrunt",
	}

	terragrunt.TgStackClean(t, terragruntCleanExistingStackOptions)

	for _, tc := range testCases {

		t.Run(tc.unitName, func(t *testing.T) {
			t.Parallel()

			t.Logf("terragrunt plan running...")
			terragruntOptions := &terragrunt.Options{
				TerragruntDir:    terragruntDir,
				TerragruntBinary: "terragrunt",
				TerragruntArgs:   []string{"plan"},
				EnvVars:          tc.expected,
			}

			terragrunt.TgStackRun(t, terragruntOptions)

			defer terragrunt.TgStackCleanE(t, terragruntOptions)

			t.Logf("terragrunt apply running...")
			terragruntApplyOptions := &terragrunt.Options{
				TerragruntDir:    terragruntDir,
				TerragruntBinary: "terragrunt",
				TerragruntArgs:   []string{"apply"},
				EnvVars:          tc.expected,
			}

			terragrunt.TgStackRunE(t, terragruntApplyOptions)

			cluster_name := terragrunt.TgOutput(t, terragruntApplyOptions, "cluster_name")

			assert.Equal(t, tc.expected["cluster_name"], cluster_name)

		})

	}

}
