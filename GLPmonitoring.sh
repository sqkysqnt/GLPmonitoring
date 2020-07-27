#!/bin/sh
clear

#---------------------------------
#Check if Sudo
#---------------------------------
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo "Copying files..."
cp config/snmp.yml /usr/local/bin/snmp.yml
cp services/snmpexporter.service /etc/systemd/system/snmpexporter.service
cp config/loki.yml /usr/local/bin/config-loki.yml
cp services/loki.service /etc/systemd/system/loki.service
cp config/promtail.yml /usr/local/bin/config-promtail.yml
cp services/promtail.service /etc/systemd/system/promtail.service
cp config/snmp.yml /usr/local/bin/snmp.yml
cp services/snmpexporter.service /etc/systemd/system/snmpexporter.service
cp config/blackbox.yml /usr/local/bin/blackbox.yml
cp services/blackbox.service /etc/systemd/system/blackbox.service
clear

#---------------------------------
#Update/Upgrade
#---------------------------------
echo "Updating and upgrading system..."
apt-get update
apt-get upgrade -y
apt-get autoremove
apt-get autoclean
clear

#---------------------------------
#Install Dependancies
#---------------------------------
echo "Installing dependancies..."
apt-get install -y unzip build-essential libsnmp-dev p7zip-full docker.io make golang apt-transport-https software-properties-common wget
clear

#---------------------------------
#Add Repos
#---------------------------------
echo "Adding necessary repositories..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 
curl -s https://golift.io/gpgkey | sudo apt-key add -
echo deb https://dl.bintray.com/golift/ubuntu bionic main | sudo tee /etc/apt/sources.list.d/golift.list
apt-get update
clear

#---------------------------------
#Install Grafana
#---------------------------------
echo "Installing Grafana..."
apt-get install -y grafana-enterprise
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
clear

#---------------------------------
#Install Prometheus
#---------------------------------
echo "Installing Prometheus..."
apt-get install -y prometheus
clear

#---------------------------------
#Install Loki
#---------------------------------
echo "Installing Loki..."
cd /tmp
sudo git clone https://github.com/grafana/loki $GOPATH/src/github.com/grafana/loki
cd $GOPATH/src/github.com/grafana/loki
make loki
cd cmd/loki
cp loki /usr/local/bin/loki

systemctl start loki
systemctl enable loki
clear

#---------------------------------
#Install Promtail
#---------------------------------
echo "Installing Promtail..."
cd /tmp
curl -fSL -o promtail.gz "https://github.com/grafana/loki/releases/download/v1.5.0/promtail-linux-amd64.zip"
gunzip promtail.gz
cp promtail /usr/local/bin/promtail
cd /usr/local/bin
chmod a+x promtail

systemctl start promtail
systemctl enable promtail
clear

#---------------------------------
#Install snmp_exporter
#---------------------------------
echo "Installing SNMP Exporter..."
cd /tmp
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.18.0/snmp_exporter-0.18.0.linux-amd64.tar.gz
tar -xvf snmp_exporter-0.18.0.linux-amd64.tar.gz
cd snmp_exporter-0.18.0.linux-amd64/
sudo mv snmp_exporter /usr/local/bin/
chmod a+x snmp_exporter
cd /usr/local/bin

systemctl start snmpexporter
systemctl enable snmpexporter
clear

#---------------------------------
# Install Unifi Poller
#---------------------------------
echo "Installing Unifi-Poller..."
apt-get install -y unifi-poller
clear

#---------------------------------
# Install Blackbox Exporter
#---------------------------------
echo "Installing Blackbox Exporter..."
cd /tmp
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.17.0/blackbox_exporter-0.17.0.linux-amd64.tar.gz
tar -xvf blackbox_exporter-0.17.0.linux-amd64.tar.gz
cd blackbox_exporter-0.17.0.linux-amd64/
sudo mv blackbox_exporter /usr/local/bin/
chmod a+x blackbox_exporter
cd /usr/local/bin

systemctl start blackboxexporter
systemctl enable blackboxexporter
clear

#---------------------------------
# Install Cockpit
#---------------------------------
echo "Installing Cockpit..."
apt-get install cockpit
clear

#---------------------------------
# Install Grafana plugins
#---------------------------------
echo "Installing Grafana Plugins..."
grafana-cli plugins install grafana-piechart-panel
grafana-cli plugins install grafana-image-renderer
clear

#---------------------------------
# All configs in the same place
#---------------------------------
echo "Linking configs..."
mkdir /etc/GLPmonitoring
ln -s /usr/local/bin/blackbox.yml /etc/GLPmonitoring/blackbox.yml
ln -s /usr/local/bin/config-loki.yml /etc/GLPmonitoring/loki.yml
ln -s /usr/local/bin/config-promtail.yml /etc/GLPmonitoring/promtail.yml
ln -s /usr/local/bin/snmp.yml /etc/GLPmonitoring/snmp.yml
ln -s /etc/prometheus/prometheus.yml /etc/GLPmonitoring/prometheus.yml
ln -s /etc/unifi-poller/up.conf /etc/GLPmonitoring/up.conf
clear
