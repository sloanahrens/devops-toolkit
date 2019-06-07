#!/usr/bin/env bash

STACK_NAME="$1"

echo "Deleting K8s resources for STACK_NAME: $STACK_NAME"
kubectl -n $STACK_NAME delete service,deployment,ingress,statefulset,pod,pvc --all --grace-period=0 --force
kubectl delete ns $STACK_NAME  --ignore-not-found=true

echo "Deleting Route53 records for STACK_NAME: $STACK_NAME"
aws route53 list-resource-record-sets  --hosted-zone-id Z1CDZE44WDSMXZ | jq -c '.ResourceRecordSets[]' |
while read -r resourcerecordset; do
  read -r name type <<<$(echo $(jq -r '.Name,.Type' <<<"$resourcerecordset"))
  if [[ $name = $STACK_NAME* ]]; then
        aws route53 change-resource-record-sets \
          --hosted-zone-id Z1CDZE44WDSMXZ \
          --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
              '"$resourcerecordset"'
            }]}' \
          --output text --query 'ChangeInfo.Id'
  fi
done