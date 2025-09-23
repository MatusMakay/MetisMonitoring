#!/bin/bash
set -e

bash -c '
  if [ x${ELASTIC_PASSWORD} == x ]; then
    echo "ERROR: Set the ELASTIC_PASSWORD environment variable in the .env file";
    exit 1;
  elif [ x${KIBANA_PASSWORD} == x ]; then
    echo "ERROR: Set the KIBANA_PASSWORD environment variable in the .env file";
    exit 1;
  fi;
  if [ x${ELASTIC_SERVER_HOST} == x ]; then
    echo "ERROR: Set the ELASTIC_SERVER_HOST environment variable in the .env file";
    exit 1;
  elif [ x${KIBANA_SERVER_HOST} == x ]; then
    echo "ERROR: Set the KIBANA_SERVER_HOST environment variable in the .env file";
    exit 1;
  fi;

  if [ ! -f config/certs/ca.zip ]; then
    echo "INFO: Creating CA";
    bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
    unzip config/certs/ca.zip -d config/certs;
  fi;

  if [ ! -f config/certs/certs.zip ]; then
    echo "INFO: Creating certs for ELK components";
    echo -ne \
    "instances:\n"\
    "  - name: es01\n"\
    "    dns:\n"\
    "      - es01\n"\
    "      - localhost\n"\
    "    ip:\n"\
    "      - 127.0.0.1\n"\
    "  - name: kibana\n"\
    "    dns:\n"\
    "      - kibana\n"\
    "      - localhost\n"\
    "    ip:\n"\
    "      - 127.0.0.1\n"\
    "  - name: fleet-server\n"\
    "    dns:\n"\
    "      - fleet-server\n"\
    "      - localhost\n"\
    "    ip:\n"\
    "      - 127.0.0.1\n"\
    "      - 127.0.0.1\n"\
    > config/certs/instances.yml;
    bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
    unzip config/certs/certs.zip -d config/certs;
  fi;

  echo "INFO: Setting certs and directory permissions"
  chown -R root:root config/certs;
  find . -type d -exec chmod 750 {} \;;
  find . -type f -exec chmod 640 {} \;;

  echo "INFO: Waiting for Elasticsearch ";
  until curl --cacert config/certs/ca/ca.crt ${ELASTIC_SERVER_HOST} | grep -q "missing authentication credentials"; do sleep 30; done;

  echo "INFO: Setting kibana_system password";
  until curl -X POST --cacert config/certs/ca/ca.crt -u "elastic:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    ${ELASTIC_SERVER_HOST}_security/user/kibana_system/_password \
    -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done;

  echo "INFO: Elasticsearch/Kibana setup complete!";
'

sleep 60

echo "INFO: Initializing Elastic Agents policies."

cd /app/policy_update
python3 main.py
