package main

import (
	"fmt"
	"k8s.io/apimachinery/pkg/util/wait"
	"time"
)

func main()  {
	
	ticker:=time.Tick(time.Second * 5)
	ch := make(chan time.Time)
	go wait.Forever(func() {
		for  {
			select {
			case <- ticker:
				ch <- time.Now()
			}
		}
	},0)

	for t := range ch{
		fmt.Println(t)
	}
}
