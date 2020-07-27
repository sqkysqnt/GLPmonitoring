# GLPmonitoring

#---------------------------------
# URLs
#---------------------------------
# http://localhost:3000 #Grafana - Main visulization tool, single pane of glass
# http://localhost:9090 #Prometheus - Collects metrics
# http://localhost:3100/metrics #Loki - Indexes Logs
# http://localhost:9080 #Promtail - Collects Logs
# http://localhost:9116/ #SNMP Exporter - Collects metrics from SNMP clients and sends them to Prometheus
# http://localhost:9115/ #Blackbox Exporter - Queries webhosts and sends metrics to Prometheus
# http://localhost:7777/ #Cockpit - Server management tool

#---------------------------------
# Get started
#---------------------------------
# /etc/GLPmonitoring/ contains all the config files
# Setup email notifications and server domain for links and alerting to work
# Add unifi information to up.conf to begin polling unifi
# Add SNMP information for any non unifi networking equipment
# Use Blackbox Exporter for any icmp/tcp/dns/ssh monitoring.
# Install node_exporter on any hosts for realtime dynamic monitoring
#   Linux: https://devopscube.com/monitor-linux-servers-prometheus-node-exporter/
#   Windows: https://medium.com/@facundofarias/setting-up-a-prometheus-exporter-on-windows-b3e45f1235a5
# Forward syslogs to localhost:1514 to be indexed by Loki
# Create dashboards in Grafana!
