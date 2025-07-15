#!/usr/bin/bash

REMOTE_NAME=""

REMOTES=$(rclone listremotes)

if echo "$REMOTES" | grep -q "googledrive"; then
	REMOTE_NAME="googledrive"
elif echo "$REMOTES" | grep -q "gdrive"; then
	REMOTE_NAME="gdrive"
elif echo "$REMOTES" | grep -q "drive"; then
	REMOTE_NAME="drive"
elif echo "$REMOTES" | grep -q "remote"; then
	REMOTE_NAME="remote"
else
	echo "No Google Drive remote found. Please set up a remote using rclone."
	exit 1
fi

mkdir -p $HOME/drive
rclone mount "$REMOTE_NAME": $HOME/drive/
