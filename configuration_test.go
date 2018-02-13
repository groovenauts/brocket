package main

import (
	"os"
	"path/filepath"
	"regexp"
	"testing"

	"github.com/stretchr/testify/assert"
)

func chdir(t *testing.T, dir string, f func()) {
	cwd, err := os.Getwd()
	assert.NoError(t, err)
	defer func() {
		assert.NoError(t, os.Chdir(cwd))
	}()
	assert.NoError(t, os.Chdir("configuration_test/"+dir))
	f()
}

func loadConfigurationAt(t *testing.T, dir, dockerfile, configPath string, assertions func(*Configuration, error)) {
	chdir(t, dir, func() {
		config := &Configuration{
			ConfigPath:     configPath,
			DockerfilePath: dockerfile,
		}
		assertions(config, config.Load())
	})
}

var RuntimeGopathPattern = regexp.MustCompile(".gopath~/src/brocket/")

func TestConfiguration(t *testing.T) {
	basePath, err := filepath.Abs("configuration_test")
	assert.NoError(t, err)
	basePath = RuntimeGopathPattern.ReplaceAllString(basePath, "")

	dockerfilePathPtn := regexp.MustCompile(`:dockerfilePath`)

	type Ptn struct {
		ErrFormat  string
		Dir        string
		Dockerfile string
		ConfigPath string
	}
	patterns := []Ptn{
		Ptn{":dockerfilePath not found", "no_dockerfile_case0", "", ""},
		Ptn{":dockerfilePath not found", "no_dockerfile_case0", "", "./sub/brocket1.yaml"},
		Ptn{":dockerfilePath not found", "no_dockerfile_case0", "./app1/Dockerfile-prod", ""},
		Ptn{":dockerfilePath not found", "no_dockerfile_case0", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
		Ptn{":dockerfilePath not found", "no_dockerfile_case1", "", ""},
		Ptn{":dockerfilePath not found", "no_dockerfile_case1", "./app1/Dockerfile-prod", ""},
		Ptn{":dockerfilePath not found", "no_dockerfile_case2", "", "./sub/brocket1.yaml"},
		Ptn{":dockerfilePath not found", "no_dockerfile_case2", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
		Ptn{":dockerfilePath has no configuration", "dockerfile_without_config0", "", ""},
		Ptn{":dockerfilePath has no configuration", "dockerfile_without_config0", "", "./sub/brocket1.yaml"},
		Ptn{":dockerfilePath has no configuration", "dockerfile_without_config1", "./app1/Dockerfile-prod", ""},
		Ptn{":dockerfilePath has no configuration", "dockerfile_without_config1", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
	}
	for _, ptn := range patterns {
		loadConfigurationAt(t, ptn.Dir, ptn.Dockerfile, ptn.ConfigPath, func(c *Configuration, err error) {
			if assert.Error(t, err) {
				dockerfileName := ptn.Dockerfile
				if dockerfileName == "" {
					dockerfileName = "Dockerfile"
				}
				dockerfilePath := filepath.Join(basePath, ptn.Dir, dockerfileName)
				msg := dockerfilePathPtn.ReplaceAllString(ptn.ErrFormat, dockerfilePath)
				assert.Equal(t, msg, err.Error())
			}
		})
	}
}
