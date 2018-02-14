package main

import (
	"gopkg.in/yaml.v2"

	"github.com/urfave/cli"
)

type Command struct {
}

var (
	ConfigPathFlag = cli.StringFlag{
		Name:  "config,c",
		Usage: "Path to config YAML file",
	}

	DockerfileFlag = cli.StringFlag{
		Name:  "dockerfile,f",
		Usage: "Dockerfile to build",
		Value: "Dockerfile",
	}
)

func (b *Command) LoadConfiguration(c *cli.Context, f func(*Configuration) error) error {
	config := &Configuration{
		DockerfilePath: c.String("dockerfile"),
		ConfigPath:     c.String("config"),
	}
	log.Debugf("Configuration loading %v\n", config)
	err := config.Load()
	if err != nil {
		return err
	}
	yaml, err := yaml.Marshal(config)
	if err == nil {
		log.Debugf("Configuration loaded\n%s\n", string(yaml))
	}
	return f(config)
}
