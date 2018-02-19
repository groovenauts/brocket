package main

import (
	"os/exec"
)

type Executor interface {
	Run(cmd *exec.Cmd) error
	Output(cmd *exec.Cmd) ([]byte, error)
}

type DefaultExecutor struct {
}

func (ex *DefaultExecutor) Run(cmd *exec.Cmd) error {
	return cmd.Run()
}

func (ex *DefaultExecutor) Output(cmd *exec.Cmd) ([]byte, error) {
	return cmd.Output()
}

func (c *Configuration) GetExecutor() Executor {
	if c.executor == nil {
		c.executor = &DefaultExecutor{}
	}
	return c.executor
}

func (c *Configuration) ExecRun(cmd *exec.Cmd) error {
	return c.GetExecutor().Run(cmd)
}

func (c *Configuration) ExecOutput(cmd *exec.Cmd) ([]byte, error) {
	return c.GetExecutor().Output(cmd)
}
