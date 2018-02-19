package main

import (
	"fmt"
	"os"
	"os/exec"
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
	return b.LoadConfiguration(c, func(config *Configuration) error {
		return config.PushDockerImage(b.useSudo(c))
	})
}

func (c *Configuration) PushDockerImage(useSudo bool) error {
	log.Infof("[docker push] starting")
	commands, err := c.BuildDockerPushCommand(useSudo)
	if err != nil {
		log.Errorf("Failed to build command because of %v\n", err)
		return err
	}
	log.Infof("[docker push] executing...")
	for _, command := range commands {
		cmd := exec.Command(command[0], command[1:]...)
		cmd.Dir = c.WorkingDir
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		err = c.ExecRun(cmd)
		if err != nil {
			log.Errorf("Failed to run %v because of %v\n", command, err)
			return err
		}
	}
	log.Infof("[docker push] OK")
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
	base := c.CommandBase(useSudo)
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
