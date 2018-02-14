package main

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigurationBuildDcokerBuildCommand(t *testing.T) {
	loadConfigurationAt(t, "configuration_test/dockerfile_without_config0", "", "", func(c *Configuration, e error) {
		_, err := c.BuildDockerBuildCommand(false)
		if assert.Error(t, err) {
			assert.Equal(t, fmt.Sprintf("No IMAGE_NAME found in %s", c.FilePath), err.Error())
		}
	})
	loadConfigurationAt(t, "configuration_version_test/brocket_yaml", "", "", func(c *Configuration, e error) {
		text, err := c.BuildDockerBuildCommand(true)
		if assert.NoError(t, err) {
			assert.Equal(t, []string{"sudo", "docker", "build", "-t", "groovenauts/rails-example:0.1.2", "."}, text)
		}
	})
	loadConfigurationAt(t, "configuration_test/dockerfile_with_config3", "./app1/Dockerfile-prod", "", func(c *Configuration, e error) {
		text, err := c.BuildDockerBuildCommand(false)
		if assert.NoError(t, err) {
			assert.Equal(t, []string{"docker", "build", "-t", "groovenauts/rails-example:1.0.3", "-f", "app1/Dockerfile-prod", "."}, text)
		}
	})
}
