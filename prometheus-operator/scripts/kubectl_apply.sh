#!/bin/bash -e

tempdir=$(mktemp -d)
export KUBECONFIG="${tempdir}/.config"

pushd "${tempdir}"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl

git clone https://github.com/prometheus-operator/kube-prometheus.git
ctx logger info "Cloned Prometheus Operator repository into ${tempdir}/kube-prometheus"

pushd "${tempdir}/kube-prometheus"

"${tempdir}"/kubectl config set-cluster cfc --server=${host} --insecure-skip-tls-verify=true
"${tempdir}"/kubectl config set-context cfc --cluster=cfc
"${tempdir}"/kubectl config set-credentials user --token=${token}
"${tempdir}"/kubectl config set-context cfc --user=user
"${tempdir}"/kubectl config use-context cfc

# Create the namespace and CRDs, and then wait for them to be availble before creating the remaining resources
"${tempdir}"/kubectl create -f manifests/setup || true

# Wait until the "servicemonitors" CRD is created. The message "No resources found" means success in this context.
until "${tempdir}"/kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done

# Remove the PDBs as they don't seem to work on the EKS verison we are using.
rm manifests/*podDisruptionBudget.yaml

"${tempdir}"/kubectl apply -f manifests/

"${tempdir}"/kubectl config delete-context cfc
"${tempdir}"/kubectl config delete-cluster cfc
"${tempdir}"/kubectl config delete-user user
rm -rf "${tempdir}"
