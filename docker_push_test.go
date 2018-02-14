package main

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigurationBuildDcokerPushCommand(t *testing.T) {
	loadConfigurationAt(t, "configuration_test/dockerfile_without_config0", "", "", func(c *Configuration, e error) {
		if assert.Error(t, e) {
			assert.Equal(t, fmt.Sprintf("%s has no configuration", c.AbsDockerfilePath), e.Error())
		}
	})
	loadConfigurationAt(t, "configuration_version_test/brocket_yaml", "", "", func(c *Configuration, e error) {
		if assert.NoError(t, e) {
			text, err := c.BuildDockerPushCommand(true)
			if assert.NoError(t, err) {
				assert.Equal(t, [][]string{[]string{"sudo", "docker", "push", "groovenauts/rails-example:0.1.2"}}, text)
			}
		}
	})
	loadConfigurationAt(t, "configuration_test/dockerfile_with_config3", "./app1/Dockerfile-prod", "", func(c *Configuration, e error) {
		if assert.NoError(t, e) {
			text, err := c.BuildDockerPushCommand(false)
			if assert.NoError(t, err) {
				assert.Equal(t, [][]string{[]string{"docker", "push", "groovenauts/rails-example:1.0.3"}}, text)
			}
		}
	})
	loadConfigurationAt(t, "docker_push_test/dockerfile_with_config", "", "", func(c *Configuration, e error) {
		if assert.NoError(t, e) {
			text, err := c.BuildDockerPushCommand(false)
			if assert.NoError(t, err) {
				assert.Equal(t, [][]string{
					[]string{"docker", "tag", "groovenauts/rails-example:0.2.3", "asia.gcr.io/groovenauts/groovenauts/rails-example:0.2.3"},
					[]string{"gcloud", "docker", "--", "push", "asia.gcr.io/groovenauts/groovenauts/rails-example:0.2.3"},
				}, text)
			}
		}
	})
	loadConfigurationAt(t, "docker_push_test/brocket_yaml", "", "brocket-production.yml", func(c *Configuration, e error) {
		if assert.NoError(t, e) {
			text, err := c.BuildDockerPushCommand(false)
			if assert.NoError(t, err) {
				assert.Equal(t, [][]string{
					[]string{"docker", "tag", "groovenauts/rails-example:0.1.2", "asia.gcr.io/groovenauts-production/groovenauts/rails-example:0.1.2"},
					[]string{"docker", "tag", "groovenauts/rails-example:0.1.2", "asia.gcr.io/groovenauts-production/groovenauts/rails-example:latest"},
					[]string{"gcloud", "docker", "--", "push", "asia.gcr.io/groovenauts-production/groovenauts/rails-example:0.1.2"},
					[]string{"gcloud", "docker", "--", "push", "asia.gcr.io/groovenauts-production/groovenauts/rails-example:latest"},
				}, text)
			}
		}
	})
	loadConfigurationAt(t, "docker_push_test/brocket_yaml", "", "brocket-staging.yml", func(c *Configuration, e error) {
		if assert.NoError(t, e) {
			text, err := c.BuildDockerPushCommand(true)
			if assert.NoError(t, err) {
				assert.Equal(t, [][]string{
					[]string{"sudo", "docker", "tag", "groovenauts/rails-example:0.1.2", "asia.gcr.io/groovenauts-staging/groovenauts/rails-example:0.1.2"},
					[]string{"sudo", "docker", "tag", "groovenauts/rails-example:0.1.2", "asia.gcr.io/groovenauts-staging/groovenauts/rails-example:latest"},
					[]string{"sudo", "gcloud", "docker", "--", "push", "asia.gcr.io/groovenauts-staging/groovenauts/rails-example:0.1.2"},
					[]string{"sudo", "gcloud", "docker", "--", "push", "asia.gcr.io/groovenauts-staging/groovenauts/rails-example:latest"},
				}, text)
			}
		}
	})
}
