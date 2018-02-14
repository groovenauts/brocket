package main

import (
	"github.com/urfave/cli"
)

func (b *Command) PushCommand() cli.Command {
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

func (b *Command) Push(c *cli.Context) error {
	return nil
}
