package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"gopkg.in/yaml.v2"
)

type Configuration struct {
	DockerfilePath string `yaml:"-"` // Path to Dockerfile
	ConfigPath     string `yaml:"-"` // Path to YAML file
	// From config file
	WorkingDir string `yaml:"WORKING_DIR"`
	ImageName  string `yaml:"IMAGE_NAME"`
}

func (c *Configuration) Load() error {
	dockerfilePath, err := c.FilepathWithCheck(c.DockerfilePath, "Dockerfile")
	if err != nil {
		return err
	}
	configSource, err := c.ExtractConfigSource(dockerfilePath)
	if err != nil {
		return err
	}

	_, err = c.FilepathWithCheck(c.ConfigPath, "brocket.yml", "brocket.yaml")
	if err != nil {
		switch err.(type) {
		case *FileNotFound:
			if c.ConfigPath != "" {
				return err
			}
			if configSource == "" {
				return fmt.Errorf("%s has no configuration", dockerfilePath)
			}
			err := c.LoadAsYaml([]byte(configSource))
			if err != nil {
				return err
			}
			c.Prepare()
		default:
			return err
		}
	}
	return nil
}

type FileNotFound struct {
	Path string
}

func (err *FileNotFound) Error() string {
	return fmt.Sprintf("%s not found", err.Path)
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
	return "", &FileNotFound{strings.Join(absPaths, " or ")}
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

var ConfigLinePattern = regexp.MustCompile(`\A\#\s*\[config\]\s?`)

func (c *Configuration) ExtractConfigSource(path string) (string, error) {
	bytes, err := ioutil.ReadFile(path)
	if err != nil {
		log.Errorf("Failed to ioutil.ReadFile(%q) because of %v\n", path, err)
		return "", err
	}
	result := []string{}
	lines := strings.Split(string(bytes), "\n")
	for _, line := range lines {
		if ConfigLinePattern.MatchString(line) {
			line := ConfigLinePattern.ReplaceAllString(line, "")
			if line != "" {
				result = append(result, strings.TrimSpace(line))
			}
		}
	}
	return strings.Join(result, "\n"), nil
}

func (c *Configuration) LoadAsYaml(source []byte) error {
	err := yaml.Unmarshal(source, c)
	if err != nil {
		return fmt.Errorf("Failed to yaml.Unmarshal because of %v", err)
	}
	return nil
}

func (c *Configuration) Prepare() {
	if c.WorkingDir == "" {
		c.WorkingDir = "."
	}
}
