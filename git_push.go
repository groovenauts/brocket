package main

import (
	"os/exec"

	"github.com/urfave/cli"
)

func (b *Command) GitPushCommand() cli.Command {
	return cli.Command{
		Name:   "git-push",
		Usage:  "Push tag to remote repository",
		Action: b.GitPush,
		Flags: []cli.Flag{
			ConfigPathFlag,
			DockerfileFlag,
		},
	}
}

func (b *Command) GitPush(c *cli.Context) error {
	return b.LoadConfiguration(c, func(config *Configuration) error {
		log.Infof("[git push] starting")
		err := config.GitPush()
		if err != nil {
			log.Errorf("%s\n", err.Error())
			return err
		}
		log.Infof("[git push] OK")
		return nil
	})
}

func (c *Configuration) GitPush() error {
	versionTag, err := c.GetVersionTag()
	if err != nil {
		return err
	}
	tagged, err := c.IsAlreadyTagged(versionTag)
	if err != nil {
		return err
	}
	if tagged {
		return nil
	}

	type FuncWithError func() error
	return c.GitTagVersion(versionTag, func() error {
		funcs := []FuncWithError{
			func() error {
				return c.PerformGitPush("commits", "")
			},
			func() error {
				return c.PerformGitPush("tags", "--tags")
			},
		}
		for _, f := range funcs {
			err := f()
			if err != nil {
				return err
			}
		}
		return nil
	})
}

func (c *Configuration) GitTagVersion(versionTag string, f func() error) error {
	cmd := exec.Command("git", "tag", "-a", "-m", "\"Version "+versionTag+"\"", versionTag)
	err := c.ExecRun(cmd)
	if err != nil {
		log.Errorf("Failed to tag %q because of %v\n", versionTag, err)
		return err
	}
	log.Infof("Tagged %q\n", versionTag)

	err = f()
	if err != nil {
		log.Warningf("Untagging %q due to error\n", versionTag)
		cmd := exec.Command("git", "tag", "-d", versionTag)
		err2 := c.ExecRun(cmd)
		if err2 != nil {
			log.Errorf("Failed to untag %q because of %v\n", versionTag, err)
			return err
		}
		log.Warningf("Untagged %q\n", versionTag)
		return err
	}
	return nil
}

func (c *Configuration) PerformGitPush(name, extra string) error {
	args := []string{"push"}
	if extra != "" {
		args = append(args, extra)
	}
	cmd := exec.Command("git", args...)
	err := c.ExecRun(cmd)
	if err != nil {
		log.Errorf("Failed to exec `git push` %s because of %v\n", name, err)
		return err
	}
	log.Infof("Pushed %s successfully\n", name)
	return nil
}
