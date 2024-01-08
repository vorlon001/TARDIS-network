package main

import (
	"fmt"
)

type container struct {
	items []int
}
func (c *container) Iter () <-chan *int{
    ch := make(chan *int);
    go func () {
        for i := 0; i < len(c.items); i++ {
            ch <- &c.items[i]
        }
	ch <- nil
    } ();
    return ch
}

func main() {
	c := container{ items: []int{5,6,6,23,234,345,2345,2356}}
	for v := range c.Iter() {
		if v==nil {
			break
		}
		fmt.Println(*v)
	}
	fmt.Println("Hello, playground")
}
