# Enroll
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-9.1.4-windows-x86_64.zip -OutFile elastic-agent-9.1.4-windows-x86_64.zip
Expand-Archive .\elastic-agent-9.1.4-windows-x86_64.zip -DestinationPath .
cd elastic-agent-9.1.4-windows-x86_64
.\elastic-agent.exe install --url=https://fleet-server:8220 --enrollment-token=[YOUR ENROLLMENT TOKEN]
