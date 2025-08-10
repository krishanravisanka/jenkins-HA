#### #!/bin/bash
# set -e

# # Install dependencies
# sudo apt-get update -y
# sudo apt-get install -y openjdk-17-jdk curl gnupg

# # Add Jenkins repo & key
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
#     /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
#     https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
#     /etc/apt/sources.list.d/jenkins.list > /dev/null

# # Install Jenkins
# sudo apt-get update -y
# sudo apt-get install -y jenkins

# # Create bootstrap dirs
# sudo mkdir -p /var/lib/jenkins/init.groovy.d
# sudo mkdir -p /var/lib/jenkins/jcasc
# sudo chown -R jenkins:jenkins /var/lib/jenkins

# # Enable & start
# sudo systemctl enable jenkins

#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Clean apt and avoid CNF hook issues
sudo rm -rf /var/lib/apt/lists/*
sudo mkdir -p /var/lib/apt/lists/partial
sudo sed -i 's@/usr/lib/cnf-update-db@/bin/true@g' /etc/apt/apt.conf.d/50command-not-found || true

sudo apt-get update -o Acquire::Retries=3 -o Acquire::http::No-Cache=true
sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg unzip

# Java 17
sudo apt-get install -y --no-install-recommends openjdk-17-jdk

# Jenkins repo + key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

sudo apt-get update -o Acquire::Retries=3 -o Acquire::http::No-Cache=true
sudo apt-get install -y --no-install-recommends jenkins

# Pre-create dirs; proper ownership
sudo mkdir -p /var/lib/jenkins/init.groovy.d /var/lib/jenkins/jcasc
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Optional: preinstall a few plugins (keeps first boot fast)
if command -v jenkins-plugin-cli >/dev/null 2>&1; then
  sudo -u jenkins jenkins-plugin-cli \
    --plugins git workflow-aggregator configuration-as-code aws-credentials job-dsl
fi

sudo systemctl enable jenkins

