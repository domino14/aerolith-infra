set -e

echo "Checking out initial repos. Ensure you have an ssh key registered with github."

cwd=$(pwd)

for repo in "webolith" "macondo" "word_db_maker" "liwords"
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

echo "Bringing up macondo Docker container"

docker-compose up -d macondo

echo "Creating DAWGs from lexica files..."

for lex in "America.txt" "CSW15.txt" "FISE.txt"
do
    # Send an RPC command to Macondo to build DAWGs from these lexicon files.
    preamble='"jsonrpc":"2.0","method":"GaddagService.GenerateDawg"'
    if [ -f $cwd/lexica/$lex ]; then
        rpc_str=$(printf '{%s,"params":{"filename":"%s","minimize":true},"id":%s}' "$preamble" "$cwd/lexica/$lex" "$RANDOM" )
        curl -vvv localhost:8088/rpc -H "Content-Type: application/json" -d $rpc_str
    fi
done

# echo "Building image..."
# # docker build --rm -t webolith:dev .
# docker-compose up -d
# docker-compose run --rm app \
#     mysql -h db -ppass -e "drop database if exists djaerolith;" \
#     -e "create database djaerolith;" \
#     -e "create database test_djAerolith;" \
#     -e "create user aerolith@'%' identified by 'password';" \
#     -e "grant all on djaerolith.* to aerolith@'%';"
# docker-compose run --rm app python manage.py migrate
# docker-compose stop
# echo "Finished! You can now run docker-compose up -d to bring up the env."


# docker-compose stop macondo