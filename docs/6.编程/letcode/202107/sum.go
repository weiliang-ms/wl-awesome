package main

import "fmt"

/*
	给定一个整数数组 nums 和一个整数目标值 target，请你在该数组中找出和为目标值target 的那两个整数，并返回它们的数组下标。

	你可以假设每种输入只会对应一个答案。但是，数组中同一个元素在答案里不能重复出现。

	你可以按任意顺序返回答案。
*/
func main() {
	nums := []int{11, 2, 13, 12, 23, 14, 28, 8}
	target := 27
	//now := time.Now()
	// return:
	re := code1(nums, target)
	fmt.Printf("%v", re)
}

func code1(nums []int, target int) []int {
	hashT := map[int]int{}
	for k, v := range nums {
		if p, ok := hashT[target-v]; ok {
			return []int{k, p}
		}
		hashT[v] = k
	}
	return nil
}
