package main

import "fmt"

/*
	给定一个 n 个元素有序的（升序）整型数组 nums 和一个目标值 target  ，写一个函数搜索 nums 中的 target，如果目标值存在返回下标，否则返回 -1。

	例：输入: nums = [-1,0,3,5,9,12], target = 9
	输出: 4
	解释: 9 出现在 nums 中并且下标为 4
*/
func main() {
	nums := []int{6, 7}
	target := 7
	fmt.Println(index(nums, target))
}

func index(nums []int, target int) int {
	// 获取中值
	m := len(nums) / 2
	if nums[m] < target {
		for k, v := range nums[m:] {
			if v == target {
				return k + m
			}
		}
	} else {
		for j := m; j >= 0; j-- {
			if nums[j] == target {
				return j
			}
		}
	}
	return -1
}
