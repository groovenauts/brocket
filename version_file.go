package main

import (
	"fmt"

	"github.com/urfave/cli"
)

func (b *Command) VersionCommand() cli.Command {
	return cli.Command{
		Name:   "version",
		Usage:  "Show version",
		Action: b.ShowVersion,
		Flags: []cli.Flag{
			ConfigPathFlag,
			DockerfileFlag,
		},
	}
}

func (b *Command) ShowVersion(c *cli.Context) error {
	return b.LoadConfiguration(c, func(config *Configuration) error {
		version, err := config.GetVersion()
		if err != nil {
			return err
		}
		fmt.Println(version)
		return nil
	})
}
