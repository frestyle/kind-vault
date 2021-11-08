#  Kubernetes authentication

##  Configure Kubernetes authentication

```sh

kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh
```

```sh

vault auth enable kubernetes

```