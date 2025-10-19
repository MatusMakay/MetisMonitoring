#!/bin/bash
set -e

bash -c '
  # --- Check mandatory environment variables ---
  if [ -z "${ELASTIC_PASSWORD}" ]; then
    echo "ERROR: Set the ELASTIC_PASSWORD environment variable in the .env file"
    exit 1
  elif [ -z "${KIBANA_PASSWORD}" ]; then
    echo "ERROR: Set the KIBANA_PASSWORD environment variable in the .env file"
    exit 1
  fi

  if [ -z "${ELASTIC_SERVER_HOST}" ]; then
    echo "ERROR: Set the ELASTIC_SERVER_HOST environment variable in the .env file"
    exit 1
  elif [ -z "${KIBANA_SERVER_HOST}" ]; then
    echo "ERROR: Set the KIBANA_SERVER_HOST environment variable in the .env file"
    exit 1
  fi

  mkdir -p config/certs

  # --- Generate CA only if missing ---
  if [ ! -f config/certs/ca/ca.crt ] || [ ! -f config/certs/ca/ca.key ]; then
    echo "INFO: Creating CA"
    bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip
    unzip -qo config/certs/ca.zip -d config/certs
  else
    echo "INFO: CA already exists, skipping generation"
  fi

  # --- Generate component certs only if missing ---
  if [ ! -f config/certs/es01/es01.crt ] || [ ! -f config/certs/kibana/kibana.crt ] || [ ! -f config/certs/fleet-server/fleet-server.crt ]; then
    echo "INFO: Creating certs for ELK components"
    cat > config/certs/instances.yml <<EOF
instances:
  - name: es01
    dns:
      - es01
      - localhost
      - siem-ng.fiitacademy.fiit.stuba.sk
    ip:
      - 10.0.130.2
  - name: kibana
    dns:
      - kibana
      - localhost
      - siem-ng.fiitacademy.fiit.stuba.sk
    ip:
      - 10.0.130.2
  - name: fleet-server
    dns:
      - fleet-server
      - localhost
      - siem-ng.fiitacademy.fiit.stuba.sk
    ip:
      - 10.0.130.2
EOF

    bin/elasticsearch-certutil cert --silent --pem \
      -out config/certs/certs.zip \
      --in config/certs/instances.yml \
      --ca-cert config/certs/ca/ca.crt \
      --ca-key config/certs/ca/ca.key
    unzip -qo config/certs/certs.zip -d config/certs
  else
    echo "INFO: Certificates already exist, skipping generation"
  fi

  echo "INFO: Setting certs and directory permissions"
  chown -R root:root config/certs
  find config/certs -type d -exec chmod 750 {} \;
  find config/certs -type f -exec chmod 640 {} \;

  echo "INFO: Waiting for Elasticsearch to start..."
  until curl --silent --cacert config/certs/ca/ca.crt ${ELASTIC_SERVER_HOST} | grep -q "missing authentication credentials"; do
    sleep 30
  done

  echo "INFO: Setting kibana_system password"
  until curl -s -X POST --cacert config/certs/ca/ca.crt -u "elastic:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    ${ELASTIC_SERVER_HOST}_security/user/kibana_system/_password \
    -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do
    sleep 10
  done

  echo "INFO: Elasticsearch/Kibana setup complete!"
'

sleep 60

echo "INFO: Initializing Elastic Agents policies."
cd /app/policy_update
python3 main.py
