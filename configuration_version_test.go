package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigurationVersion(t *testing.T) {
	loadConfigurationAt(t, "configuration_version_test/brocket_yaml", "", "", func(c *Configuration, e error) {
		assert.NoError(t, e)
		version, err := c.GetVersion()
		assert.NoError(t, err)
		assert.Equal(t, "0.1.2", version)
	})
	})
}
