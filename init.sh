#!/bin/sh

./stop.sh
docker volume rm oracle-data
docker volume create --name=oracle-data
