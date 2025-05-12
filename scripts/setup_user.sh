#!/bin/bash

echo "************************************************************"
echo "Setting up users..."
echo "************************************************************"

# create root user
nohup gosu mongodb mongosh admin --eval "db.createUser({user: 'admin', pwd: '$ADMIN_PASSWORD', roles:[{ role: 'root', db: 'admin' }, { role: 'read', db: 'local' }]});"

# create app user/database
#nohup gosu mongodb mongosh admin --eval "db.createUser({user: 'the_user', pwd: 'mysecretpassword*123', roles: [{ role: 'readWrite', db: 'admin' }, { role: 'read', db: 'local' }]});"

echo "************************************************************"
echo "Shutting down"
echo "************************************************************"
nohup gosu mongodb mongosh admin --eval "db.shutdownServer();"
