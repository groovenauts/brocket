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
		log.Errorf("Failed to build command because of %v\n", err)
		return err
	}
	err = c.WrapWithCallbacks(func() error {
		log.Infof("[docker build] building")
		cmd := exec.Command(command[0], command[1:]...)
		cmd.Dir = c.WorkingDir
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		err = cmd.Run()
		if err != nil {
			log.Errorf("Failed to run %v because of %v\n", command, err)
			return err
		}
		return nil
	})
	if err != nil {
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

func (c *Configuration) WrapWithCallbacks(f func() error) error {
	log.Debugf("WrapWithCallbacks %v\n", 1)
	err := c.ExecBuildCallbacks(c.BeforeBuildScript)
	if err != nil {
		log.Errorf("Failed to run BeforeBuildScript because of %v\n", err)
		return err
	}

	log.Debugf("WrapWithCallbacks %v\n", 2)
	defer c.ExecBuildCallbacks(c.AfterBuildScript)

	err = f()
	if err != nil {
		// Ignore error from OnBuildErrorScript
		c.ExecBuildCallbacks(c.OnBuildErrorScript)
		return err
	}
	log.Debugf("WrapWithCallbacks %v\n", 3)

	err = c.ExecBuildCallbacks(c.OnBuildCompleteScript)
	if err != nil {
		log.Errorf("Failed to run OnBuildCompleteScript because of %v\n", err)
		return err
	}
	log.Debugf("WrapWithCallbacks %v\n", 4)

	return nil
}

func (c *Configuration) ExecBuildCallbacks(cb interface{}) error {
	log.Debugf("ExecBuildCallbacks %v\n", cb)
	if cb == nil {
		return nil
	}
	switch cb.(type) {
	case string:
		if cb.(string) == "" {
			return nil
		}
		cmd := exec.Command("sh", "-c", cb.(string))
		cmd.Dir = c.WorkingDir
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		err := cmd.Run()
		if err != nil {
			log.Errorf("Failed to run %v because of %v\n", cb, err)
			return err
		}
		return nil
	case []string:
		for _, s := range cb.([]string) {
			err := c.ExecBuildCallbacks(s)
			if err != nil {
				return err
			}
		}
		return nil
	case []interface{}:
		for _, s := range cb.([]interface{}) {
			err := c.ExecBuildCallbacks(s)
			if err != nil {
				return err
			}
		}
		return nil
	default:
		return fmt.Errorf("Unsupported callback type [%T] %v", cb, cb)
	}
}
