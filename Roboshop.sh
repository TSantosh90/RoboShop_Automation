#!/bin/bash

SG_ID="sg-03397cf5cc6b4017f"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z03483342NIJJTO7ECL8J"
DOMIAN_NAME="santoshdevops.online"

for instance in $@
do
   INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
     --security-group-id $SG_ID \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
     --query 'Instances[0].InstanceId' \
     --output text )

    if [ $instance == "frontend" ]; then
       IP=$(
        aws ec2 describe-instances \
         --instance-ids $INSTANCE_ID \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text 
        )
      RECORD_NAME="$DOMAIN_NAME" #santoshdevops.online
    else
      IP=$(
        aws ec2 describe-instances \
       --instance-ids $INSTANCE_ID \
       --query 'Reservations[].Instances[].PrivateIpAddress' \
       --output text 
       )
       RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.santoshdevops.online
    fi
        echo "IP Address: $IP"

    
  aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID \
   --change-batch '{
     "Changes": [
      {
        "Action": "Updating record",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            { "Value": "'$IP'" }
          ]
        }
      }
     ]
   }'
 echo "Record updated for $instance"
done 
