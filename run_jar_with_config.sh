#!/usr/bin/env bash

export DATABASE_URL="mysql://localhost:3306/cat_dev?user=cat_user&password=local-pass"
export APP_HOST="http://localhost:3000"
export PORT="3000"
export USER_API_URI="https://adams.ugent.be/oauth/api/current_user/"

export AUTHORIZE_URI="https://adams.ugent.be/oauth/oauth2/authorize/"
export ACCESS_TOKEN_URI="https://adams.ugent.be/oauth/oauth2/token/"
export OAUTH_CONSUMER_KEY="tomtest"
export OAUTH_CONSUMER_SECRET="blargh"

java \
    -Dlogback.configurationFile=env/dev/resources/logback.xml \
    -jar target/uberjar/cat.jar
