package main

import (
	"os/exec"
)

type Executor interface {
	Run(cmd *exec.Cmd) error
}

type DefaultExecutor struct {
}

func (ex *DefaultExecutor) Run(cmd *exec.Cmd) error {
	return cmd.Run()
}
