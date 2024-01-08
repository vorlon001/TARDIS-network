// https://go.dev/play/p/7EkKzz-3Zzh

package main

import "fmt"

type employee struct {
	name         string
	age          int
	salary       int
	callBackFunc func() //То самое новое поле хранящее функцию
}

func (a *employee) Show() {
	a.callBackFunc() //<- теперь здесь будет вызов той функции, что была сохранена в поле структуры!
}

func (a *employee) Shows() {
	fmt.Printf("???????????<<<%v", a.name)
}

type employee_interface interface {
	Show()
	Shows()
}

type Play struct {
	employee
	Messages string
}

func (a *Play) toShow() {
	fmt.Printf(">>>>>>>%v >>>>%v\n", a.name, a.Messages)
}

func NewEmployee(name string, age int, salary int) employee_interface {
	emp3 := Play{
		employee: employee{
			name:   "Sam",
			age:    31,
			salary: 2000,
		},
		Messages: "eeeeeeeeeeeeeeeeeezfgsdfgsd",
	}
	emp3.callBackFunc = emp3.toShow
	return &emp3
}

func main() {

	emp := NewEmployee("Sam", 31, 2000)

	fmt.Printf("Emp3: %#v\n", emp)
	emp.Show()
	emp.Shows()
}

