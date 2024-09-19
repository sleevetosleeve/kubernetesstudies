# Control Plane Taint

Remove the control plane taint
```
kubectl taint node origoc1 node-role.kubernetes.io/control-plane:NoSchedule-
```

Add the control plane taint back in
```
kubectl taint node origoc1 node-role.kubernetes.io/control-plane:NoSchedule
```

