#!/bin/bash

/home/server/scripts/notify.sh "Server login" "Login to ${USER}@$(hostname -f) from $(echo $SSH_CLIENT|awk '{print $1}') ($(date))"

