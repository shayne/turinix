kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
kubectl create -f pvc.yaml
kubectl create -f ingress.yaml
