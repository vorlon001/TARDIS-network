package main
// https://go.dev/play/p/MIHfbuOe_SP
import "fmt"

type employee struct {
	name   string
	age    int
	salary int
}

func (a *employee) Show() {
}

type employee_interface interface {
	Show()
}

type Employee employee

func (a *Employee) Show() {
	fmt.Printf(">>>>>>>%v\n", a.name)
}

func NewEmployee(name string, age int, salary int) employee_interface {
	emp3 := Employee{
		//		employee: employee{
		name:   "Sam",
		age:    31,
		salary: 2000,
		//		},
	}
	return &emp3
}

func main() {

	emp := NewEmployee("Sam", 31, 2000)

	fmt.Printf("Emp3: %+v\n", emp)
	emp.Show()

}
