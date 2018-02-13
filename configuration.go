package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type Configuration struct {
	DockerfilePath string // Path to Dockerfile
	ConfigPath     string // Path to YAML file
	// From config file
	WorkingDir string
	ImageName  string
}

func (c *Configuration) Load() error {
	_, err := c.FilepathWithCheck(c.DockerfilePath, "Dockerfile")
	if err != nil {
		return err
	}
	_, err = c.FilepathWithCheck(c.ConfigPath, "brocket.yml", "brocket.yaml")
	if err != nil {
		return err
	}
	return nil
}

func (c *Configuration) FilepathWithCheck(relPath string, candidates ...string) (string, error) {
	var relPaths []string
	if relPath != "" {
		relPaths = []string{relPath}
	} else {
		relPaths = candidates
	}
	absPaths := []string{}
	for _, relPath := range relPaths {
		path, err := filepath.Abs(relPath)
		if err != nil {
			log.Errorf("Failed to filepath.Abs(%q) because of %v\n", relPath, err)
			return "", err
		}
		absPaths = append(absPaths, path)
		existance, err := c.FileExist(path)
		if err != nil {
			return "", err
		}
		if existance {
			return path, nil
		}
	}
	return "", fmt.Errorf("%s not found", strings.Join(absPaths, " or "))
}

func (c *Configuration) FileExist(path string) (bool, error) {
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return false, nil
	}
	if err != nil {
		log.Errorf("Failed to os.Stat(%q) because of %v\n", path, err)
		return false, err
	}
	return true, err
}
