#!/usr/bin/bash

function throw()
{
   errorCode=$?
   echo "Error: ($?) LINENO:$1"
   exit $errorCode
}

function check_error {
  if [ $? -ne 0 ]; then
    echo "Error: ($?) LINENO:$1"
    exit 1
  fi
}

export DEBIAN_FRONTEND=noninteractive

docker-compose down || throw ${LINENO}
docker volume rm $(docker volume ls -qf dangling=true)
DOCKER_BUILDKIT=0 docker-compose build --no-cache || throw ${LINENO}
docker-compose up -d || throw ${LINENO}
sleep 20
docker exec -it kafka-0 kafka-topics.sh --alter --topic my-topic --bootstrap-server localhost:9092 --partitions 2
sleep 10
docker restart kafka4public_logs0_1  || throw ${LINENO}
docker restart kafka4public_logs1_1  || throw ${LINENO}
docker restart kafka4public_app_1  || throw ${LINENO}
sleep 10

curl 127.0.0.1:8851/handle && echo || throw ${LINENO}
curl 127.0.0.1:8851/handle && echo || throw ${LINENO}
curl 127.0.0.1:8851/handle && echo || throw ${LINENO}
curl 127.0.0.1:8851/handle && echo || throw ${LINENO}
curl 127.0.0.1:8851/handle && echo || throw ${LINENO}
curl 127.0.0.1:8851/handle && echo || throw ${LINENO}

docker logs kafka4public_logs0_1 || throw ${LINENO}
docker logs kafka4public_logs1_1 || throw ${LINENO}
docker logs kafka4public_app_1 || throw ${LINENO}




docker run --network=kafka4public_backend --rm harbor.iblog.pro/dockerio/skandyla/wrk -t20 -c20 -d30s http://app:8890/handle
