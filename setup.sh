#!/usr/bin/env bash

# This is a helper script to setup the entire Aerolith stack from scratch.
# Please refer to the README.md for instructions. The bare minimum needed
# is lexicon files, git, and docker.

set -e

echo "Trying to fetch lexica repo"

{
    git clone git@github.com:domino14/word-game-lexica ~/word-game-lexica &&
    cp ~/word-game-lexica/*.txt $cwd/lexica
} || {
    echo "Could not check out lexica repo. You may not have access. "
    echo "This will not work if you don't have at least one lexicon "
    echo "inside the $cwd/lexica directory"
}

echo "Checking out initial repos. Ensure you have an ssh key registered with github."

cwd=$(pwd)

for repo in "webolith" "macondo" "word_db_server"
do
    if [ ! -d $cwd/$repo ]; then
        git clone git@github.com:domino14/$repo
    else
        echo "Dir $repo already exists, skipping..."
    fi
done

# Create temporary local_config.env file for webolith in order to allow it to
# come up.

touch $cwd/webolith/config/local_config.env

# cat >/dev/null <<GOTO_1

# XXX: THIS IS BROKEN; FIX ME! THERE IS NO MORE MACONDO.
echo "Bringing up macondo Docker container"

docker-compose up -d macondo

echo "Creating DAWGs and GADDAGs from lexica files..."

for lex in "NWL18.txt" "CSW19.txt" "FISE2.txt"
do
    # Strip out extension.
    lex_name=${lex%.*}

    # Send an RPC command to Macondo to build DAWGs from these lexicon files.
    json_builder='{"jsonrpc":"2.0","method":"GaddagService.%s","params":{"filename":"%s","minimize":true,"authToken":"abcdef"},"id":%s}'

    # If the lexicon text file exists, generate a dawg and a goddamn for it.
    if [ -f $cwd/lexica/$lex ]; then
        rpc_str=$(printf $json_builder "GenerateDawg" "/lexica/$lex" "$RANDOM" )
        echo "Sending" $rpc_str
        curl -v localhost:8088/rpc -H "Content-Type: application/json" -d $rpc_str
        docker-compose exec macondo mv out.dawg /dawgs/$lex_name.dawg

        # Also make the GADDAG as the database maker needs it.
        rpc_str=$(printf $json_builder "Generate" "/lexica/$lex" "$RANDOM" )
        curl -v localhost:8088/rpc -H "Content-Type: application/json" -d $rpc_str
        docker-compose exec macondo mv out.gaddag /gaddags/$lex_name.gaddag
    fi
done

docker-compose stop macondo

echo "Creating word databases"

docker build -t domino14/word_db_server -f word_db_server/Dockerfile word_db_server

docker run --rm \
    -v $cwd/lexica:/lexica \
    -v $cwd/lexica/db:/db \
    -e LEXICON_PATH=/lexica/ \
    domino14/word_db_server ./word_db_server -outputdir /db

# GOTO_1

echo "Fixin' up Aerolith config file"

rm $cwd/webolith/config/local_config.env

cat >$cwd/webolith/config/local_config.env << END
DEBUG=on
DEBUG_JS=on
PGSQL_DB_NAME=djaerolith
PGSQL_USER=postgres
PGSQL_PASSWORD=pass
PGSQL_HOST=pgdb

STATIC_ROOT=/
SECRET_KEY=0gc6=82_ehrw-@fv1a8dqq^6%zuxxu)f^5belgu68cuu*zr&qu
EMAIL_PW=somepass
INTERCOM_APP_SECRET_KEY=abc
USE_GA=off
USE_FB=off

USE_CAPTCHA=off
WORD_DB_SERVER_ADDRESS=http://word_db_server:8180
RECAPTCHA_SSL=off
WORD_DB_LOCATION=/db

END

# Now create the database

docker-compose up -d pgdb
echo "Bringing up database..."
sleep 5

# Bring up app and run migrations

docker-compose build app
docker-compose run --rm app ./manage.py migrate
docker-compose run --rm app ./manage.py createcachetable
docker-compose run --rm app ./manage.py loaddata test/lexica.yaml
docker-compose run --rm app ./manage.py loaddata dcNames
# Run yarn in both webpack containers

docker-compose build webpack_webolith
docker-compose run --rm webpack_webolith yarn
docker-compose build webpack_crosswords
docker-compose run --rm webpack_crosswords yarn

# Run liwords elixir stuff

docker-compose build crosswords
docker-compose run --rm crosswords mix deps.get
docker-compose run --rm crosswords mix ecto.migrate

docker-compose stop

echo "All ready! You can now type docker-compose up -d to bring up the environment."
