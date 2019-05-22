#!/bin/bash
# requiremet: cifs-utils
# sudo apt-get install cifs-utils 
# if you encounter error
# usage: ./mount.sh $(YOUR_MICROSOFT_ALIAS) $(NETWORK_PATH) $(LOCAL_PATH) 


mkdir -p $3

sudo mount -t cifs -o user=$1,dom=fareast,uid=$(id -u),gid=$(id -g),cruid=$(id -u),vers=2.1,forceuid,forcegid $2 $3