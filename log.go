package main

import (
	"github.com/sirupsen/logrus"
)

var log = logrus.New()

func InitLog() error {
	log.SetLevel(logrus.DebugLevel)
	return nil
}
