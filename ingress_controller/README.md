# Ingress Controller

## Ingress-NGINX
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Install ingress-nginx as a DaemonSet and as the cluster-wide default ingress controller.
```
helm install nginxingress ingress-nginx/ingress-nginx \
  --set controller.kind=DaemonSet \
  --set controller.ingressClassResource.default=true
```
Get the ingress controllers external ip
```
$ kubectl get service nginxingress-ingress-nginx-controller
NAME                                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
nginxingress-ingress-nginx-controller   LoadBalancer   10.103.206.218   192.168.1.16   80:32537/TCP,443:30264/TCP   27m
```

Test
```
kubectl run webthing --image=httpd
kubectl expose pod/webthing --name=webthing-service --port=80
kubectl apply -f webthing-ingress.yaml
curl -H "Host: webthing.io" 192.168.1.16 # outputs <html><body><h1>It works!</h1></body></html>
kubectl delete -f webthing-ingress.yaml
kubectl delete pod/webthing service/webthing-service
```