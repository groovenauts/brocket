package main

import (
	"os"

	"github.com/urfave/cli"
)

func newApp() *cli.App {
	InitLog()

	app := cli.NewApp()
	app.Name = "brocket"
	app.Usage = "github.com/groovenauts/brocket"
	app.Version = VERSION

	cmd := &Command{}

	app.Commands = []cli.Command{
		cmd.BuildCommand(),
		cmd.PushCommand(),
		cmd.VersionCommand(),
		cmd.GuardCommand(),
		cmd.GitPushCommand(),
	}

	return app
}

func main() {
	app := newApp()
	app.Run(os.Args)
}
