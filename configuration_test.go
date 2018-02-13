package main

import (
	"fmt"
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
	configPathPtn := regexp.MustCompile(`:configPath`)

	type Ptn struct {
		No         int
		ErrFormat  string
		Dir        string
		Dockerfile string
		ConfigPath string
	}
	patterns := []Ptn{
		Ptn{1, ":dockerfilePath not found", "no_dockerfile_case0", "", ""},
		Ptn{2, ":dockerfilePath not found", "no_dockerfile_case0", "", "./sub/brocket1.yaml"},
		Ptn{3, ":dockerfilePath not found", "no_dockerfile_case0", "./app1/Dockerfile-prod", ""},
		Ptn{4, ":dockerfilePath not found", "no_dockerfile_case0", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
		Ptn{5, ":dockerfilePath not found", "no_dockerfile_case1", "", ""},
		Ptn{6, ":dockerfilePath not found", "no_dockerfile_case1", "./app1/Dockerfile-prod", ""},
		Ptn{7, ":dockerfilePath not found", "no_dockerfile_case2", "", "./sub/brocket1.yaml"},
		Ptn{8, ":dockerfilePath not found", "no_dockerfile_case2", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
		Ptn{9, ":dockerfilePath has no configuration", "dockerfile_without_config0", "", ""},
		Ptn{10, ":dockerfilePath has no configuration", "dockerfile_without_config0", "", "./sub/brocket1.yaml"},
		Ptn{11, ":dockerfilePath has no configuration", "dockerfile_without_config1", "./app1/Dockerfile-prod", ""},
		Ptn{12, ":dockerfilePath has no configuration", "dockerfile_without_config1", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
		Ptn{13, ":configPath not found", "dockerfile_with_config0", "", "./sub/brocket1.yaml"},
		Ptn{16, ":configPath not found", "dockerfile_with_config2", "./app1/Dockerfile-prod", "./sub/brocket1.yaml"},
	}
	for _, ptn := range patterns {
		loadConfigurationAt(t, ptn.Dir, ptn.Dockerfile, ptn.ConfigPath, func(c *Configuration, err error) {
			if assert.Error(t, err, fmt.Sprintf("%v", ptn)) {
				dockerfileName := ptn.Dockerfile
				if dockerfileName == "" {
					dockerfileName = "Dockerfile"
				}
				dockerfilePath := filepath.Join(basePath, ptn.Dir, dockerfileName)

				configFileName := ptn.ConfigPath
				if configFileName == "" {
					configFileName = "brocket.{yml,yaml}"
				}
				configFilePath := filepath.Join(basePath, ptn.Dir, configFileName)

				msg := dockerfilePathPtn.ReplaceAllString(ptn.ErrFormat, dockerfilePath)
				msg = configPathPtn.ReplaceAllString(msg, configFilePath)
				assert.Equal(t, msg, err.Error(), fmt.Sprintf("%v", ptn))
			}
		})
	}
}
