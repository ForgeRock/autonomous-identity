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

sed -i .template "s|<ADD HERE>|${TENANT_NAME}|"  utils/iga_datastore_schema_job.yaml

kubectl create namespace iga

# enable workload identity
kubectl -n iga create serviceaccount iga-workload-identity
kubectl -n iga annotate serviceaccount iga-workload-identity iam.gke.io/gcp-service-account=${WORKLOAD_IDENTITY_SERVICE_ACCOUNT}

echo "Waiting for create secrets job to run..."
# generate secrets for iga
kubectl create -n iga -f utils/iga_create_secrets_job.yaml
kubectl wait -n iga --for=condition=complete --timeout=60s job/iga-create-secrets-job
kubectl logs -n iga  --ignore-errors=true job/iga-create-secrets-job | grep 'TLS_STORE_PASS'

# create datastore tenancy
kubectl -n iga create -f utils/iga_datastore_schema_job.yaml
echo "Waiting for datastore schema job to run..."
kubectl wait -n iga --for=condition=complete --timeout=90s job/iga-datastore-schema-job
echo "Tenant id: "; kubectl logs -n iga --ignore-errors=true job/iga-datastore-schema-job | grep 'Tenant ID' | cut -f4 -d ':'

echo " "
echo "--------"
echo "Next steps: "
echo "  * copy 'KEYSTORE_PASS' from above logs"
echo "  * copy 'Tenant ID' from above logs"  
echo "  * set it to JAS_TENANT_ID property in config.env file"
echo "  * run ./deploy.sh"
echo "--------"
echo " "
