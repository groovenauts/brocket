package main

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/urfave/cli"
)

func (b *Command) GuardCommand() cli.Command {
	return cli.Command{
		Name:   "guard",
		Usage:  "Check if the repository is clean and committed",
		Action: b.Guard,
		Flags: []cli.Flag{
			ConfigPathFlag,
			DockerfileFlag,
		},
	}
}

func (b *Command) Guard(c *cli.Context) error {
	return b.LoadConfiguration(c, func(config *Configuration) error {
		err := config.GitGuard()
		if err != nil {
			log.Errorf("%s\n", err.Error())
			return err
		}
		log.Infof("[git guard_clean] OK")
		return nil
	})
}

func (c *Configuration) GitGuard() error {
	if !c.IsClean() || !c.IsCommitted() {
		return fmt.Errorf("There are files needed to be committed first. Run `git status`")
	}
	versionTag, err := c.GetVersionTag()
	if err != nil {
		return err
	}
	tagged, err := c.IsAlreadyTagged(versionTag)
	if err != nil {
		return err
	}
	if tagged {
		return fmt.Errorf("Tag %q has already been used", versionTag)
	}
	sameCommit, err := c.IsSameCommitAs(versionTag)
	if err != nil {
		return err
	}
	if !sameCommit {
		return fmt.Errorf("Tag %q is already tagged to another commit", versionTag)
	}
	return nil
}

func (c *Configuration) IsClean() bool {
	// `git diff --exit-code` returns 0 when there isn't any difference in woprkspace.
	cmd := exec.Command("git", "diff", "--exit-code")
	return c.ExecRun(cmd) == nil
}

func (c *Configuration) IsCommitted() bool {
	// `git diff-index --quiet --cached HEAD` returns 0 when there isn't any difference in index.
	cmd := exec.Command("git", "diff-index", "--quiet", "--cached", "HEAD")
	return c.ExecRun(cmd) == nil
}

func (c *Configuration) GetVersionTag() (string, error) {
	version, err := c.GetVersion()
	if err != nil {
		return "", err
	}
	return c.GitTagPrefix + version, nil
}

func (c *Configuration) IsAlreadyTagged(tag string) (bool, error) {
	out, err := c.ExecOutput(exec.Command("git", "tag"))
	if err != nil {
		log.Errorf("Failed to exec.Command `git tag` because of %v\n", err)
		return false, err
	}
	tags := strings.Split(string(out), "\n")
	for _, t := range tags {
		if t == tag {
			return true, nil
		}
	}
	return false, nil
}

func (c *Configuration) IsSameCommitAs(tag string) (bool, error) {
	s1, err := c.GetSha(tag)
	if err != nil {
		return false, err
	}
	s2, err := c.GetSha("HEAD")
	if err != nil {
		return false, err
	}
	return (s1 == s2), nil
}

func (c *Configuration) GetSha(obj string) (string, error) {
	out, err := c.ExecOutput(exec.Command("git", "show", obj, `--format=\"%H\"`, "--quiet"))
	if err != nil {
		log.Errorf("Failed to execute `git show %s` because of %v\n", obj, err)
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}
