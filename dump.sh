#!/bin/sh
# Dump a database and its roles
# Mario Duhanic

# rm:
# due to the nature of modern filesystems, we are using a simple rm -f here
# make sure your environment is secure and encrypted.

if [ "$1" = "" ]; then
    echo "Usage: $0 config-file.sh"
    exit
fi

error=0
pg_dump=pg_dump
pg_dumpall=pg_dumpall
psql=psql
tar=tar
rm="rm -f"
gpg=gpg

compress() {
    echo Compressing...
    $tar $1 $2 || error=10
}

# what, connection
. $1

db_creds=($(echo $connection | sed -r 's/^postgresql:\/\/([a-zA-Z0-9]+):(.+)@(.+):([0-9]+)\/([a-zA-Z0-9_]+)\?*.*/\1 \2 \3 \4 \5/'))

db_user=${db_creds[0]}
db_password=${db_creds[1]}
db_host=${db_creds[2]}
db_port=${db_creds[3]}
db_name=${db_creds[4]}


# if debug is set, print the parsed connection string
if [ "$debug" ]; then
    echo "User: $db_user"
    # print password with asterisks
    echo "Password: ${db_password//?/*}"
    echo "Host: $db_host"
    echo "Port: $db_port"
    echo "Database: $db_name"
fi

# check if all database variables are set
# will need that for pg_dumpall mainly
if [ "$db_user" = '' -o "$db_password" = '' -o "$db_host" = '' -o "$db_port" = '' -o "$db_name" = '' ]; then
    echo "Missing database credentials after parsing."
    exit 1
fi

# check if config is containing all needed variables
# POSIX compliant (zsh would be [[||]]):
if [ "$what" = '' -o "$connection" = '' ]; then
    echo "Config error."
    exit 2
fi

# check if headless is set in config
if [ "$headless" ]; then
    echo "Headless mode."
    
    # exit if no encrypt_to is set
    if [ ! "$encrypt_to" ]; then
        echo "No encrypt_to set."
        exit 3
    fi

    echo "Will remove unencrypted and uncompressed."

    #set compress and remove_uncompressed
    compress="true"
    remove_uncompressed="true"

    # set remove_unencrypted
    remove_unencrypted="true"
fi

# set current timestamp and target directory
time=$(date +"%Y_%m_%d_%H_%M_%S")
target_dir=dump/$what/$what-$time
target=$target_dir/$what-$time

# debug mode
if [ "$debug" ]; then
    echo "DEBUG MODE"
    echo "will not execute"
    echo "What: $what"
    echo "Connection: $connection"
    echo "Target: $target"
    echo "Time: $time"
    echo "Error: $error"
    exit
fi

# create target directories if they don't exist
if [ ! -d $target_dir ]; then
    echo "Creating $target_dir..."
    mkdir -p $target_dir || error=20
fi

start_time=`date +%s`
echo Dumping Schema...
$pg_dump --dbname=$connection --schema-only >$target-dump-schema-only.sql || error=40
echo Dumping Data...

# $pg_dump --dbname=$connection >$target-dump.sql || error=45
$pg_dump -Fc --dbname=$connection >$target-dump.dump || error=45

echo Dumping Roles...
$psql $connection -X -t -f role-creator.sql .sql >$target-roles.sql || error=50
end_time=`date +%s`
echo Time: $((end_time-start_time)) s
du -hc $target-*.sql | grep total
du -hc $target-*.dump | grep total
echo Writing Readme...
echo "Dump of $what at $time." >$target-readme.txt || error=30
echo "Don't need to use the schema-only dump for recreating the database." >>$target-readme.txt

echo "Creating checksums..."
shasum -a 256 $target-*.sql >>$target-checksums.txt || error=35

# compress if needed and remove uncompressed if needed
if [ "$compress" ]; then
    echo "Compressing..."
    $tar -czf $target.tgz $target-* || error=60
    if [ "$remove_uncompressed" ]; then
        echo "Removing uncompressed..."
        $rm $target-*.sql $target-*.dump || error=55
    fi
fi

# encrypt with public key if needed and remove unencrypted if needed
if [ "$encrypt_to" ]; then
    echo "Encrypting..."
    $gpg --encrypt --recipient $encrypt_to $target.tgz || error=70
    if [ "$remove_unencrypted" ]; then
        echo "Removing unencrypted..."
        $rm $target.tgz || error=75
    fi
fi

# upload to google bucket if needed
if [ "$upload_to" ]; then
    echo "Uploading..."
    gsutil cp $target.tgz $upload_to || error=80
fi

# exit with error code if error occured
if [ "$error" -gt 0 ]; then
    echo "Error: $error"
    exit $error
fi