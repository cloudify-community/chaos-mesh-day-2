#!/bin/bash -e

tempdir=$(mktemp -d)
export KUBECONFIG="${tempdir}/.config"

pushd "${tempdir}"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl

resource_path=$(ctx download-resource ${manifest})
ctx logger info "Resource downloaded into ${resource_path}"

"${tempdir}"/kubectl config set-cluster cfc --server=${host} --insecure-skip-tls-verify=true
"${tempdir}"/kubectl config set-context cfc --cluster=cfc
"${tempdir}"/kubectl config set-credentials user --token=${token}
"${tempdir}"/kubectl config set-context cfc --user=user
"${tempdir}"/kubectl config use-context cfc

"${tempdir}"/kubectl apply -f ${resource_path}

"${tempdir}"/kubectl config delete-context cfc
"${tempdir}"/kubectl config delete-cluster cfc
"${tempdir}"/kubectl config delete-user user

rm -rf "${tempdir}"
