package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var pipeFile = "pipe.log"

func signals ( exit_chan chan int) {
        signal_chan := make(chan os.Signal, 1)

        signal.Notify(signal_chan,
                syscall.SIGHUP,
                syscall.SIGINT,
                syscall.SIGTERM,
                syscall.SIGQUIT)
        fmt.Printf("%#v\n",os.Getpid())
        go func() {
                for {
                        s := <-signal_chan
                        switch s {
                        // kill -SIGHUP XXXX
                        case syscall.SIGHUP:
                                fmt.Println("hungup")

                        // kill -SIGINT XXXX or Ctrl+c
                        case syscall.SIGINT:
                                fmt.Println("Warikomi")
				e := os.Remove(pipeFile)
				if e != nil {
					log.Printf("%v %v\n",os.Getpid(),e)
					return
				}
                                exit_chan <- 0

                        // kill -SIGTERM XXXX
                        case syscall.SIGTERM:
                                fmt.Println("force stop")
                                exit_chan <- 0

                        // kill -SIGQUIT XXXX
                        case syscall.SIGQUIT:
                                fmt.Println("stop and core dump")
                                exit_chan <- 0

                        default:
                                fmt.Println("Unknown signal.")
                                exit_chan <- 1
                        }
                }
        }()

}

func main() {
	os.Remove(pipeFile)
        exit_chan := make(chan int)

	go signals( exit_chan );
	err := syscall.Mkfifo(pipeFile, 0666)
	if err != nil {
		log.Fatal("Make named pipe file error:", err)
	}
	go scheduleWrite()
	fmt.Println("open a named pipe file for read.")
	file, err := os.OpenFile(pipeFile, os.O_CREATE, os.ModeNamedPipe)
	if err != nil {
		log.Fatal("Open named pipe file error:", err)
	}

	reader := bufio.NewReader(file)

	go func () {
		for {
			line, err := reader.ReadBytes('\n')
			if err == nil {
				fmt.Print("load string:" + string(line))
			}
		}
	}()

        code := <-exit_chan
        os.Exit(code)

}

func scheduleWrite() {
	fmt.Println("start schedule writing.")
	f, err := os.OpenFile(pipeFile, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0777)
	if err != nil {
		log.Fatalf("error opening file: %v", err)
	}
	i := 0
	for {
		fmt.Println("write string to named pipe file.")
		f.WriteString(fmt.Sprintf("test write times:%d\n", i))
		i++
		time.Sleep(time.Second)
	}
}
/* Test result */
/*================================
go run pipe.go
open a named pipe file for read.
start schedule writing.
write string to named pipe file.
load string:test write times:0
write string to named pipe file.
load string:test write times:1
write string to named pipe file.
load string:test write times:2
=================================*/
