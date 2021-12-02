#!/usr/bin/env bash

# Usage:
# For Datastore:
# ./init.sh "$IGA_DEPLOYMENT_NAME"
# For BigTable:
# ./init.sh "$IGA_DEPLOYMENT_NAME" bigtable

echo " "
cat readme.txt
echo " "

if [ "$#" -eq 0 ]; then
  echo " "
  echo "Usage: init.sh <tenant-name>"
  echo " "
  echo "    example: init.sh panduri-iga-0821 iga"
  echo " "
  exit 1
fi

TENANT_NAME=$1
DATABASE=${2:-datastore}
BASEDIR=$(cd ../ && pwd)

source ./config.env

grep -rl --exclude='*.sh' '#NAMESPACE#' $BASEDIR | xargs sed -ibackup "s|#NAMESPACE#|${NAMESPACE}|"
sed -ibackup "s|<ADD HERE>|${TENANT_NAME}|"  utils/iga_datastore_schema_job.yaml
sed -ibackup "s|<ADD HERE>|${TENANT_NAME}|"  utils/iga_bigtable_schema_job.yaml
sed -ibackup "s|#BIG_TABLE_PROJECT_ID#|${GCP_PROJECT_ID}|"          utils/iga_bigtable_schema_job.yaml
sed -ibackup "s|#BIG_TABLE_INSTANCE_ID#|${BIG_TABLE_INSTANCE_ID}|"  utils/iga_bigtable_schema_job.yaml
sed -ibackup "s|#BIG_TABLE_ENABLED#|true|"                          utils/iga_bigtable_schema_job.yaml

kubectl create namespace $NAMESPACE

kubectl -n $NAMESPACE create serviceaccount iga-workload-identity
kubectl -n $NAMESPACE annotate serviceaccount iga-workload-identity iam.gke.io/gcp-service-account=${WORKLOAD_IDENTITY_SERVICE_ACCOUNT}
pushd ../secrets
export NAMESPACE=${NAMESPACE}
sh ./apply-secrets.sh
popd

echo "Preferred database: ${DATABASE}"
if [[ $DATABASE == "bigtable" ]]; then
    printf "Using ${YELLOW}BigTable database${COLOR_OFF} for JAS...\n"
    kubectl -n $NAMESPACE create -f utils/iga_bigtable_schema_job.yaml
    echo "Waiting for BigTable schema job to start..."
    sleep 30
    kubectl -n $NAMESPACE logs -f --ignore-errors=true job/iga-datastore-schema-job
    echo " "
    echo "--------"
else
    printf "Using ${YELLOW}Cloud Datastore database${COLOR_OFF} for JAS...\n"
    kubectl -n $NAMESPACE create -f utils/iga_datastore_schema_job.yaml
    echo "Waiting for Datastore schema job to start..."
    sleep 30
    kubectl -n $NAMESPACE logs -f --ignore-errors=true job/iga-datastore-schema-job
    echo " "
    echo "--------"
fi

echo "Next steps: "
echo "  * copy 'Tenant ID' from above logs"  
echo "  * set it to JAS_TENANT_ID property in config.env file"
echo "  * run ./deploy.sh"
echo "--------"
echo " "
