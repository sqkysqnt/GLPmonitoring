#!/bin/sh


#Check if Sudo
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

#Update/Upgrade
apt-get update
apt-get upgrade -y
apt-get autoremove
apt-get autoclean


#Install Dependancies
apt-get install -y unzip build-essential libsnmp-dev p7zip-full docker.io make golang apt-transport-https software-properties-common wget



#Add Repos
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 
apt-get update

#Install Grafana
apt-get install -y grafana-enterprise
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service


#Install Prometheus
apt-get install -y prometheus

#Install Loki
cd /tmp
sudo git clone https://github.com/grafana/loki $GOPATH/src/github.com/grafana/loki
cd $GOPATH/src/github.com/grafana/loki
make loki
cd cmd/loki
cp loki /usr/local/bin/loki
cp loki-local-config.yaml /usr/local/bin/config-loki.yml
#nano /etc/systemd/system/loki.service #Add systemd service definition
sudo systemctl start loki
sudo systemctl enable loki