package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func chdir(t *testing.T, dir string, f func()) {
	cwd, err := os.Getwd()
	assert.NoError(t, err)
	defer func() {
		assert.NoError(t, os.Chdir(cwd))
	}()
	assert.NoError(t, os.Chdir(dir))
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
