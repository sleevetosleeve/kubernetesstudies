# Cluster Setup

There are many considerations that need to be taken and choices that need to be made when setting up a kubernetes cluster. This guide presents one set of solutions for these issues, and some of the reasoning behind them. However other choices and solutions are just as valid.

The first such choice is the kind or flavor of kubernetes you wish to run. Here we choose to configure a cluster using [`kubeadmn`](https://kubernetes.io/docs/reference/setup-tools/kubeadm/), a tool specifically developed for assisting in setting up a kubernetes cluster. In fact we will be more or less following the guide [Bootstrapping clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/).

The reasoning for this is that using `kubeadm` for this task is not easy, and the reader will thus gain much knowledge and experience of many of the core concepts in kubernetes. The other reason is that this represents 15% to 25% of the CKA exam.

A simpler way to get access to a kubernetes cluster would be to run minikube, docker desktop kubernetes or a hosted cluster on a cloud service. And a much harder way would be to follow the guide [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

Note also that this guide will purposely configure that next latest version of kubernetes. This is done such that we can practice upgrading a cluster, which is one of most important tasks of a kubernetes administrator.

## Nodes

At the most basic level a kubernetes cluster is a collections of computers that work together in an automated way to run containers. These computers are referred to as nodes. The nodes are generally grouped in two groups. 

* Control plane nodes administer the activities of the cluster. Normally these are configured not to execute any of the actual work containers.
* Worker nodes are in principal all the nodes that do not run any administration containers.

This guide will help you set up virtual machines you can use as your nodes. The absolute minimum you will need to be able to set aside for the vms is in total 4 CPUs and 4GB ram.

But actually any machine that meets the requirements stated here: [Before you begin](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin), can be added to the cluster. Note however that one of the steps in the installation process is to deactivate swap on the machine. So if you use swap on a machine to increase performance, that machine might not be a good candidate.

Kubernetes 1.30 actually has partial compatibility with systems using swap, and hopefully swap will not be an issue in a release or two.

It is also worth noting that windows machines can be used as worker nodes. This guide wil not be covering that however. See [Windows in Kubernetes](https://kubernetes.io/docs/concepts/windows/) fro more information. 

## Naming

Before we get to setting up the virtual machines, let us take a moment to discuss the naming on said nodes and cluster. In an enterprise environment you will probably have a couple of clusters names as `prod`, `staging`, `test` and so on. But in a study situation you will probably be using a few clusters to test various aspects of kubernetes. And you might end up calling them `test`, `test01`, `test02` and so on. But if we also take the names of the nodes into consideration the naming might go slightly overboard with names like `test1c1`, `test1w1`, `test2c1`, `test2c2` and `test2w1`. It might thus a good idea to avoid numbers in the primary name of the cluster. One god idea could be to call it according to what you are testing, like `ingress`, `metrics` or `servicemesh`. Alternatively something neutral like a color, planet or city.

Another thing worth considering is the use of a dns name for accessing the cluster. 

![images/cluster01.png](images/cluster01.png)

The above diagram of a simple cluster named `origo` shows how the cluster is accessed from a workstation. Since the setup is so simple one could argue that the simplest way would be to just connect to the control plane node.

![images/cluster02.png](images/cluster02.png)

A better solution would be to utilize a dns name that pointed to the control plane node.

![images/cluster03.png](images/cluster03.png)  ![images/cluster04.png](images/cluster04.png)

The benefit of this setup becomes apparent with slightly bigger clusters. Where we can utilize the extra abstraction level to increase availability.

