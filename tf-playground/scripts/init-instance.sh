#!/bin/bash
# ec2 initialization setup
# Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20
# user_data already launched as root (no need sudo -s)

# Must disable swappiness

echo 'Start ...'
apt-get update -y
# docker
modprobe kvm
apt-get remove docker docker-engine docker.io -y
apt install docker.io -y
apt install docker-compose -y
apt install jq -y
# git
git clone https://github.com/raphael-chir/SQLstreamingtoNoSQL.git
# setup demo
cd SQLstreamingtoNoSQL
docker-compose up -d

timeout=360
interval=3

while ((timeout > 0)); do
  sleep $interval
  resp=$(curl -I http://localhost:8083/connectors 2>/dev/null | head -n 1 | cut -d$' ' -f2)
  if [ $resp -eq 200 ];
  then
    # Create connectors when api is ready
    curl -X POST -H "Content-Type: application/json" -d @SqlServerConnector.json http://localhost:8083/connectors
    curl -X POST -H "Content-Type: application/json" -d @CouchbaseSinkConnector.json http://localhost:8083/connectors
    break
  fi
  ((timeout -= interval))
done

cp deployksql.sh /home/ubuntu
cp ksqldb.sql /home/ubuntu
echo ". ~/deployksql.sh" >> /home/ubuntu/.bashrc
chown -R ubuntu.ubuntu /home/ubuntu/
chmod 755 /home/ubuntu/deployksql.sh

# Launch manually this command deploy_ksql ksqldb.sql to perform the demo