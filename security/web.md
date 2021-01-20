<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [不安全的Http方法](#%E4%B8%8D%E5%AE%89%E5%85%A8%E7%9A%84http%E6%96%B9%E6%B3%95)
- [Host攻击](#host%E6%94%BB%E5%87%BB)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**nginx处理的优势：由于nginx高吞吐性，减轻后端服务的压力**

## 不安全的Http方法

> nginx维护白名单

lua样例

	-- 检测方法合法性
	reques_method = ngx.var.request_method
	function method_check(method)
	   record_debug_log(method)
	   if tableFind(method,valid_methods) == false
	      then
	        record_attack_log("BadHttpMethod")
	        ngx.exit(405)
	   end
	end

## Host攻击

> nginx维护白名单

lua样例

	-- 校验Host合法性
	function host_check(host)
	    if tableFind(host,valid_hosts) == false
	      then
	        record_attack_log("BadHost")
	        ngx.exit(444)
	    end
	end

原生方式

	server{
	...
	if ($http_host != ""){
		return 444;
	}
	...
	}	

	