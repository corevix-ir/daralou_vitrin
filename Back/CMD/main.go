package main

import (
	"Back/Bootstrap"
)

func main() {
	e := Bootstrap.InitializeApp()
	e.Start(":5749")
}
