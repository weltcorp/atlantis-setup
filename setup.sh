#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get -qqy update
DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get -yy install apt-transport-https ca-certificates curl software-properties-common pwgen gnupg

# Add Docker GPG signing key
if [ ! -f "/etc/apt/keyrings/docker.gpg" ]; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Add Docker download repository to apt
cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

TG_VERSION="v0.55.1"
TG_SHA256_SUM="61983a96bf06c87c1854a7926f002289207f07f30234a208ed7b12f3c5b8f876"
TG_FILE="/usr/local/sbin/terragrunt"
wget https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64 -O "${TG_FILE}"
echo "${TG_SHA256_SUM}  ${TG_FILE}" | sha256sum -c
chmod 755 "${TG_FILE}"
terragrunt -v

wget https://infracost.io/downloads/v0.10/infracost-linux-amd64.tar.gz -O infracost.tar.gz && \
tar -xvf infracost.tar.gz && \
mv infracost-linux-amd64 "/usr/local/sbin/infracost"

TAC_VERSION="1.17.4" # without v
TAC_SHA256_SUM="06fbd1a3f482d048cd8e177f7e20f7d8d1b6b66190e64d707e55034ccaaafe64"
TAC_FILE="/usr/local/sbin/terragrunt-atlantis-config"
wget "https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TAC_VERSION}/terragrunt-atlantis-config_${TAC_VERSION}_linux_amd64.tar.gz"
echo "${TAC_SHA256_SUM}  terragrunt-atlantis-config_${TAC_VERSION}_linux_amd64.tar.gz" | sha256sum -c
tar xf "terragrunt-atlantis-config_${TAC_VERSION}_linux_amd64.tar.gz"
cp -fv "terragrunt-atlantis-config_${TAC_VERSION}_linux_amd64/terragrunt-atlantis-config_${TAC_VERSION}_linux_amd64" "${TAC_FILE}"
chmod 755 "${TG_FILE}"

docker compose up -d
