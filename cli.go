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

	cmd := &Command{}

	app.Commands = []cli.Command{
		cmd.BuildCommand(),
		cmd.PushCommand(),
	}

	return app
}

func main() {
	app := newApp()
	app.Run(os.Args)
}
