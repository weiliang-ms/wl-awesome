# Job

`Job`创建一个或多个`pod`，并将继续重试`pod`的执行，直到指定数量的`pod`成功终止。
当`pods`成功完成时，`Job`将跟踪成功的完成。
当达到指定的成功完成次数时，`Job`（即作业）即完成。

删除`Job`将清理它创建的`pod`，暂停`Job`将删除其活动pod，直到作业再次恢复。

一个简单的例子是创建一个作业对象，以便可靠地运行一个Pod以完成任务。如果第一个Pod失败或被删除（例如由于节点硬件故障或节点重新启动），作业对象将启动一个新的Pod。

还可以使用作业并行运行多个pod。

## job类型

> 适合以`Job`形式来运行的任务主要有三种

- 1.非并行`Job`:
    - 通常只启动一个`Pod`，除非该`Pod`失败
    - 当`Pod`成功终止时，立即视`Job`为完成状态
    
- 2.具有`确定完成计数`(`completions`)的并行`Job`:
    - `.spec.completions`字段设置为非`0`的正数值
    - `Job`用来代表整个任务，当成功的`Pod`个数达到`.spec.completions`时，`Job`被视为完成

- 3.带`工作队列`(`parallelism`)的并行`Job`:
    - 不设置`spec.completions`，默认值为`.spec.parallelism`
    - 多个`Pod`之间必须相互协调，或者借助外部服务确定每个`Pod`要处理哪个工作条目。
    例如，任一`Pod`都可以从工作队列中取走最多`N`个工作条目
    - 每个`Pod`都可以独立确定是否其它`Pod`都已完成，进而确定`Job`是否完成
    - 当`Job`中任何`Pod`成功终止，不再创建新`Pod`
    - 一旦至少`1`个`Pod`成功完成，并且所有`Pod`都已终止，即可宣告`Job`成功完成
    - 一旦任何`Pod`成功退出，任何其它`Pod`都不应再对此任务执行任何操作或生成任何输出。
    所有`Pod`都应启动退出过程
    
第三种`Job`适用于并行计算？

对于非并行的`Job`，你可以不设置`spec.completions`和`spec.parallelism`。
这两个属性都不设置时，均取默认值`1`，即第一种类型`Job`

对于`确定完成计数`类型的`Job`，你应该设置`.spec.completions`为所需要的完成个数。
你可以设置`.spec.parallelism`，也可以不设置，其默认值为`1`

### 控制并行性

并行性请求（`.spec.parallelism`）可以设置为任何非负整数。如果未设置，则默认为`1`。
如果设置为`0`，则`Job`相当于启动之后便被暂停，直到此值被增加
    
实际并行性（在任意时刻运行状态的`Pods`个数）可能比并行性请求略大或略小，原因如下:

- 对于确定完成计数`Job`，实际上并行执行的`Pods`个数不会超出剩余的完成数。
如果`.spec.parallelism`值较高，会被忽略。
- 对于工作队列`Job`，有任何`Job`成功结束之后，不会有新的`Pod`启动。不过，剩下的`Pods`允许执行完毕
- 如果`Job`控制器没有时间作出反应
- 如果`Job`控制器因为任何原因（例如，缺少`ResourceQuota`或者没有权限）无法创建`Pods`。 
`Pods`个数可能比请求的数目小
- `Job`控制器可能会因为之前同一`Job`中`Pod`失效次数过多而抑制新`Pod`的创建
- 当`Pod`被优雅地关闭时，它需要一段时间才能停止
  
### IndexedJob特性

> 特性状态

`FEATURE STATE: Kubernetes v1.21 [alpha]`

> 开启方式

`API server`与`controller manager`服务通过添加`--feature-gates="IndexedJob=true"`开启`IndexedJob`特性

