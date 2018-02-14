package main

import (
	"fmt"
	"io/ioutil"
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
	return "", nil
}

func (c *Configuration) GetVersionFromFile() (string, error) {
	var result string
	err := c.Chdir(func() error {
		existance, err := c.FileExist(c.VersionFile)
		if err != nil {
			return err
		}
		if !existance {
			return fmt.Errorf("File not found: %q at %q", c.VersionFile, c.WorkingDir)
		}
		bytes, err := ioutil.ReadFile(c.VersionFile)
		if err != nil {
			log.Errorf("Failed to ioutil.ReadFile(%q) because of %v\n", c.VersionFile, err)
			return err
		}
		result = strings.TrimSpace(string(bytes))
		return nil
	})
	if err != nil {
		return "", err
	}
	return result, nil
}
