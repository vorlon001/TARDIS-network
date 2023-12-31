package main

import (
	"fmt"
	"reflect"
	//	"github.com/shirou/gopsutil/v3/mem"
	//	"github.com/shirou/gopsutil/mem"  // to use v2
)

func exportReflectValue(
  field_value reflect.Value, indent string,
  loop_detector map[uintptr]bool) string {
  defer func() { recover() }()
  var_type := field_value.Kind().String()
  inside_indent := indent + "  "
  switch field_value.Kind() {
  case reflect.Bool:
    return fmt.Sprintf("%s(%t)", var_type, field_value.Bool())
  case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
    return fmt.Sprintf("%s(%d)", var_type, field_value.Int())
  case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32,
    reflect.Uint64, reflect.Uintptr:
    return fmt.Sprintf("%s(%d)", var_type, field_value.Uint())
  case reflect.Float32:
    return fmt.Sprintf("%s(%g)", var_type, float32(field_value.Float()))
  case reflect.Float64:
    return fmt.Sprintf("%s(%g)", var_type, field_value.Float())
  case reflect.Complex64:
    return fmt.Sprintf("%s%g", var_type, complex64(field_value.Complex()))
  case reflect.Complex128:
    return fmt.Sprintf("%s%g", var_type, field_value.Complex())
  case reflect.Ptr:
    if field_value.IsNil() {
      return fmt.Sprintf("(%s)nil", field_value.Type().String())
    }
    pointer := field_value.Pointer()
    if _, present := loop_detector[pointer]; present {
      return "<infinite loop is detected>"
    }
    loop_detector[pointer] = true
    defer delete(loop_detector, field_value.Pointer())
    return "&" + exportReflectValue(field_value.Elem(), indent, loop_detector)
  case reflect.Array, reflect.Slice:
    output := fmt.Sprintf("%s{", field_value.Type())
    if field_value.Len() > 0 {
      output += "\n"
      for i := 0; i < field_value.Len(); i++ {
        output += inside_indent
        // output += exportReflectValue(field_value.Index(i), inside_indent)
        output += exportReflectValue(
          field_value.Index(i), inside_indent, loop_detector)
        output += ",\n"
      }
      output += indent
    }
    output += "}"
    return output
  case reflect.Map:
    output := fmt.Sprintf("%s{", field_value.Type())
    keys := field_value.MapKeys()
    if len(keys) > 0 {
      output += "\n"
      for _, key := range keys {
        output += inside_indent
        output += exportReflectValue(key, inside_indent, loop_detector)
        output += ": "
        output += exportReflectValue(
          field_value.MapIndex(key), inside_indent, loop_detector)
        output += ",\n"
      }
      output += indent
    }
    output += "}"
    return output
  case reflect.String:
    return fmt.Sprintf("%s(%#v)", var_type, field_value.String())
  case reflect.UnsafePointer:
    return fmt.Sprintf("unsafe.Pointer(%#v)", field_value.Pointer())
  case reflect.Struct:
    output := fmt.Sprintf("%s{\n", field_value.Type())
    for i := 0; i < field_value.NumField(); i++ {
      output += inside_indent + field_value.Type().Field(i).Name + ": "
      output += exportReflectValue(
        field_value.Field(i), inside_indent, loop_detector)
      output += ","
      if field_value.Type().Field(i).Tag != "" {
        output += fmt.Sprintf("  // Tag: %#v", field_value.Type().Field(i).Tag)
      }
      output += "\n"
    }
    output += indent + "}"
    return output
  case reflect.Interface:
    return exportReflectValue(
      reflect.ValueOf(field_value.Interface()), indent, loop_detector)
  case reflect.Chan:
    return fmt.Sprintf("(%s)%#v", field_value.Type(), field_value.Pointer())
  case reflect.Invalid:
    return "<invalid>"
  default:
    return "<" + var_type + " is not supported>"
  }
}

func Export(data interface{}) string {
  return exportReflectValue(reflect.ValueOf(data), "", map[uintptr]bool{})
}

func Print(data interface{}) {
  fmt.Println(Export(data))
}

/*
func main() {
    v, _ := mem.VirtualMemory()

    // almost every return value is a struct
    fmt.Printf("Total: %v, Free:%v, UsedPercent:%f%%\n", v.Total, v.Free, v.UsedPercent)

    // convert to JSON. String() is also implemented
    Print(v)
}
*/
