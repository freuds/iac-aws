#!/usr/bin/env bash

set -euo pipefail
set +x

if [ $# -eq 1 ]; then
    now=$(/bin/date +%s)
    yesterday=$(/bin/echo "$now - 86400*2" | bc)
    start_time=$(/bin/date -r ${yesterday} "+%Y-%m-%dT%H:%M:%SZ")
    end_time=$(/bin/date -r ${now} "+%Y-%m-%dT%H:%M:%SZ")

    metric=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/S3 \
        --start-time ${start_time} \
        --end-time ${end_time} \
        --period 86400 \
        --statistics Average \
        --metric-name NumberOfObjects \
        --dimensions Name=BucketName,Value="${1}" Name=StorageType,Value=AllStorageTTypes \
        --output json)
    echo $metric
    #     | /bin/jq '.Datapoints[0].Average' | /bin/sed 's/null/0/'
else
    echo "Usage: ${0} BucketName"
    exit 1
fi


# aws cloudwatch get-metric-statistics --metric-name BucketSizeBytes --namespace AWS/S3
# --start-time 2016-10-19T00:00:00Z
# --end-time 2016-10-20T00:00:00Z
# --statistics Average
# --unit Bytes
# --region us-west-2
# --dimensions Name=BucketName,Value=ExampleBucket Name=StorageType,Value=StandardStorage
# --period 86400
# --output json
