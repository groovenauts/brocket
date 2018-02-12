package main

type Configuration struct {
	ConfigPath string // Path to YAML file
	DockerfilePath string // Path to Dockerfile
	// From config file
	WorkingDir string
	ImageName string
}

func (c *Configuration) Setup() error {
	return nil
}
