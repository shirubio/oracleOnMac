#!/bin/sh

./stop.sh

# Ask for user confirmation
read -p "Are you sure you want to delete the volume 'oracle-data'? This action cannot be undone. (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker volume rm oracle-data
    echo "Volume 'oracle-data' has been deleted."

    docker volume create --name=oracle-data
    echo "New volume 'oracle-data' has been created."
else
    echo "Operation cancelled. The volume was not deleted."
fi