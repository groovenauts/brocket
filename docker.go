package main

import (
	"github.com/urfave/cli"
)

var (
	UseSudoForDockerFlag = cli.StringFlag{
		Name:  "use-sudo-for-docker,S",
		Usage: "Set to log your configuration loaded",
		Value: "auto",
	}
)

func (c *Configuration) CommandBase(useSudo bool) []string {
	if useSudo {
		return []string{"sudo"}
	} else {
		return []string{}
	}
}
