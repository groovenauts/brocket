package main

import (
	"fmt"
	"strings"

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

func (c *Configuration) BuildDockerPushCommand(useSudo bool) ([][]string, error) {
	if c.ImageName == "" {
		return nil, fmt.Errorf("No IMAGE_NAME found in %s", c.FilePath)
	}
	remoteName := c.RemoteName()
	version, err := c.GetVersion()
	if err != nil {
		return nil, err
	}
	localNameVer := c.ImageName + ":" + version
	remoteNameVer := remoteName + ":" + version
	remoteNameExtra := ""
	if c.DockerExtraTag != "" {
		remoteNameExtra = remoteName + ":" + c.DockerExtraTag
	}
	r := [][]string{}
	var base []string
	if useSudo {
		base = []string{"sudo"}
	} else {
		base = []string{}
	}
	if c.DockerRegistry != "" || c.DockerRegistry != "" {
		r = append(r, append(base, "docker", "tag", localNameVer, remoteNameVer))
		if remoteNameExtra != "" {
			r = append(r, append(base, "docker", "tag", localNameVer, remoteNameExtra))
		}
	}
	pushCmd := append(base, strings.Split(c.DockerPushCommand, " ")...)
	r = append(r, append(pushCmd, remoteNameVer))
	if remoteNameExtra != "" {
		r = append(r, append(pushCmd, remoteNameExtra))
	}
	return r, nil
}

func (c *Configuration) RemoteName() string {
	parts := []string{}
	if c.DockerRegistry != "" {
		parts = append(parts, c.DockerRegistry)
	}
	if c.DockerUsername != "" {
		parts = append(parts, c.DockerUsername)
	}
	if c.ImageName != "" {
		parts = append(parts, c.ImageName)
	}
	return strings.Join(parts, "/")
}
