#!/bin/bash

PROBLEM_PATTERN=$1
ENABLED=$2

if [ -z $ENABLED ]; then
  ENABLED=true
fi

if [[ "$ENABLED" != "true" && "$ENABLED" != "false" ]]; then
   echo "ERROR: invalid ENABLED argument. Must pass 'true' or 'false'"
   exit 1
fi

if [ -z "$PROBLEM_PATTERN" ]; then
   echo "ERROR: missing PROBLEM_PATTERN argument"
   exit 1
fi

PUBLIC_IP="$(curl -s http://checkip.amazonaws.com/)"
    
echo ""
echo "--------------------------------------------------------------------------------------"
echo "Setting $PROBLEM_PATTERN on $PUBLIC_IP"
STATUS_CODE=$(curl --write-out %{http_code} --silent --output /dev/null "http://$PUBLIC_IP:8091/services/ConfigurationService/setPluginEnabled?name=$PROBLEM_PATTERN&enabled=$ENABLED")
if [[ "$STATUS_CODE" -ne 202 ]] ; then
  echo "ERROR: Received STATUS_CODE = $STATUS_CODE"
  exit 1
else
  echo "Done. Value set to $ENABLED."
fi

./getProblemPatterns.sh