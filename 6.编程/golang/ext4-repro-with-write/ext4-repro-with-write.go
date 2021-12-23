package main


import (

	"flag"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)



const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

const path = "/usr/share/fxck/"



func RandStringBytes(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}

	return string(b)

}



func createFileName(path string) string {
	name, _ := os.Hostname()
	fn := path + name + strconv.Itoa(int(time.Now().Unix())) + RandStringBytes(8)
	return fn
}



func w(path string) {
	fn := createFileName(path)
	fmt.Println(fn)
	f, _ := os.OpenFile(fn, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	fmt.Println(f)
	defer os.Remove(fn)

	defer f.Close()

	for {
		s := RandStringBytes(10)
		_, _ = f.WriteString(s)
		f.Sync()

	}

}


func main() {
	path := flag.String("path", "/usr/share/ext4-repo/", "a string")
	flag.Parse()

	fmt.Println("path:", *path)
	go w(*path)

	for {
		time.Sleep(time.Duration(1) * time.Second)

	}
}