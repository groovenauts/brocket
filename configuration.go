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
	BaseDir        string `yaml:"-"`
	// From config file
	WorkingDir string `yaml:"WORKING_DIR"`
	ImageName  string `yaml:"IMAGE_NAME"`
	// Version
	VersionFile   string `yaml:"VERSION_FILE"`
	VersionScript string `yaml:"VERSION_SCRIPT"`
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

	configPath, err := c.FilepathWithCheck(c.ConfigPath, "brocket.yml", "brocket.yaml")
	fmt.Printf("c.FilepathWithCheck(%v, %v, %v) => (%v, %v) \n", c.ConfigPath, "brocket.yml", "brocket.yaml", configPath, err)
	if err != nil {
		switch err.(type) {
		case *FileNotFound:
			if c.ConfigPath != "" {
				return err
			}
			if configSource == "" {
				return fmt.Errorf("%s has no configuration", dockerfilePath)
			}
			c.BaseDir = filepath.Dir(dockerfilePath)
			err := c.LoadAsYaml([]byte(configSource))
			if err != nil {
				return err
			}
			c.Prepare()
			return nil
		default:
			return err
		}
	}

	c.BaseDir = filepath.Dir(configPath)
	bytes, err := ioutil.ReadFile(configPath)
	if err != nil {
		log.Errorf("Failed to ioutil.ReadFile(%q) because of %v\n", configPath, err)
		return err
	}
	err = c.LoadAsYaml(bytes)
	if err != nil {
		return err
	}
	c.Prepare()

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
	return true, nil
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
				result = append(result, line)
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
		c.WorkingDir = c.BaseDir
	} else {
		c.WorkingDir = filepath.Join(c.BaseDir, c.WorkingDir)
	}
}

func (c *Configuration) Chdir(f func() error) error {
	cwd, err := os.Getwd()
	if err != nil {
		return err
	}
	defer func() {
		os.Chdir(cwd)
	}()
	err = os.Chdir(c.WorkingDir)
	if err != nil {
		return err
	}
	return f()
}
