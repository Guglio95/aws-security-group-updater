#!/bin/bash

if [[ -z $SG_UPDATE_GROUP_ID || -z $FROM_PORT || -z $TO_PORT || -z $PROTOCOL  || -z $EXIT_ON_FINISH ]]; then
  echo 'Some ENV is missing.'
  exit 1
fi

MY_IP=$(curl --silent https://checkip.amazonaws.com)

echo "Will update group-id ${SG_UPDATE_GROUP_ID} to allow ${MY_IP} connection to ports ${FROM_PORT}-${TO_PORT}"
DESCRIPTION="Added $(date +%F)"
AWS_AUTHORIZE_RESULT=$(aws ec2 authorize-security-group-ingress \
     --group-id "${SG_UPDATE_GROUP_ID}" \
     --output text \
     --ip-permissions '[{"IpProtocol": "'"${PROTOCOL}"'", "FromPort": '"${FROM_PORT}"', "ToPort": '"${TO_PORT}"', "IpRanges": [{"CidrIp": "'"${MY_IP}/32"'", "Description": "'"${DESCRIPTION}"'"}]}]' \
     2>&1 )

if [ $? -ne 0 ]; then
    if echo "$AWS_AUTHORIZE_RESULT" | grep -q 'InvalidPermission.Duplicate'; then
        echo "IP was already allowed."
    else
        echo "Unknown error: $AWS_AUTHORIZE_RESULT"
        exit 1
    fi
else
    echo "IP correctly allowed."
fi

if [ "${EXIT_ON_FINISH}" == "true" ]; then
    exit 0
fi

sleep infinity