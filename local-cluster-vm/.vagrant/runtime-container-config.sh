#!/bin/bash

echo "Configure container runtime deamon by EOF (End Of File)..."
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo "Create docker service for systemd..."
mkdir -p /etc/systemd/system/docker.service.d

echo "reload daemon..."
systemctl daemon-reload

echo "Restart docker..."
systemctl restart docker

echo "Check cgroup in docker info..."
docker info | grep -i cgroup