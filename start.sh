#! /bin/bash

# get user info
username="Galaxy" #FIXME: get the galaxy username
pw_hash="" # no password
salt="" # no salt

# sed the dump template
cp /dump.template.nq /dump.nq
sed -i "s@__USERNAME__@$username@g" /dump.nq
sed -i "s/__EMAIL__/$USER_EMAIL/g" /dump.nq
sed -i "s@__PASSWORD_HASH__@$pw_hash@g" /dump.nq
sed -i "s@__SALT__@$salt@g" /dump.nq

sed -i "s@__ASKOMICS_KEY_ID__@galaxy_5Dvp@g" /dump.nq
sed -i "s@__ASKOMICS_KEY_NAME__@galaxy@g" /dump.nq
sed -i "s@__ASKOMICS_API_KEY__@$ASKOMICS_API_KEY@g" /dump.nq

sed -i "s@__GALAXY_ID__@$galaxy_id@g" /dump.nq
sed -i "s@__GALAXY_URL__@$GALAXY_URL@g" /dump.nq
sed -i "s@__GALAXY_KEY__@$API_KEY@g" /dump.nq

mkdir /data/toLoad
mv /dump.nq /data/toLoad

# Link galaxy uploaded datasets into askomics upload dir
mkdir -p $ASKO_files_dir/upload
ln -s /import $ASKO_files_dir/upload/$username

# Start Virtuoso
chmod +x /virtuoso.sh
/virtuoso.sh &

# Wait for virtuoso to be up
while ! wget -O /dev/null -o /dev/null http://localhost:8890/conductor; do
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
