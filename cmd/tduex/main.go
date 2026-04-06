package main

import (
	"fmt"
	"os"

	"github.com/med-000/tduex/internal/tduexcli"
)

func main() {
	if err := tduexcli.Run(os.Args); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
