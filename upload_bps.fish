#!/usr/bin/fish

pushd app-blueprint
cfy blueprint upload -b Python-Prometheus blueprint.yaml
popd

pushd chaos-mesh
cfy blueprint upload -b Chaos-Mesh blueprint.yaml
popd

pushd prometheus-operator
cfy blueprint upload -b Prometheus-Operator blueprint.yaml
popd
