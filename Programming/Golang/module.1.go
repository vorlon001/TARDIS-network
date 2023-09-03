package main

//https://play.golang.org/p/VE10ZkgGKMM
import (
	"fmt"

	f "play.ground/Core"
)

func main() {
	h := f.GetCore()
	h1 := h.GetHatter2()
	h1.Print("Hatter2")
	h2 := h.GetHatter4()
	h2.Print("Hatter4")

	r := h.GetRand()
	fmt.Printf("%d %d\n", r.Intn(100), r.Intn(100))
}
-- go.mod --
module play.ground
-- Core/module.go --
package Core

import (
	hatter "play.ground/Hatter"
	_ "play.ground/Hatter_plugin2"
	_ "play.ground/Hatter_plugin4"

	"math/rand"
	"time"
)

type core struct {
	hatter2 hatter.Hatter
	hatter4 hatter.Hatter
	rand    *rand.Rand
}

func (c *core) GetHatter2() hatter.Hatter {
	return c.hatter2
}
func (c *core) GetHatter4() hatter.Hatter {
	return c.hatter4
}
func (c *core) GetRand() *rand.Rand {
	return c.rand
}

type Core interface {
	GetHatter2() hatter.Hatter
	GetHatter4() hatter.Hatter
	GetRand() *rand.Rand
}

var _core core

func GetCore() Core {
	return &_core
}
func init() {
	hatter2, _ := hatter.GetRegisterStruct("Hatter_plugin2")
	hatter4, _ := hatter.GetRegisterStruct("Hatter_plugin4")
	source_random := rand.NewSource(time.Now().UnixNano())
	random := rand.New(source_random)
	_core = core{
		hatter2: hatter2,
		hatter4: hatter4,
		rand:    random,
	}
}
-- Hatter/module.go --
package Hatter

import (
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
)

type Hatter interface {
	Print(string)
}

var (
	driverHatter  sync.Mutex
	AtomicFormats atomic.Value
)

func RegisterStruct(name string, z Hatter) {

	driverHatter.Lock()
	defer driverHatter.Unlock()
	formats, _ := AtomicFormats.Load().(map[string]Hatter)
	formats[name] = z
	AtomicFormats.Store(formats)
}

func GetRegisterStruct(name string) (Hatter, error) {
	driverHatter.Lock()
	defer driverHatter.Unlock()

	Hatters := AtomicFormats.Load().(map[string]Hatter)
	if val, ok := Hatters[name]; ok {
		return val, nil
	}
	return nil, errors.New(fmt.Sprintf("not found driver: %s", name))
}

var Hatter_Name string

func init() {
	AtomicFormats.Store(make(map[string]Hatter, 0))
	Hatter_Name = "Hatter"
	fmt.Printf("init.Hatter %#v\n", Hatter_Name)
}
-- Hatter_plugin2/module.go --
package Hatter_plugin2

import (
	"fmt"

	hatter "play.ground/Hatter"
)

var _ hatter.Hatter = (*plugin2)(nil)
var _ = (hatter.Hatter)((*plugin2)(nil))

var Hatter_Name string

type plugin2 struct {
	Data_plugin2 string
}

func (a *plugin2) Print(z string) {
	fmt.Printf("a.print: %#v %#v\n", z, a.Data_plugin2)
}
func newPlugin(z string) hatter.Hatter {
	return &plugin2{Data_plugin2: z}
}
func init() {
	Hatter_Name = "Hatter_plugin2"
	hatter.RegisterStruct(Hatter_Name, newPlugin("Hatter_plugin2 struct"))
	fmt.Printf("init.Plugin %#v\n", Hatter_Name)
}
-- Hatter_plugin4/module.go --
package Hatter_plugin4

import (
	"fmt"

	hatter "play.ground/Hatter"
)

var _ hatter.Hatter = (*plugin4)(nil)
var _ = (hatter.Hatter)((*plugin4)(nil))

var Hatter_Name string

type plugin4 struct {
	Data_plugin4 string
}

func (a *plugin4) Print(z string) {
	fmt.Printf("a.print: %#v %#v\n", z, a.Data_plugin4)
}

func newPlugin(z string) hatter.Hatter {
	return &plugin4{Data_plugin4: z}
}

func init() {

	Hatter_Name = "Hatter_plugin4"
	hatter.RegisterStruct(Hatter_Name, newPlugin("Hatter_plugin4 struct"))
	fmt.Printf("init.Plugin 2 %#v\n", Hatter_Name)
}
