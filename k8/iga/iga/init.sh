#!/usr/bin/env bash

echo " "
cat readme.txt
echo " "

if [ "$#" -eq "0" ]; then
  echo " "
  echo "Usage: init.sh <tenant-name>"
  echo " "
  echo "    example: init.sh panduri-iga-0821"
  echo " "
  exit 1
fi

TENANT_NAME=$1

source ./config.env

sed -ibackup "s|<ADD HERE>|${TENANT_NAME}|"  utils/iga_datastore_schema_job.yaml

kubectl create namespace iga
kubectl -n iga create serviceaccount iga-workload-identity
kubectl -n iga annotate serviceaccount iga-workload-identity iam.gke.io/gcp-service-account=${WORKLOAD_IDENTITY_SERVICE_ACCOUNT}
pushd ../secrets
sh ./apply-secrets.sh
popd
kubectl -n iga create -f utils/iga_datastore_schema_job.yaml
echo "Waiting for Datastore schema job to start..."
sleep 30
kubectl -n iga logs -f --ignore-errors=true  job/iga-datastore-schema-job
echo " "
echo "--------"
echo "Next steps: "
echo "  * copy 'Tenant ID' from above logs"  
echo "  * set it to JAS_TENANT_ID property in config.env file"
echo "  * run ./deploy.sh"
echo "--------"
echo " "
