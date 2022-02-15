package main

import (
"fmt"
"math/rand"
"strings"
"time"
)

func main() {
	testProgress()
}

// 测试进度条
func testProgress() {
	// 更新当前的状态
	fmt.Println("Start processing... ")

	var total = 30
	for i := 0; i < total; i++ {
		time.Sleep(time.Duration(rand.Intn(400)) * time.Millisecond)

		// 计算百分比
		percent := int(float32(i+1) * 100.0 / float32(total))

		pro := Progress(percent)
		pro.Show()
	}
	fmt.Printf("\nDone!\n")
}

// Progress 进度
type Progress int

// Show 显示进度
func (x Progress) Show() {
	percent := int(x)
	// fmt.Println("percent: ", percent)

	total := 50 // 这个total是格子数
	middle := int(percent * total / 100.0)
	// fmt.Printf("middle:%d\n", middle)

	arr := make([]string, total)
	for j := 0; j < total; j++ {
		if j < middle-1 {
			arr[j] = "-"
		} else if j == middle-1 {
			arr[j] = ">"
		} else {
			arr[j] = " "
		}
	}
	bar := fmt.Sprintf("[%s]", strings.Join(arr, ""))
	fmt.Printf("\r%s %%%d", bar, percent)
}
