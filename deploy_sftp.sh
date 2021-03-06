#!/bin/bash
if [[ -z $DEPLOY_SFTP_KEY ]] || [[ -z $DEPLOY_SFTP_PATH ]]; then
  echo '$DEPLOY_SFTP_KEY or $DEPLOY_SFTP_PATH is unspecified.'
  exit
else
  echo $DEPLOY_SFTP_KEY | base64 -d > $HOME/deploy_sftp_id_rsa
  chmod 600 $HOME/deploy_sftp_id_rsa
fi

set -x
set -e

PACKAGE=/tmp/$(date -u +%Y%m%d%H%M%S).zip

cd staging
echo $(cd ..; git log | head -1) > NFD-Windows_version.txt
zip -r $PACKAGE *
cd ..

scp -i $HOME/deploy_sftp_id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
$PACKAGE $DEPLOY_SFTP_PATH
rm $HOME/deploy_sftp_id_rsa
