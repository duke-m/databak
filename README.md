# Database Backup Tool

* Backup databases
* Test them in docker

## Prerequisites

On a Mac you can use `brew`.

* POSIX shell (should be available on any system) and a POSIX environment (uses `tar`)
* Current version of postgres (client only okay if only for backing up, uses `pg_dump`, `pg_dumpall`, `psql`, `pg_restore`)
* `git`
* `shasum`
* `gpg` for encryption, needs your keys, have your key ID ready
* optional: `gsutil` to upload directly to Google cloud storage
* optional: Docker for testing the DB, uses `docker compose up -d`, see `compose.yml` and the Docker docs
* optional: `openssl` for generating a random temporary password for the postgres test server

## How To

* Create a configuration file (s. sample file)
* Run `./dump.sh <configuration-file>`
* Store the encrypted copies: one off-line on a optical readonly-medium, one on our Google Cloud backup archive
* Make sure no uncrypted files are left for easy access
* You can test the data with the `start-db.sh` script like this: `./start-db.sh dump/<dir> 9090` or any other port you want to use for the postgres server.

# GitHub Mass Clone Tool

* Clones all repos it can list with your account (no encryption and compression yet)

## How To

* Cloning all repos: `./clone-all-repos.sh your-org dump` will make a snapshot of all repos, compress and encrypt it properly before storing yourself. Does not use `--mirror`. 

## Prerequisites

On a Mac you can use `brew`.

* `gh` GitHub CLI client for the clone-all-repo tool
