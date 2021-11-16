# Vault Installation to kind via Helm

## Setup kind cluster 

./kind/cluster.sh 

## Setup dashboard

```sh
./kind/kubernetes-dashboard.sh
```

## Install the Consul Helm chart

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
```

```sh
helm repo update
```

```sh
helm install consul hashicorp/consul --values consul/helm-consul-values.yml
```

wait for consult to be ready


## Install the Vault Helm chart

Install the latest version of the Vault Helm chart with parameters helm-vault-values.yml applied.


```sh
helm install vault hashicorp/vault --values vault/helm-vault-values.yml
```

Retrieve the status of Vault on the vault-0 pod.

```sh
kubectl exec vault-0 -- vault status
```

port forward all requests made to http://localhost:8200 to the vault-0 pod on port 8200.

```sh
kubectl port-forward vault-0 8200:8200
```
### Initialize and unseal Vault


> The operator init command generates a master key that it disassembles into key shares -key-shares=1 and then sets the number of key shares required to unseal Vault -key-threshold=1. These key shares are written to the output as unseal keys in JSON format -format=json. Here the output is redirected to a file named cluster-keys.json.



```sh
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
```

```sh
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")

kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY
```



```sh
# Display the root token found in cluster-keys.json.
cat cluster-keys.json | jq -r ".root_token"
``` 

```sh

kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh

vault login

vault secrets enable -path=secret kv-v2

```

Create a secret at path secret/webapp/config with a username and password.

```sh
 
vault kv put secret/webapp/config username="static-user" password="static-password"

```

Verify that the secret is defined at the path secret/webapp/config.

```sh

vault kv get secret/webapp/config

```


[Kubernetes Authentication](Kubernetes%20Authentication.md)


## References 

- [Vault Installation to Minikube via Helm](https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes)

- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

- https://github.com/kelseyhightower/serverless-vault-with-cloud-run
- [Google KMS](https://www.vaultproject.io/docs/secrets/gcpkms)
- [Identity](https://www.vaultproject.io/docs/concepts/identity)
