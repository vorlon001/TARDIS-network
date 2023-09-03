package main
import "fmt"

type MapTypeInterface interface {
        string | int | bool
}

type MapTypeStruct[T MapTypeInterface] struct { }

// MapFunc constraint used in Funcy
type MapFunc[MFTArgs MapTypeInterface, MFTOutput MapTypeInterface] interface {
        func(s MFTArgs, ss []MFTArgs) []MFTOutput
}

// Funcy preforms map operation on generic map functions
func Funcy[MFTArgs MapTypeInterface, MFTOutput MapTypeInterface, MF MapFunc[MFTArgs,MFTOutput]](s MFTArgs, ss []MFTArgs, fn MF) []MFTOutput {
        return fn(s, ss)
}

// Funcy preforms map operation on generic map functions
func Funcy[MFTArgs MapTypeInterface, MFTOutput MapTypeInterface, MF MapFunc[MFTArgs,MFTOutput]](s MFTArgs, ss []MFTArgs, fn MF) []MFTOutput {
        return fn(s, ss)
}

// appendTo adds given string to the end of each index of given slice of strings
// Ex. appendTo("_", []string{"append", "to"}) --> []string{"append_", "to_"}
func appendTo(s string, ss []string) []string {
        var slice []string
        for _, v := range ss {
                slice = append(slice, v+s)
        }
        return slice
}

// isMatch checks given string against each index in given string slice for a
// match
// Ex. isMatch("hi", []string{"hello", "hi"}) --> []bool{false, true}
func isMatch(s int, ss []int) []bool {
        var slice []bool
        for _, v := range ss {
                slice = append(slice, s == v)
        }
        return slice
}


func main() {
        slice1 := []string{"append", "to"}
        slice2 := []int{234,653}

        fmt.Printf("%#v\n",Funcy("_", slice1, appendTo))
        fmt.Printf("%#v\n",Funcy(653, slice2, isMatch))
}
