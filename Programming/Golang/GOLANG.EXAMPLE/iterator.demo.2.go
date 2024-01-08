package main

import (
	"fmt"
)

type Iterator struct {
	items *[]interface{}
}
func (c *Iterator) Iter () <-chan *interface{}{
    ch := make(chan *interface{});
    go func () {
        for i := 0; i < len(*c.items); i++ {
            ch <- &(*c.items)[i]
        }
	ch <- nil
    } ();
    return ch
}

func InitIter(v *[]int) *Iterator {
	s := make([]interface{}, len(*v))
	
	for i, d := range *v {
 		s[i] = d
	}
	c := Iterator{}
	c.items = &s
	return &c
}

func main() {
	v := []int{5,6,6,23,234,345,2345,2356}
	c := InitIter(&v)

	for v := range c.Iter() {
		if v==nil {
			break
		}
		fmt.Println((*v).(int))
	}
	fmt.Println("Hello, playground")
}
