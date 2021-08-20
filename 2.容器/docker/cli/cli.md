<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [docker源码阅读笔记](#docker%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB%E7%AC%94%E8%AE%B0)
  - [命令行](#%E5%91%BD%E4%BB%A4%E8%A1%8C)
    - [cobra实现](#cobra%E5%AE%9E%E7%8E%B0)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# docker源码阅读笔记

## 命令行

基于[cobra](https://github.com/spf13/cobra)开发

### cobra实现

> `operationSubCommands`方法

**解析命令行入参，返回参数数组：**

若命令存在（未被移除 && 非隐藏类型命令）且不含子命令，依次放入数组中

    func operationSubCommands(cmd *cobra.Command) []*cobra.Command {
    	var cmds []*cobra.Command
    	for _, sub := range cmd.Commands() {
    		if sub.IsAvailableCommand() && !sub.HasSubCommands() {
    			cmds = append(cmds, sub)
    		}
    	}
    	return cmds
    }
    
> `hasSubCommands`方法

**判断`docker`命令是否含有子命令或参数**

调用`operationSubCommands`对返回的数组进行容量判断，长度大于0返回true（即含有子命令）

如`docker ps`不含有子命令，而`docker save`含有子命令（-o）

    func hasSubCommands(cmd *cobra.Command) bool {
    	return len(operationSubCommands(cmd)) > 0
    }
    
> `FlagErrorFunc`方法

**判断`docker`命令合法性：**

    func FlagErrorFunc(cmd *cobra.Command, err error) error {
    	if err == nil {
    		return nil
    	}
    
    	usage := ""
    	if cmd.HasSubCommands() {
    		usage = "\n\n" + cmd.UsageString()
    	}
    	return StatusError{
    		Status:     fmt.Sprintf("%s\nSee '%s --help'.%s", err, cmd.CommandPath(), usage),
    		StatusCode: 125,
    	}
    }