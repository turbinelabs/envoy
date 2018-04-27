#!/usr/bin/env bash

cd "$(dirname "$0")"

docker-compose down

docker-compose up --build -d

# Force some good traffic(200s)
echo "Sending some good traffic..."
for i in {1..10}; do curl -s -o /dev/null -w "%{http_code}\n" localhost:8000/service/1; done

# Force some bad traffic(500s)
echo "Sending some bad traffic..."
for i in {1..10}; do curl -s -o /dev/null -w "%{http_code}\n" -H "fail:now" localhost:8000/service/1; done

front_proxy_id=`docker ps --format "{{.ID}}:{{.Image}}" | grep frontproxy_front-envoy | cut -d: -f 1`

# prints out ejections that were triggered.
docker exec ${front_proxy_id} bash -c "cat /tmp/outliers.log"
