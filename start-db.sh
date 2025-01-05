#!/bin/sh

# Start a database container and load a dump into it 
# with roles and data for testing purposes.

docker_compose="docker compose"

# use a random password for the postgres password:
export temp_pg_password=`openssl rand -base64 9`


if [ "$2" = "" ]; then
    echo "Usage: $0 dir port"
    exit
fi

export dir=$1
export port=$2
export name=`basename $dir`

$docker_compose up -d

# Wait for the database to start
echo Sleeping a sec...
sleep 1

# Load roles and data, use connect_timeout to avoid hanging
psql postgresql://postgres:$temp_pg_password@localhost:$port?connect_timeout=10 -f $dir/*-roles.sql

# use the modern and fast way:
pg_restore --no-owner --clean --if-exists -d postgresql://postgres:$temp_pg_password@localhost:$port $dir/*-dump.dump

# let the user know the password:
echo "Connection string: postgresql://postgres:$temp_pg_password@localhost:$port"