package main

import (
	"github.com/urfave/cli"
)

type Docker struct {
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

	UseSudoForDockerFlag = cli.BoolFlag{
		Name:  "use-sudo-for-docker,S",
		Usage: "Set to log your configuration loaded",
	}
)

func (b *Docker) BuildCommand() cli.Command {
	return cli.Command{
		Name:   "build",
		Usage:  "Build docker image",
		Action: b.Build,
		Flags: []cli.Flag{
			ConfigPathFlag,
			DockerfileFlag,
			UseSudoForDockerFlag,
		},
	}
}

func (b *Docker) LoadConfiguration(c *cli.Context, f func(*Configuration) error) error {
	config := &Configuration{
		DockerfilePath: c.String("dockerfile"),
		ConfigPath:     c.String("config"),
	}
	err := config.Load()
	if err != nil {
		return err
	}
	return f(config)
}

func (b *Docker) Build(c *cli.Context) error {
	return b.LoadConfiguration(c, func(config *Configuration) error {
		return nil
	})
}

func (b *Docker) PushCommand() cli.Command {
	return cli.Command{
		Name:   "push",
		Usage:  "Push docker image to registry",
		Action: b.Push,
		Flags: []cli.Flag{
			ConfigPathFlag,
			DockerfileFlag,
			UseSudoForDockerFlag,
		},
	}
}

func (b *Docker) Push(c *cli.Context) error {
	return nil
}
