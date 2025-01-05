# all booleans default to false

# default headless setup, minimal configuration:
# headless=true
# what=name
# connection=postgresql://connection-string/sb?sslmode=require
# encrypt_to=123…

# advanced setup:

# debug would output some extra information, it will prevent the script to run, it will only "run dry"
debug=true

# if compress is set to true, the dump will be compressed
compress=true

# if remove_uncompressed is set to true, the uncompressed dump will be removed
remove_uncompressed=true

# if headless is set to true, the script will encrypt the compressed dump and remove the unencrypted and uncompressed dump
# sets to true (overwrites): compress, remove_uncompressed, remove_unencrypted
# needs: encrypt_to
headless=true

# if encrypt_to is set, the script will encrypt the compressed dump
# to the openPGP key with the keyid encrypt_to
# using an explicit keyid prevents the script from encrypting to the wrong key
encrypt_to=F000F0001234DEADBEEFCAFE1234DEADBEEFCAFE

# what is the name of the dump
what=de-ro

# connection is the connection string to the database
# must use TLS (sslmode=require)
connection=postgresql://user:password@host:port/database?sslmode=require
