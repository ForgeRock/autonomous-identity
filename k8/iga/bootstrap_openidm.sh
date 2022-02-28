#!/bin/bash

if [ $# -eq 0 ]
    then echo "usage: $0 namespace"
fi

NAMESPACE=$1

# Deploy openidm and jas
kubectl -n ${NAMESPACE} create -k app/openidm_bootstrap
if [ $? -ne 0 ]
    then
        echo "ERROR: Failed to deploy app/openidm_bootstrap"
        exit 1 
fi


# Loop and and wait for "OpenIDM ready" in logs
i=0
max=12
delay=15
ready=0
while [ $i -le $max ]
do
    sleep $delay
    ready=$(kubectl -n ${NAMESPACE} logs statefulset/openidm | grep -c -E "^OpenIDM ready$")
    if [ "$ready" -gt 0  ]
        then 
            let "i=$max + 1"
        else 
            ((i++))
    fi
done

# Remove deployment
kubectl -n ${NAMESPACE} delete -k app/openidm_bootstrap

# Process result
echo $ready
if [ $ready -eq 1 ]
    then
        echo "OpenIDM initialization completed SUCCESSFULLY"
    else
        echo "OpenIDM initialization FAILED"
fi
