#!/bin/bash

docker rm grafana
#We use the grafana image that Grafana Labs provides http://docs.grafana.org/installation/docker/
# If you wish to modify the port that Grafana runs on, you can do that here.
sudo docker run -d -p 3000:3000 -e"GF_INSTALL_PLUGINS=grafana-azure-monitor-datasource,grafana-piechart-panel,savantly-heatmap-panel" --net="host" --hostname grafana --name grafana grafana/grafana

