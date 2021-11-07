#!/bin/bash
export METALLB_V=${1:-0.9.5}

export KIND_CLUSTER_NAME=vault-cluster


# create registry container unless it already exists
KIND_CLUSTER_NETWORK=kind
reg_name='kind-registry'
reg_port='5000'


# console colors
export RED='\033[0;31m'
export Green='\033[0;32m'
export Yellow='\033[1;33m'
export NC='\033[0m' # No Color


# create a cluster with the local registry enabled in containerd
kind create cluster --name "${KIND_CLUSTER_NAME}" --config=cluster-config-registry.yaml

# connect the registry to the cluster network
# (the network may already be connected)
docker network connect "$KIND_CLUSTER_NETWORK" "${reg_name}" || true


# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF




echo -e "${Yellow}****************************************  Setup Metallb ${NC}"


kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v$METALLB_V/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v$METALLB_V/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

kubectl apply  -f metallb-system.yaml
