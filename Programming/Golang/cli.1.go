package main

import (
        "fmt"
        "reflect"
        "sync"
        "github.com/spf13/cobra"
)

// ./cobra.2 root2 sub1 -c 5 -m 4096

//var core Core

var cache sync.Map

// Singleton returns a singleton of T.
func Singleton[T any]() (t *T) {
        hash := reflect.TypeOf(t)
        v, ok := cache.Load(hash)

        if ok {
                return v.(*T)
        }

        v = new(T)
        v, _ = cache.LoadOrStore(hash, v)
        return v.(*T)
}


type CobraMenu struct { }

func (f *CobraMenu) RootsCmd1() *cobra.Command {

  var rootsCmd1 = &cobra.Command{
    Use:   "root1 [sub]",
    Short: "My root command",
    PersistentPreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PersistentPreRun with args: %v\n", args)
    },
    PreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PreRun with args: %v\n", args)
    },
    Run: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd Run with args: %v\n", args)
    },
    PostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PostRun with args: %v\n", args)
    },
    PersistentPostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PersistentPostRun with args: %v\n", args)
    },
  }
        return rootsCmd1
}

func (f *CobraMenu) RootsCmd2() *cobra.Command {
  var rootsCmd2 = &cobra.Command{
    Use:   "root2 [sub]",
    Short: "My root command",
    PersistentPreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PersistentPreRun with args: %v\n", args)
    },
    PreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PreRun with args: %v\n", args)
    },
    Run: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd Run with args: %v\n", args)
    },
    PostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PostRun with args: %v\n", args)
    },
    PersistentPostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PersistentPostRun with args: %v\n", args)
    },
  }
        return rootsCmd2
}


func (f *CobraMenu) RootsCmd1subCmd1() *cobra.Command {
  var subCmd1 = &cobra.Command{
    Use:   "sub1 [no options!]",
    Short: "My subcommand",
    PreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PreRun with args: %v\n", args)
    },
    Run: func(cmd *cobra.Command, args []string) {
        core := Singleton[Core]()
        fmt.Printf(" myMapFlag1:%d myMapFlag2:%s \n", core.myMapFlag1, core.myMapFlag2)
        fmt.Printf("Inside subCmd1Run with args: %v\n", args)
    },
    PostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PostRun with args: %v\n", args)
    },
    PersistentPostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PersistentPostRun with args: %v\n", args)
    },
  }
        return subCmd1
}

func (f *CobraMenu) RootsCmd1subCmd2() *cobra.Command {
  var subCmd2 = &cobra.Command{
    Use:   "sub2 [no options!]",
    Short: "My subcommand",
    PreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PreRun with args: %v\n", args)
    },
    Run: func(cmd *cobra.Command, args []string) {
        core := Singleton[Core]()
        fmt.Printf(" myMapFlag1:%d myMapFlag2:%s \n", core.myMapFlag1, core.myMapFlag2)
        fmt.Printf("Inside subCmd Run with args: %v\n", args)
    },
    PostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PostRun with args: %v\n", args)
    },
    PersistentPostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PersistentPostRun with args: %v\n", args)
    },
  }
        return subCmd2
}


func GetCobraMenu(name string) *cobra.Command {

        CobraMenu := CobraMenu{}
        CobraMenuType := reflect.TypeOf(&CobraMenu)
        CobraMenuValue := reflect.ValueOf(&CobraMenu)

        method, err := CobraMenuType.MethodByName(name)
        if err !=true {
                return nil
        }

        val := CobraMenuValue.MethodByName(method.Name).Call([]reflect.Value{})

        if len(val)==1 {
                return val[0].Interface().(*cobra.Command)
        }
        return nil
}

type SubMenu struct {
    Name string
    Run func(c *cobra.Command)
}

type Menu struct {
        Name    string   `yaml:"name"`
        SubMenu []SubMenu `yaml:"subMenu"`
}
type Core struct {
        Menu []Menu `yaml:"menu"`
        myMapFlag1 int
        myMapFlag2 string
}

func initCoreCobra() {

        core := Singleton[Core]()

        core.Menu = []Menu{
                                        Menu{
                                                Name:"RootsCmd1",
                                                SubMenu: []SubMenu{
                                                  SubMenu{ Name: "RootsCmd1subCmd1",
                                                  Run: func(c *cobra.Command) {
                                                      core := Singleton[Core]()
                                                      c.PersistentFlags().IntVarP(&core.myMapFlag1, "cpu", "c", 2,"Num CPU Cores")
                                                      c.PersistentFlags().StringVarP(&core.myMapFlag2, "memory", "m","4096","Memory in Mbytes")
                                                  }},
                                                  SubMenu{ Name: "RootsCmd1subCmd2",
                                                  Run: func(c *cobra.Command) {
                                                      core := Singleton[Core]()
                                                      c.PersistentFlags().IntVarP(&core.myMapFlag1, "cpu", "c", 2,"Num CPU Cores")
                                                      c.PersistentFlags().StringVarP(&core.myMapFlag2, "memory", "m","4096","Memory in Mbytes")
                                                  }},
                                                  },
                                        },
                                        Menu{
                                                Name:"RootsCmd2",
                                                SubMenu: []SubMenu{
                                                  SubMenu{ Name: "RootsCmd1subCmd1",
                                                  Run: func(c *cobra.Command) {
                                                      core := Singleton[Core]()
                                                      c.PersistentFlags().IntVarP(&core.myMapFlag1, "cpu", "c", 2,"Num CPU Cores")
                                                      c.PersistentFlags().StringVarP(&core.myMapFlag2, "memory", "m","4096","Memory in Mbytes")
                                                  }},
                                                  SubMenu{ Name: "RootsCmd1subCmd2",
                                                  Run: func(c *cobra.Command) {
                                                      core := Singleton[Core]()
                                                      c.PersistentFlags().IntVarP(&core.myMapFlag1, "cpu", "c", 2,"Num CPU Cores")
                                                      c.PersistentFlags().StringVarP(&core.myMapFlag2, "memory", "m","4096","Memory in Mbytes")
                                                  }},
                                                },
                                        },
                }
}


func initMenu() *cobra.Command {

        initCoreCobra()

        var rootCmd = &cobra.Command{Use: "app"}
        core := Singleton[Core]()

        for _,v := range core.Menu {
                rootMenu := GetCobraMenu(v.Name)
                for _,j := range v.SubMenu {
                        subCmd := GetCobraMenu(j.Name)
                        j.Run(subCmd)
                        rootMenu.AddCommand(subCmd)
                }
                rootCmd.AddCommand(rootMenu)
        }
        return rootCmd
}

func main() {

        initMenu().Execute()

}
