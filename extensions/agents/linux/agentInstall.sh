# Enrollment-token is coppied from fleet-ui
curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-9.1.4-linux-x86_64.tar.gz
tar xzvf elastic-agent-9.1.4-linux-x86_64.tar.gz
cd elastic-agent-9.1.4-linux-x86_64
sudo ./elastic-agent install --url=https://fleet-server:8220 --enrollment-token=[YOUR ENROLLMENT TOKEN]
