package main

import (
	"os/exec"
)

type Executor interface {
	Run(cmd *exec.Cmd) error
	Output(cmd *exec.Cmd) error
}

type DefaultExecutor struct {
}

func (ex *DefaultExecutor) Run(cmd *exec.Cmd) error {
	return cmd.Run()
}

func (ex *DefaultExecutor) Output(cmd *exec.Cmd) ([]byte, error) {
	return cmd.Output()
}
