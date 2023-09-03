// https://go.dev/play/p/DoqTngbyiP7

package main

import (
	"fmt"
)

func main() {

	fmt.Println("---------------------------------------------------------------")
	var newSecond NewObjectBase
	var newBase NewObjectBase

	newBase = newObjectBase
	newSecond = newObjectSecondTypeBase

	demoBase := newSecond(newBase(nil))
	fmt.Printf("%#v\n", demoBase)
	demoBase.Show("EVENT: func.show1")
	demoBase.Print("EVENT: func.show1")

	fmt.Println("---------------------------------------------------------------")

	demoSecond := newObjectSecondTypeSecond(newObjectBase(nil))
	fmt.Printf("%#v\n", demoSecond)
	demoSecond.Show("EVENT: func.show1")
	demoSecond.Print("EVENT: func.show1")

	fmt.Println("---------------------------------------------------------------")
}

type ObjectInterface interface {
	Show(string)
	Print(string)
}

type ObjectBase struct {
}

func newObjectBase(objectBase ObjectInterface) ObjectInterface {
	return &ObjectBase{}
}
func (c *ObjectBase) Show(a string) {
	fmt.Println("ObjectBase:show")
	fmt.Println(a)
}
func (c *ObjectBase) Print(a string) {
	fmt.Println("ObjectBase:print")
	fmt.Println(a)
}

type ObjectSecond struct {
	ObjectInterface
	var1 int
	var2 string
}

func (c *ObjectSecond) Draw() {
	fmt.Println("cancelCtx: draw")
	fmt.Printf("%#v %#v\n", c.var1, c.var2)
}

type ObjectSecondInterface interface {
	ObjectInterface
	Draw()
}

func (c *ObjectSecond) Show(a string) {
	fmt.Println("ObjectSecond:show")
	fmt.Println(a, c)
}
func (c *ObjectSecond) Print(a string) {
	fmt.Println("ObjectSecond:print")
	fmt.Println(a, c)
}

type NewObjectBase func(ObjectInterface) ObjectInterface

func newObjectSecondTypeSecond(objectBase ObjectInterface) ObjectSecondInterface {
	return &ObjectSecond{ObjectInterface: objectBase, var1: 234, var2: "2345234"}
}

func newObjectSecondTypeBase(objectBase ObjectInterface) ObjectInterface {
	return &ObjectSecond{ObjectInterface: objectBase, var1: 234, var2: "2345234"}
}


/*


---------------------------------------------------------------
&main.ObjectSecond{ObjectInterface:(*main.ObjectBase)(0x55e008), var1:234, var2:"2345234"}
ObjectSecond:show
EVENT: func.show1 &{0x55e008 234 2345234}
ObjectSecond:print
EVENT: func.show1 &{0x55e008 234 2345234}
---------------------------------------------------------------
&main.ObjectSecond{ObjectInterface:(*main.ObjectBase)(0x55e008), var1:234, var2:"2345234"}
ObjectSecond:show
EVENT: func.show1 &{0x55e008 234 2345234}
ObjectSecond:print
EVENT: func.show1 &{0x55e008 234 2345234}
---------------------------------------------------------------



*/