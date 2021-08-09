#!/usr/bin/env bash

set -e

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    awscli \
    snapd \
    docker-ce \
    docker-ce-cli \
    containerd.io

snap install amazon-ssm-agent --classic

curl -s \
    -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose

curl -s \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose

chmod +x /usr/local/bin/docker-compose

mkdir -p /etc/sessionstack/ && mv /tmp/files/* /tmp/files/.env /etc/sessionstack/

cat /etc/sessionstack/keyfile.json | docker login -u _json_key --password-stdin https://eu.gcr.io

cd /etc/sessionstack

docker-compose pull
