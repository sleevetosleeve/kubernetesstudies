# Load Balancer

This document will guide you through installing Metal LB on your cluster. A Load Balancer is a vital part of a cluster.

## IPs

For the load balancer to be able to load balance it needs some ip-addresses to distribute to the kubernetes services. This can be an issue on a home networks that are using the router provided by the ISP. In these cases you will have to ensure the DHCP of the router does not distribute the same ip-addresses that you want the load balancer to distribute. How you achieve this is not covered by this guide, but it is vital that it is done. Otherwise you might risk having two entities on you network who claim the have the same ip-address. 

In my case I dug deep into my ISP's configuration and got it to only assign ip's between `192.168.1.32-192.168.1.255`, so I will be using `192.168.1.16-192.168.1.31` for the load balancer and `192.168.1.2-192.168.1.15` for something else down the line. 

You need to figure out what ips you want to give your load balance. In this guide I will show you how to configure MetalLB with any combination of single  or multiple ip-ranges and/or single or multiple specific ip-addresses.

## Namespace

We will need to prepare a namespace to run MetalLb in

```
# metallb-system-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: metallb-system
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
```
The yaml file above initiates the namespace `metallb-system` and gives it elevated privileges as this is required ny MetalLB to interact with the node's network configuration. This file is in this folder and can be applied using this command:
```
kubectl apply -f ../metallb-system-namespace.yaml
```
## kube-proxy

MetalLB requires the `strictARP` configuration of kube-proxy to be turned on. The following command will achieve this:
```
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```
And as long as we are fiddling with kube-proxy we will use this opportunity to switch kube-proxy to the IPVS network mode. Without activating this mode kube-proxy falls back to using iptables, a much more inferior teleology for routing. And as we just installed the vms using modern operating systems. so we know they have IPVS functionality, so there is no reason not to use it. Activate IPVS using this command.
```
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e 's/mode:.*false/mode: "ipvs"/' | \
kubectl apply -f - -n kube-system
```
After updating the kube-proxy's configmap we need to kill the kube-proxy pods so they restart using the new configmap. Or use the builtin `rollout` command:
```
kubectl rollout restart ds kube-proxy -n kube-system
```
## Helm

Navigate to [https://helm.sh/](https://helm.sh/) and install helm according to the latest method and your workstation.

## MetalLB

Start by adding the MetalLB repository to your helm repositories:
```
helm repo add metallb https://metallb.github.io/metallb
```
Now we will install MetalLB into the namespace we made earlier:
```
helm install -n metallb-system metallb metallb/metallb
```
## Configuration
We start by defining an ip-address pool. Take a look at the `IPAddressPool.yaml` file in this folder and modify it according to the comments therein.
```
# IPAddressPool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: origo-pool # can be changed to anything you like
  namespace: metallb-system
spec:
  addresses:
  # For each single ip-address you want to add to the pool,
  # uncomment a copy of the below line and replace "1.2.3.4" 
  # with the ip-address.
  # - 1.2.3.4/32
  # For each range of ip-address you want to add to the pool,
  # uncomment a copy of the below line and replace "5.6.7.8" 
  # with the start of the ip-range and "5.6.7.18" with the 
  # end of the ip-range.
  # - 5.6.7.8-5.6.7.18
```
After you have modified  `IPAddressPool.yaml` according to your needs, you can apply it using this command:
```
kubectl apply -f IPAddressPool.yaml
```
And now we can apply the `L2Advertisement.yaml`:
```
kubectl apply -f L2Advertisement.yaml
```
And we are done:
## Test
Launch a simple web pod:
```
kubectl run webthing --image=httpd
```
Expose it with load balancing:
```
kubectl expose pod/webthing --port=80 --type=LoadBalancer
```
Get the service:
```
kubectl get services webthing
```
And you can see that the EXTERNAL-IP is one of the ip-addresses of the address pool:
```
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
webthing   LoadBalancer   10.100.14.86   5.6.7.8        80:31123/TCP   25h
```
Now you can curl the ip and get a response:
```
loadbalancer$ curl [the external ip of your service]
<html><body><h1>It works!</h1></body></html>
```
You can also visit the ip in a browser and ger the same answer.

To cleanup after the test run
```
kubectl delete pod/webthing service/webthing
```

