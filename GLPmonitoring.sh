#!/bin/sh

#---------------------------------
#Check if Sudo
#---------------------------------
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

cp config/snmp.yml /usr/local/bin/snmp.yml
cp services/snmpexporter.service /etc/systemd/system/snmpexporter.service
cp config/loki.yml /usr/local/bin/config-loki.yml
cp services/loki.service /etc/systemd/system/loki.service
cp config/promtail.yml /usr/local/bin/config-promtail.yml
cp services/promtail.service /etc/systemd/system/promtail.service

#---------------------------------
#Update/Upgrade
#---------------------------------
apt-get update
apt-get upgrade -y
apt-get autoremove
apt-get autoclean

#---------------------------------
#Install Dependancies
#---------------------------------
apt-get install -y unzip build-essential libsnmp-dev p7zip-full docker.io make golang apt-transport-https software-properties-common wget



#---------------------------------
#Add Repos
#---------------------------------
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 
curl -s https://golift.io/gpgkey | sudo apt-key add -
echo deb https://dl.bintray.com/golift/ubuntu bionic main | sudo tee /etc/apt/sources.list.d/golift.list
apt-get update

#---------------------------------
#Install Grafana
#---------------------------------
apt-get install -y grafana-enterprise
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service

#---------------------------------
#Install Prometheus
#---------------------------------
apt-get install -y prometheus

#---------------------------------
#Install Loki
#---------------------------------
cd /tmp
sudo git clone https://github.com/grafana/loki $GOPATH/src/github.com/grafana/loki
cd $GOPATH/src/github.com/grafana/loki
make loki
cd cmd/loki
cp loki /usr/local/bin/loki

systemctl start loki
systemctl enable loki

#---------------------------------
#Install Promtail
#---------------------------------
cd /tmp
curl -fSL -o promtail.gz "https://github.com/grafana/loki/releases/download/v1.5.0/promtail-linux-amd64.zip"
gunzip promtail.gz
cp promtail /usr/local/bin/promtail
cd /usr/local/bin
chmod a+x promtail

systemctl start promtail
systemctl enable promtail

#---------------------------------
#Install snmp_exporter
#---------------------------------
cd /tmp
sudo wget https://github.com/prometheus/snmp_exporter/releases/download/v0.18.0/snmp_exporter-0.18.0.linux-amd64.tar.gz
sudo tar -xvf snmp_exporter-0.18.0.linux-amd64.tar.gz
cd snmp_exporter-0.18.0.linux-amd64/
sudo mv snmp_exporter /usr/local/bin/
chmod a+x snmp_exporter
cd /usr/local/bin

sudo systemctl start snmpexporter
sudo systemctl enable snmpexporter

#---------------------------------
# Install Unifi Poller
#---------------------------------
sudo apt-get install -y unifi-poller