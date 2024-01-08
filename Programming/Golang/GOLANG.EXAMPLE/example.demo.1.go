package main

import (
	"fmt"
)

func main1() {
	var a interface{}
	z := 4_555_555
	x := &z
	a = &x
	b := &a
	c := &b
	d := &c

	fmt.Printf("H1) %#v\r", d)
	fmt.Printf("H2) %#v\r", (*(*(*d))))
	fmt.Printf("H3) %#v\r", **(*(*(*d))).(**int))
}

func main2() {
	var a interface{}
	z := 4_555_555
	x := &z
	y := &x
	a = &y
	b := &a
	c := &b
	d := &c

	fmt.Printf("H1) %#v\r", d)
	fmt.Printf("H2) %#v\r", (*(*(*d))))
	fmt.Printf("H3) %#v\r", ***(*(*(*d))).(***int))
}

func main() {
	main1()
	main2()
}
