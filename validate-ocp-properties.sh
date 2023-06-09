#!/bin/bash

# retrieve variables
OCP_CLUSTER=$1
OCP_LOGIN_USER=$2
OCP_LOGIN_PASS=$3
OCP_PROJECT=$4
OCP_CONFIG_MAPS=$5

FILE_NAME=$6
PROPERTY_KEY=$7
PROPERTY_VAL=$8

oc login $OCP_CLUSTER -u $OCP_LOGIN_USER -p $OCP_LOGIN_PASS > /dev/null
oc project $OCP_PROJECT > /dev/null


FILE_EXTENSION=`echo $FILE_NAME | rev | cut -d'.' -f1 | rev`

if [[ $FILE_EXTENSION == "properties" ]]; then
  if [[ $(oc get cm $OCP_CONFIG_MAPS -o json | jq ".data.\"$FILE_NAME\"" | sed 's/\\\\r\\\\n *\\\\\\n\(\\t\)*//g' | sed 's/\\\\r\\\\n//g' | sed 's/^"//' | sed 's/"$//' | awk '{gsub(/\\n/,"\n")}1'  | sed 's/ *= */=/g' | grep -xc ^$PROPERTY_KEY=$PROPERTY_VAL$) -gt 0 ]]; then
    echo "Property matched for $OCP_PROJECT:$FILE_NAME!!\n\033[0;32m$PROPERTY_KEY=$PROPERTY_VAL\033[0m"
  else
    echo "Property not found in $OCP_PROJECT:$FILE_NAME!!\n\033[0;31m$PROPERTY_KEY=\033[0m"
  fi
elif [[ $FILE_EXTENSION == "yml" ]]; then
  if [[ $(oc get cm $OCP_CONFIG_MAPS -o json | jq ".data.\"$FILE_NAME\"" -r | yq -N ".$PROPERTY_KEY" | grep -xv null | grep -xc $PROPERTY_VAL) -gt 0 ]]; then
    echo "Property matched for $OCP_PROJECT:$FILE_NAME!!\n\033[0;32m$PROPERTY_KEY=$PROPERTY_VAL\033[0m"
  else
    echo "Property not found in $OCP_PROJECT:$FILE_NAME!!\n\033[0;31m$PROPERTY_KEY=\033[0m"
  fi
else
  echo "Cannot yet validate .$FILE_EXTENSION file(s)."
fi
