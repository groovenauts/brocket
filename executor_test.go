package main

import (
	"os/exec"
)

type TestExecutor struct {
	Cmd   *exec.Cmd
	Error error
}

func (ex *TestExecutor) Run(cmd *exec.Cmd) error {
	ex.Cmd = cmd
	return ex.Error
}
