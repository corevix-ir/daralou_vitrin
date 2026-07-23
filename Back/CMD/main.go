package main

import (
	"Back/Bootstrap"
	"fmt"
)

func main() {
	fmt.Println("Hello World")
	e := Bootstrap.InitializeApp()
	e.Start(":5749")
}
