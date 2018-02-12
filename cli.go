package main

import (
	"os"

	"github.com/urfave/cli"
)

func newApp() *cli.App {
	app := cli.NewApp()
	app.Name = "brocket"
	app.Usage = "github.com/groovenauts/brocket"
	app.Version = VERSION

	docker := &Docker{}

	app.Commands = []cli.Command{
		docker.BuildCommand(),
		docker.PushCommand(),
	}

	return app
}

func main() {
	app := newApp()
	app.Run(os.Args)
}
