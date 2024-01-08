#!/usr/bin/sh

go mod init main
#echo "go run .go"
#go run main.go
echo "go build .go"

go get github.com/coreos/go-iptables/iptables
go get github.com/vishvananda/netlink
go get github.com/vishvananda/netns


go build -o main .
#./main 
