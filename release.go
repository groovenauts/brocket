package main

import (
	"github.com/urfave/cli"
)

func (b *Command) ReleaseCommand() cli.Command {
	return cli.Command{
		Name:   "release",
		Usage:  "Release docker image",
		Action: b.Release,
		Flags: []cli.Flag{
			ConfigPathFlag,
			DockerfileFlag,
			UseSudoForDockerFlag,
		},
	}
}

func (b *Command) Release(c *cli.Context) error {
	return b.LoadConfiguration(c, func(config *Configuration) error {
		return config.Release(b.useSudo(c))
	})
}

func (c *Configuration) Release(useSudo bool) error {
	type FuncWithError func() error

	funcs := []FuncWithError{
		c.GitGuard,
		func() error {
			return c.BuildDockerImage(useSudo)
		},
		c.GitPush,
		func() error {
			return c.PushDockerImage(useSudo)
		},
	}

	for _, f := range funcs {
		err := f()
		if err != nil {
			return err
		}
	}
	return nil
}
