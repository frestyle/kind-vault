#  Kubernetes authentication

##  Configure Kubernetes authentication

```sh

kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh
```

```sh

vault auth enable kubernetes

```

Configure the Kubernetes authentication method to use the service account token, the location of the Kubernetes host, and its certificate.
```sh
vault write auth/kubernetes/config \
        token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

```


![image](https://user-images.githubusercontent.com/1333354/145258859-5ddfda9d-5171-456d-bf3f-f259fee0a4bc.png)
