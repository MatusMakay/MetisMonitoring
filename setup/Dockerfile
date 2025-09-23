ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}

USER root
RUN microdnf install -y python3 python3-pip unzip bash && \
    microdnf clean all

WORKDIR /app
COPY ./policy_update/ ./policy_update
RUN pip3 install --no-cache-dir -r policy_update/requirements.txt

RUN chmod +x policy_update/main.py

WORKDIR /usr/share/elasticsearch

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
