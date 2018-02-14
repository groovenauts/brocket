package main

import (
	"io/ioutil"
	"os/exec"
	"strings"
)

func (c *Configuration) GetVersion() (string, error) {
	if c.VersionScript != "" {
		return c.GetVersionFromScript()
	} else {
		return c.GetVersionFromFile()
	}
}

func (c *Configuration) GetVersionFromScript() (string, error) {
	cmd := exec.Command("sh", "-c", c.VersionScript)
	cmd.Dir = c.WorkingDir
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}

func (c *Configuration) GetVersionFromFile() (string, error) {
	var result string
	f, err := c.FilepathWithCheck(c.VersionFile, "VERSION")
	if err != nil {
		return "", err
	}
	bytes, err := ioutil.ReadFile(f)
	if err != nil {
		log.Errorf("Failed to ioutil.ReadFile(%q) because of %v\n", f, err)
		return "", err
	}
	result = strings.TrimSpace(string(bytes))
	if err != nil {
		return "", err
	}
	return result, nil
}
