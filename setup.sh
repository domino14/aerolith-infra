#!/usr/bin/env bash

# This is a helper script to setup the entire Aerolith stack from scratch.
# Please refer to the README.md for instructions. The bare minimum needed
# is lexicon files, git, and docker.

set -e

echo "Trying to fetch lexica repo"
cwd=$(pwd)

{
    git clone --depth 1 git@github.com:domino14/word-game-lexica ./word-game-lexica &&
    cp ./word-game-lexica/*.txt $cwd/lexica &&
    cp ./word-game-lexica/kwg/*.kwg $cwd/lexica/gaddag
} || {
    echo "Could not check out lexica repo. You may not have access. "
    echo "This will not work if you don't have at least one lexicon "
    echo "inside the $cwd/lexica directory, and the corresponding .kwg "
    echo "inside the $cwd/lexica/gaddag directory. See README for more info."
}

echo "Checking out initial repos. Ensure you have an ssh key registered with github."


for repo in "webolith" "word_db_server"
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

echo "Creating word databases"

docker build -t domino14/word_db_server -f word_db_server/Dockerfile word_db_server

docker run --rm \
    -v $cwd/lexica:/lexica \
    -v $cwd/lexica/db:/db \
    -e LEXICON_PATH=/lexica/ \
    -e LETTER_DISTRIBUTION_PATH=/lexica/letterdistributions \
    domino14/word_db_server ./dbmaker -dbs NWL20,CSW21 -outputdir /db

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
docker-compose run --rm app ./manage.py loaddata challenge_names

docker-compose stop

echo "All ready! You can now type docker-compose up to bring up the environment."
