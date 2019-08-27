#! /bin/bash

# Create the database with the Galaxy user
mkdir -p ${ASKO_files_dir}
sqlite3 ${ASKO_database_path} "CREATE TABLE IF NOT EXISTS users (user_id INTEGER PRIMARY KEY AUTOINCREMENT, username text, email text, password text, salt text, apikey text, admin boolean, blocked boolean);"
sqlite3 ${ASKO_database_path} "INSERT INTO users VALUES (NULL, '${GALAXY_USER_NAME}', '${GALAXY_USER_EMAIL}', '', '', '${ASKOMICS_API_KEY}', 'true', 'false')"

sqlite3 ${ASKO_database_path} "CREATE TABLE IF NOT EXISTS galaxy_accounts (galaxy_id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, url text, apikey text, FOREIGN KEY(user_id) REFERENCES users(user_id));"
sqlite3 ${ASKO_database_path} "INSERT INTO galaxy_accounts VALUES(NULL, 1, '${GALAXY_URL}', '${GALAXY_API_KEY}');"

# Link galaxy uploaded datasets into askomics upload dir
mkdir -p ${ASKO_files_dir}/${GALAXY_USER_NAME}
ln -s /import ${ASKO_files_dir}/${GALAXY_USER_NAME}/upload

# Start Virtuoso
chmod +x /virtuoso.sh
/virtuoso.sh &

# Wait for virtuoso to be up
while ! wget -O /dev/null http://localhost:8890/conductor; do
    sleep 1s
done

# manage proxy
if [[ $PROXY_PREFIX != "" ]]; then
    # There is a proxy, export env for the askomics proxy
    export ASKOCONFIG_app_colon_main_filter_hyphen_with='proxyprefix'
    export ASKOCONFIG_filter_colon_proxyprefix_use='egg:PasteDeploy#prefix'
    export ASKOCONFIG_filter_colon_proxyprefix_prefix=$PROXY_PREFIX
fi

# Start AskOmics
cd ${ASKOMICS_DIR}
./startAskomics.sh -r
