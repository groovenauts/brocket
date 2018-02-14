package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/urfave/cli"
)

var (
	UseSudoForDockerFlag = cli.StringFlag{
		Name:  "use-sudo-for-docker,S",
		Usage: "Set to log your configuration loaded",
		Value: "auto",
	}
)

func (b *Command) BuildCommand() cli.Command {
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

func (b *Command) Build(c *cli.Context) error {
	return b.LoadConfiguration(c, func(config *Configuration) error {
		return config.BuildDockerImage(b.useSudo(c))
	})
}

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

func (b *Command) useSudo(c *cli.Context) bool {
	switch c.String("use-sudo-for-docker") {
	case "auto":
		cmd := exec.Command("sh", "-c", "docker ps >/dev/null 2>/dev/null")
		err := cmd.Run()
		return err != nil
	case "true":
		return true
	default:
		return false
	}
}

func (c *Configuration) BuildDockerImage(useSudo bool) error {
	log.Infof("[docker build] starting")
	command, err := c.BuildDockerBuildCommand(useSudo)
	if err != nil {
		return err
	}
	cmd := exec.Command(command[0], command[1:]...)
	cmd.Dir = c.WorkingDir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	if err != nil {
		log.Errorf("Failed to run %v because of %v\n", command, err)
		return err
	}
	log.Infof("[docker build] OK")
	return nil
}

func (c *Configuration) BuildDockerBuildCommand(useSudo bool) ([]string, error) {
	if c.ImageName == "" {
		return nil, fmt.Errorf("No IMAGE_NAME found in %s", c.FilePath)
	}
	version, err := c.GetVersion()
	if err != nil {
		return nil, err
	}
	cmd := []string{"docker", "build", "-t", c.ImageName + ":" + version}
	rel, err := filepath.Rel(c.WorkingDir, c.AbsDockerfilePath)
	if err != nil {
		return nil, fmt.Errorf("Failed to get filepath.Rel(%q, %q) because of %v", c.WorkingDir, c.AbsDockerfilePath, err)
	}
	if rel != "Dockerfile" {
		cmd = append(cmd, "-f", rel)
	}
	cmd = append(cmd, ".")
	if useSudo {
		cmd = append([]string{"sudo"}, cmd...)
	}
	return cmd, nil
}
