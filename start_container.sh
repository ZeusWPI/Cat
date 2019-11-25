#!/bin/bash

# kill the possibly running container
echo "---- KILLING OLD RUNNING CONTAINER ----"
docker kill cat-container
echo "---- REMOVING OLD CONTAINER----"
docker rm cat-container 

# The database url
DATABASE_URL="jdbc:mysql://192.168.2.1:3306/cat_dev?user=cat_user&password=C1t&serverTimezone=UTC"
APP_HOST="http://192.168.2.2:3000"
PORT="3000"
USER_API_URI="https://adams.ugent.be/oauth/api/current_user/"

AUTHORIZE_URI="https://adams.ugent.be/oauth/oauth2/authorize/"
ACCESS_TOKEN_URI="https://adams.ugent.be/oauth/oauth2/token/"
OAUTH_CONSUMER_KEY="tomtest"
OAUTH_CONSUMER_SECRET="blargh"

# IP the container should have
IP="192.168.2.2"
DOCKER_NETWORK="testnet"

# Build the container
echo "---- BUILDING NEW IMAGE: cat ----"
docker build . --rm -t cat

# Start the container, with option restart==always
echo "---- STARTING THE NEW CONTAINER: cat-container IN BACKGROUND ----"
docker run --network="$DOCKER_NETWORK" --ip "$IP" --restart always --name cat-container -d -e DATABASE_URL="$DATABASE_URL" -e APP_HOST="$APP_HOST" -e PORT="$PORT" -e USER_API_URI="$USER_API_URI" -e AUTHORIZE_URI="$AUTHORIZE_URI" -e ACCESS_TOKEN_URI="$ACCESS_TOKEN_URI" -e OAUTH_CONSUMER_KEY="$OAUTH_CONSUMER_KEY" -e OAUTH_CONSUMER_SECRET="$OAUTH_CONSUMER_SECRET" cat

echo "--- REMOVE DANGLING IMAGES ----"
for image in "$(docker images -qa -f 'dangling=true')"
do
  if [[ "$image" != "" ]]
  then
    docker rmi "$image"
  fi
done

echo "---- DONE ----"
