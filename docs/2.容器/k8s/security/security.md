# 云原生安全

[k8s安全](https://kubernetes.io/zh/docs/concepts/security/overview/)

本概述定义了一个模型，用于在`Cloud Native`安全性上下文中考虑`Kubernetes`安全性。

## 云原生安全的4个`C`

你可以分层去考虑安全性，云原生安全的4个C分别是云（`Cloud`）、集群（`Cluster`）、容器（`Container`）和代码（`Code`）

![](images/4c.png)

### 4C中的云

在许多方面，云（或者位于同一位置的服务器，或者是公司数据中心）是`Kubernetes`集群中的可信计算基础。
如果云层容易受到攻击（或者被配置成了易受攻击的方式），就不能保证在此基础之上构建的组件是安全的。
每个云提供商都会提出安全建议，以在其环境中安全地运行工作负载。

> 云提供商安全性

下面是一些比较流行的云提供商的安全性文档链接：

- [Alibaba Cloud](https://www.alibabacloud.com/trust-center)
- [Amazon Web Services](https://aws.amazon.com/security/)

> 基础设施安全

- 通过网络访问`API`服务（控制平面）
    - 所有对`Kubernetes`控制平面的访问不允许在`Internet`上公开，
    同时应由网络访问控制列表控制，该列表包含管理集群所需的`IP`地址集
- 通过网络访问`Node`（节点）
    - 节点应配置为仅能从控制平面上通过指定端口来接受（通过网络访问控制列表）连接，
    以及接受`NodePort`和`LoadBalancer`类型的`Kubernetes`服务连接。
    如果可能的话，这些节点不应完全暴露在公共互联网上。
- `Kubernetes`访问云提供商的`API`
    - 每个云提供商都需要向`Kubernetes`控制平面和节点授予不同的权限集。
    为集群提供云提供商访问权限时，最好遵循对需要管理的资源的最小特权原则。
- 访问`etcd`
    - 对`etcd`（`Kubernetes`的数据存储）的访问应仅限于控制平面。根据配置情况，你应该尝试通过`TLS`来使用`etcd`
- `etcd`加密
    - 在所有可能的情况下，最好对所有驱动器进行静态数据加密，
    但是由于`etcd`拥有整个集群的状态（包括机密信息），因此其磁盘更应该进行静态数据加密。
    
### 集群

保护`Kubernetes`有两个方面需要注意：

- 保护可配置的集群组件
- 保护在集群中运行的应用程序

> 控制对`Kubernetes API`的访问 

因为`Kubernetes`是完全通过`API`驱动的，所以，控制和限制谁可以通过`API`访问集群，
以及允许这些访问者执行什么样的`API`动作，就成为了安全控制的第一道防线。

> 为所有`API`交互使用传输层安全 （TLS）

`Kubernetes`期望集群中所有的`API`通信在默认情况下都使用`TLS`加密，大多数安装方法也允许创建所需的证书并且分发到集群组件中。
请注意，某些组件和安装方法可能使用`HTTP`来访问本地端口， 管理员应该熟悉每个组件的设置，以识别潜在的不安全的流量

> `API`认证

安装集群时，选择一个`API`服务器的身份验证机制，去使用与之匹配的公共访问模式。
例如，小型的单用户集群可能希望使用简单的证书或静态承载令牌方法。
更大的集群则可能希望整合现有的、`OIDC`、`LDAP`等允许用户分组的服务器。

所有`API`客户端都必须经过身份验证，即使它是基础设施的一部分，比如节点、代理、调度程序和卷插件。
这些客户端通常使用服务帐户或`X509`客户端证书，并在集群启动时自动创建或是作为集群安装的一部分进行设置

> `API`授权

一旦通过身份认证，每个`API`的调用都将通过鉴权检查。
`Kubernetes`集成基于角色的访问控制（RBAC）组件，将传入的用户或组与一组绑定到角色的权限匹配。
这些权限将动作（`get，create，delete`）和资源（`pod，service, node`）在命名空间或者集群范围内结合起来， 
根据客户可能希望执行的操作，提供了一组提供合理的违约责任分离的外包角色。
建议你将节点和`RBAC`一起作为授权者，再与`NodeRestriction`准入插件结合使用。

与身份验证一样，简单而广泛的角色可能适合于较小的集群，但是随着更多的用户与集群交互，可能需要将团队划分成有更多角色限制的单独的命名空间。
就鉴权而言，理解怎么样更新一个对象可能导致在其它地方的发生什么样的行为是非常重要的。
例如，用户可能不能直接创建`Pod`，但允许他们通过创建一个`Deployment`来创建这些`Pod`， 
这将让他们间接创建这些`Pod`。同样地，从`API`删除一个节点将导致调度到这些节点上的`Pod`被中止，
并在其他节点上重新创建。原生的角色设计代表了灵活性和常见用例之间的平衡，但有限制的角色应该仔细审查，
以防止意外升级。如果外包角色不满足你的需求，则可以为用例指定特定的角色

> 控制对`Kubelet`的访问 

`Kubelet`公开`HTTPS`端点，这些端点授予节点和容器强大的控制权。
默认情况下，`Kubelet`允许对此`API`进行未经身份验证的访问。
生产级别的集群应启用`Kubelet`身份验证和授权。

**Kubelet 身份认证**

- 要禁用匿名访问并向未经身份认证的请求发送`401 Unauthorized`响应，请执行以下操作：
    - 带`--anonymous-auth=false`标志启动`kubelet`
- 要对`kubelet`的`HTTPS`端点启用`X509`客户端证书认证:
    - 带`--client-ca-file`标志启动`kubelet`，提供一个`CA`证书包以供验证客户端证书
    - 带`--kubelet-client-certificate`和`--kubelet-client-key`标志启动`apiserver`
- 要启用`API`持有者令牌（包括服务帐户令牌）以对`kubelet`的`HTTPS`端点进行身份验证，请执行以下操作：
    - 确保在`API`服务器中启用了`authentication.k8s.io/v1beta1 API`组
    - 带`--authentication-token-webhook`和`--kubeconfig`标志启动`kubelet`
    - `kubelet`调用已配置的`API`服务器上的`TokenReview API`，以根据持有者令牌确定用户信息

> 集群中的组件（自定义应用）安全性

- [RBAC 授权(访问 Kubernetes API)](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/)
- [认证方式](https://kubernetes.io/zh/docs/concepts/security/controlling-access/)
- [应用程序 Secret 管理](https://kubernetes.io/zh/docs/concepts/configuration/secret/)
- [etcd静态数据加密](https://kubernetes.io/zh/docs/tasks/administer-cluster/encrypt-data/) 
- [Pod安全策略](https://kubernetes.io/zh/docs/concepts/policy/pod-security-policy/)
- [服务质量（和集群资源管理）](https://kubernetes.io/zh/docs/tasks/configure-pod-container/quality-service-pod/)
- [网络策略](https://kubernetes.io/zh/docs/concepts/services-networking/network-policies/)
- [Kubernetes Ingress 的 TLS 支持](https://kubernetes.io/zh/docs/concepts/services-networking/ingress/#tls)








