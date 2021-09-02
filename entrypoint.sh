#!/bin/sh

# Start the SSH agent and load key.
source agent-start "$GITHUB_ACTION"
echo "$INPUT_REMOTE_KEY" | SSH_PASS="$INPUT_REMOTE_KEY_PASS" agent-add

# Add strict errors.
set -eu

# Variables.
SWITCHES="$INPUT_SWITCHES"
RSH="ssh -o StrictHostKeyChecking=no -p $INPUT_REMOTE_PORT $INPUT_RSH"
LOCAL_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
DSN="$INPUT_REMOTE_USER@$INPUT_REMOTE_HOST"
SYNC_FILES_TO_WORKSPACE="$INPUT_SYNC_FILES_TO_WORKSPACE"
SYNC_FILES_TO_WORKSPACE_FOLDER="$INPUT_SYNC_FILES_TO_WORKSPACE_FOLDER"
OWNER="$INPUT_OWNER"
GROUP="$INPUT_GROUP"

if [ "$SYNC_FILES_TO_WORKSPACE" = true ] ; then
    # Fetch files.
    echo 'FETCHING FILES'
    sh -c "rsync $SWITCHES -e '$RSH' $DSN:$SYNC_FILES_TO_WORKSPACE_FOLDER $LOCAL_PATH"
else
    # Deploy.
    echo 'DEPLOYING FILES'
    sh -c "rsync $SWITCHES -e '$RSH' $LOCAL_PATH $DSN:$INPUT_REMOTE_PATH"
    
    echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'
    
    ssh -o StrictHostKeyChecking=no -t $DSN "sudo chown -R $OWNER:$GROUP $INPUT_REMOTE_PATH"
fi
