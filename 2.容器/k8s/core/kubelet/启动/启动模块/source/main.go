package main

import "fmt"

func main()  {
	value := 1 << uint(15)
	fmt.Printf("%#08x", value)
}
