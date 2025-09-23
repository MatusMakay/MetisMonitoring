#!/bin/bash
docker volume create certs 2>/dev/null
docker network create siem-ng 2>/dev/null
docker-compose up --build -d
