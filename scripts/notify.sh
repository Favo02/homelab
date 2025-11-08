#!/bin/bash

URL=$(<./.gotify-url)
TOKEN=$(<./.gotify-token)
TITLE=$1
TEXT=$2

curl "https://$URL/message?token=$TOKEN" -F "title=$TITLE" -F "message=$TEXT" -F "priority=5" > /dev/null 2>&1
