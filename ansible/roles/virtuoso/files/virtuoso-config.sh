#!/usr/bin/env bash

# Adapted configuration from https://github.com/openphacts/ops-platform-setup/blob/master/vagrant_install/bootstrap.sh
# NOTE: not used in the ansible-role-virtuoso, but a future version should enable configuring the options herein.

#set NumberOfBuffers and MaxDirtyBuffers parameters in Virtuoso.ini
totalMem=$(cat /proc/meminfo | grep "MemTotal" | grep -o "[0-9]*")

virtMemAlloc=$(($totalMem/2))
nBuffers=$(($virtMemAlloc/9))
dirtyBuffers=$(($nBuffers*3/4))

echo "Virtuoso params: NumberOfBuffers $nBuffers ; MaxDirtyBuffers: $dirtyBuffers "

sudo sed -i "s/^\(NumberOfBuffers\s*= \)[0-9]*/\1$nBuffers/" $VIRT_INSTALATION_PATH/var/lib/virtuoso/db/virtuoso.ini
sudo sed -i "s/^\(MaxDirtyBuffers\s*= \)[0-9]*/\1$dirtyBuffers/" $VIRT_INSTALATION_PATH/var/lib/virtuoso/db/virtuoso.ini

#Setup Data directory
export DATA_DIR="$1"
echo "export DATA_DIR=$DATA_DIR" >> $HOME/.bashrc
mkdir -p $DATA_DIR

mkdir -p /home/www-data
sudo chown -R www-data:vagrant /home/www-data
echo "export DATA_DIR=/home/www-data" >>/vagrant/env.sh
echo "export SCRIPTS_PATH=/var/www/html/scripts" >>/vagrant/env.sh

sudo sed -i "s%^\(DirsAllowed.*\)$%\1,$DATA_DIR%" $VIRT_INSTALATION_PATH/var/lib/virtuoso/db/virtuoso.ini
sudo sed -i "s%^\(DirsAllowed.*\)$%\1,/home/www-data%" $VIRT_INSTALATION_PATH/var/lib/virtuoso/db/virtuoso.ini


#start Virtuoso
$VIRT_INSTALATION_PATH/bin/virtuoso-t +wait +configfile $VIRT_INSTALATION_PATH/var/lib/virtuoso/db/virtuoso.ini

isql 1111 dba dba VERBOSE=OFF BANNER=OFF PROMPT=OFF ECHO=OFF BLOBS=ON ERRORS=stdout "exec=GRANT EXECUTE  ON DB.DBA.SPARQL_INSERT_DICT_CONTENT TO \"SPARQL\";"
isql 1111 dba dba VERBOSE=OFF BANNER=OFF PROMPT=OFF ECHO=OFF BLOBS=ON ERRORS=stdout "exec=GRANT EXECUTE  ON DB.DBA.L_O_LOOK TO \"SPARQL\";"
isql 1111 dba dba VERBOSE=OFF BANNER=OFF PROMPT=OFF ECHO=OFF BLOBS=ON ERRORS=stdout "exec=GRANT EXECUTE  ON DB.DBA.SPARUL_RUN TO \"SPARQL\";"
isql 1111 dba dba VERBOSE=OFF BANNER=OFF PROMPT=OFF ECHO=OFF BLOBS=ON ERRORS=stdout "exec=GRANT EXECUTE  ON DB.DBA.SPARQL_DELETE_DICT_CONTENT TO \"SPARQL\";"
isql 1111 dba dba VERBOSE=OFF BANNER=OFF PROMPT=OFF ECHO=OFF BLOBS=ON ERRORS=stdout "exec=GRANT EXECUTE  ON DB.DBA.RDF_OBJ_ADD_KEYWORD_FOR_GRAPH TO \"SPARQL\";"

sed -i "s,exit 0,$VIRT_INSTALATION_PATH/bin/virtuoso-t +wait +configfile $VIRT_INSTALATION_PATH/var/lib/virtuoso/db/virtuoso.ini," /etc/rc.local
echo "exit 0" >>/etc/rc.local