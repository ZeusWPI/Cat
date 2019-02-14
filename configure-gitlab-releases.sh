#!/usr/bin/env bash

# Never worked

PRIVATE_TOKEN="-gcyNiyf1iAHjDKPTwjy"
URL="https://git.zeus.gent/ZeusWPI/cat/releases/"

if [[ $1 = "list" ]]
then

    curl \
        -H "Accept: application/json" -v \
        --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" "${URL}"

elif [[ $1 = "create" ]]
then

    curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" \
     --data '{ "name": "New release", "tag_name": "v0.1", "description": "Super nice release", "assets": { "links": [{ "name": "hoge", "url": "https://duck.com" }] } }' \
     --request POST "${URL}"

fi