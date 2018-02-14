package main

import (
	"fmt"
	"path/filepath"
	"regexp"
	"testing"

	"github.com/stretchr/testify/assert"
)

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
		WorkingDir string
	}
	patterns := []Ptn{
		Ptn{1, ":dockerfilePath not found", "no_dockerfile_case0", "", "", ""},
		Ptn{2, ":dockerfilePath not found", "no_dockerfile_case0", "", "./sub/brocket1.yaml", ""},
		Ptn{3, ":dockerfilePath not found", "no_dockerfile_case0", "./app1/Dockerfile-prod", "", ""},
		Ptn{4, ":dockerfilePath not found", "no_dockerfile_case0", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", ""},
		Ptn{5, ":dockerfilePath not found", "no_dockerfile_case1", "", "", ""},
		Ptn{6, ":dockerfilePath not found", "no_dockerfile_case1", "./app1/Dockerfile-prod", "", ""},
		Ptn{7, ":dockerfilePath not found", "no_dockerfile_case2", "", "./sub/brocket1.yaml", ""},
		Ptn{8, ":dockerfilePath not found", "no_dockerfile_case2", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", ""},
		Ptn{9, ":dockerfilePath has no configuration", "dockerfile_without_config0", "", "", ""},
		Ptn{10, ":configPath not found", "dockerfile_without_config0", "", "./sub/brocket1.yaml", ""},
		Ptn{11, ":dockerfilePath has no configuration", "dockerfile_without_config1", "./app1/Dockerfile-prod", "", ""},
		Ptn{12, ":configPath not found", "dockerfile_without_config1", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", ""},
		Ptn{13, ":configPath not found", "dockerfile_with_config0", "", "./sub/brocket1.yaml", ""},
		Ptn{16, ":configPath not found", "dockerfile_with_config2", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", ""},
		Ptn{30, ":dockerfilePath not found", "sub_brocket_yaml_case5", "./invalid/Dockerfile-prod", "./sub/brocket1.yaml", "sub"},
		Ptn{30, ":configPath not found", "sub_brocket_yaml_case5", "./app1/Dockerfile-prod", "./invalid/brocket1.yaml", "sub"},
		Ptn{30, ":dockerfilePath not found", "sub_brocket_yaml_case5", "./invalid/Dockerfile-prod", "./invalid/brocket1.yaml", "sub"},
	}
	for _, ptn := range patterns {
		loadConfigurationAt(t, "configuration_test/"+ptn.Dir, ptn.Dockerfile, ptn.ConfigPath, func(c *Configuration, err error) {
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

	patterns = []Ptn{
		Ptn{14, "", "dockerfile_with_config0", "", "", "."},
		Ptn{15, "", "dockerfile_with_config1", "", "", "build"},
		Ptn{17, "", "dockerfile_with_config2", "./app1/Dockerfile-prod", "", "app1"},
		Ptn{18, "", "dockerfile_with_config3", "./app1/Dockerfile-prod", "", "."},
		Ptn{19, "", "root_brocket_yaml_case0", "", "", "."},
		Ptn{20, "", "root_brocket_yaml_case1", "", "", "build"},
		Ptn{21, "", "root_brocket_yaml_case2", "", "", "."},
		Ptn{22, "", "root_brocket_yaml_case3", "./app1/Dockerfile-prod", "", "."},
		Ptn{23, "", "root_brocket_yaml_case4", "./app1/Dockerfile-prod", "", "app1"},
		Ptn{24, "", "root_brocket_yaml_case5", "./app1/Dockerfile-prod", "", "."},
		Ptn{25, "", "sub_brocket_yaml_case0", "", "./sub/brocket1.yaml", "sub"},
		Ptn{26, "", "sub_brocket_yaml_case1", "", "./sub/brocket1.yaml", "."},
		Ptn{27, "", "sub_brocket_yaml_case2", "", "./sub/brocket1.yaml", "sub"},
		Ptn{28, "", "sub_brocket_yaml_case3", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", "sub"},
		Ptn{29, "", "sub_brocket_yaml_case4", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", "app1"},
		Ptn{30, "", "sub_brocket_yaml_case5", "./app1/Dockerfile-prod", "./sub/brocket1.yaml", "sub"},
	}
	for _, ptn := range patterns {
		fmt.Printf("test case: %v\n", ptn)
		loadConfigurationAt(t, "configuration_test/"+ptn.Dir, ptn.Dockerfile, ptn.ConfigPath, func(c *Configuration, err error) {
			if assert.NoError(t, err, fmt.Sprintf("%v", ptn)) {
				assert.Equal(t, "groovenauts/rails-example", c.ImageName, fmt.Sprintf("%v", ptn))
				wd, err := filepath.Abs(ptn.WorkingDir)
				assert.NoError(t, err)
				assert.Equal(t, wd, c.WorkingDir, fmt.Sprintf("%v", ptn))
			}
		})
	}
}
