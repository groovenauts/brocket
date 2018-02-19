package main

import (
	"os/exec"
)

type TestExecutor struct {
	Error  error
	Result []byte
}

func (ex *TestExecutor) Run(cmd *exec.Cmd) error {
	return ex.Error
}

func (ex *TestExecutor) Output(cmd *exec.Cmd) ([]byte, error) {
	return ex.Result, ex.Error
}
