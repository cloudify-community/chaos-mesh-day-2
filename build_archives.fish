#!/usr/bin/fish

rm "archives/*.zip"
zip -r archives/app-blueprint.zip app-blueprint/
zip -r archives/chaos-mesh.zip chaos-mesh/
zip -r archives/prometheus-operator.zip prometheus-operator/
