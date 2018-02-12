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

	return app
}

func main() {
	app := newApp()
	app.Run(os.Args)
}
