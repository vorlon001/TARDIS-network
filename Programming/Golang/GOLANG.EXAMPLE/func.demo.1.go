package main

import (
	"fmt"
	"os"
	"os/exec"
)

func Start(args ...string) (p *os.Process, err error) {

	nullFile, _ := os.Open(os.DevNull)
	rpipe, _, _ := os.Pipe()
	logFile, _ := os.OpenFile("demon_demo3.LOG", os.O_WRONLY|os.O_CREATE|os.O_APPEND, os.FileMode(0640))

	f := []*os.File{
		rpipe,    // (0) stdin
		logFile,  // (1) stdout
		logFile,  // (2) stderr
		nullFile, // (3) dup on fd 0 after initialization
	}

	if args[0], err = exec.LookPath(args[0]); err == nil {
		var procAttr os.ProcAttr
		procAttr.Files = f //[]*os.File{os.Stdin, os.Stdout, os.Stderr}
		p, err := os.StartProcess(args[0], args, &procAttr)
		if err == nil {
			return p, nil
		}
	}
	return nil, err
}

func main() {

	if proc, err := Start("ping", "-c 5", "www.google.com"); err == nil {
		fmt.Printf("%#v\n", proc)
	}
}
