#!/bin/bash

nohup gosu mongodb mongod --dbpath=/data/db &

nohup gosu mongodb mongosh admin --eval "help" > /dev/null 2>&1
RET=$?

while [[ "$RET" -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  mongosh admin --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 2
done

bash /home/mongodb/scripts/setup_user.sh

gosu mongodb mongod --dbpath=/data/db --config mongod.conf --bind_ip_all --auth
