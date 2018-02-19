package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigurationGetVersionTag(t *testing.T) {
	loadConfigurationAt(t, "configuration_version_test/brocket_yaml", "", "", func(c *Configuration, e error) {
		assert.NoError(t, e)
		text, err := c.GetVersionTag()
		if assert.NoError(t, err) {
			assert.Equal(t, "0.1.2", text)
		}
	})
	loadConfigurationAt(t, "configuration_test/dockerfile_with_config3", "./app1/Dockerfile-prod", "", func(c *Configuration, e error) {
		assert.NoError(t, e)
		text, err := c.GetVersionTag()
		if assert.NoError(t, err) {
			assert.Equal(t, "1.0.3", text)
		}
	})

	loadConfigurationAt(t, "git_guard_test/brocket_yaml", "", "brocket-staging.yml", func(c *Configuration, e error) {
		assert.NoError(t, e)
		text, err := c.GetVersionTag()
		if assert.NoError(t, err) {
			assert.Equal(t, "staging/0.1.2", text)
		}
	})

	loadConfigurationAt(t, "git_guard_test/brocket_yaml", "", "brocket-production.yml", func(c *Configuration, e error) {
		assert.NoError(t, e)
		text, err := c.GetVersionTag()
		if assert.NoError(t, err) {
			assert.Equal(t, "production/0.1.2", text)
		}
	})
}
