#!/bin/bash

SG_ID="sg-03397cf5cc6b4017f"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do
   INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
     --security-group-id $SG_ID \
     --tag_specifications "ResouceType=instance,Tags=[{key=name,Value=$instance}]" \
     --query 'instances[0].InstanceId' \
     --output text)

    if [ $instance == "frontend" ]; then
       IP=$(
        aws ec2 describe-instances \
         --instance-ids $INSTANCE_ID \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text 
        )

    else

      IP=$(
        aws ec2 describe-instances \
       --instance-ids $INSTANCE_ID \
       --query 'Reservations[].Instances[].PrivateIpAddress' \
       --output text 
       )

    fi
        echo "IP_Address = $IP"
done
