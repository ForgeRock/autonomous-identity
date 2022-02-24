#!/usr/bin/env bash

# Usage:
# For Datastore:
# ./deploy.sh dev
# For BigTable:
# ./deploy.sh dev bigtable

YELLOW='\033[0;33m'
COLOR_OFF='\033[0m'

cat readme.txt
echo " "


source ./config.env

if [ "$#" -eq "0" ]; then
  printf "Deploying in ${YELLOW}default${COLOR_OFF} mode\n"
else
  if [[ $1 == "dev" ]] ; then
  printf "Deploying in ${YELLOW}dev${COLOR_OFF} mode...\n"
    kubectl -n $NAMESPACE apply -k dev/
  elif [[ $1 == "default" ]] ; then
    echo "Deploying..."
  else
    echo "Unknown deployment mode $1.  Available modes are 'default' and 'dev'\n"
    exit 1
  fi
fi
echo " "

DATABASE=${2:-datastore}
echo "Preferred database: ${DATABASE}"

ES_USERNAME_ENC=`echo -n $ES_USERNAME | base64`
ES_PASSWORD_ENC=`echo -n $ES_PASSWORD | base64`
TLS_STORE_PASS_ENC=`echo -n $TLS_STORE_PASS | base64`
OPENIDM_ADMIN_PASSWORD_ENC=`echo -n openidm-admin | base64`

sed -ibackup "s|#CLOUD_DATASTORE_PROJECT_ID#|${GCP_PROJECT_ID}|"                                  app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#BIG_TABLE_PROJECT_ID#|${GCP_PROJECT_ID}|"                                        app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#BIG_TABLE_INSTANCE_ID#|${BIG_TABLE_INSTANCE_ID}|"                                app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#DATAFLOW_PROJECT_ID#|${GCP_PROJECT_ID}|"                                         app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#DATAFLOW_WORKER_SERVICE_ACCOUNT#|${DATAFLOW_WORKER_SERVICE_ACCOUNT}|"            app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#DATAFLOW_ETL_CONFIG_LOCATION#|${DATAFLOW_ETL_CONFIG_LOCATION}|"                  app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#DOMAIN_NAME#|${DOMAIN_NAME}|"                                                    app/nginx/overlays/nginx_config_map.yaml
sed -ibackup "s|#IGA_UI_SUBDOMAIN#|${IGA_UI_SUBDOMAIN}|"                                          app/nginx/overlays/nginx_config_map.yaml
sed -ibackup "s|#PLATFORM_UI_SUBDOMAIN#|${PLATFORM_UI_SUBDOMAIN}|"                                app/nginx/overlays/nginx_config_map.yaml
sed -ibackup "s|#ES_HOST#|${ES_HOST}|"                                                            app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#ES_PRIMARY_SHARDS_PER_INDEX#|${ES_PRIMARY_SHARDS_PER_INDEX}|"                    app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#ES_REPLICA_SHARDS_PER_INDEX#|${ES_REPLICA_SHARDS_PER_INDEX}|"                    app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#ES_SSL_ENABLED#|${ES_SSL_ENABLED}|"                                              app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#ES_PASSWORD#|${ES_PASSWORD_ENC}|"                                                app/jas/overlays/jas_secret.yaml
sed -ibackup "s|#ES_USERNAME#|${ES_USERNAME_ENC}|"                                                app/jas/overlays/jas_secret.yaml
sed -ibackup "s|#GCP_PROJECT#|${GCP_PROJECT_ID}|"                                                 app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#GCP_PROJECT#|${GCP_PROJECT_ID}|"                                                 app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -ibackup "s|#GCP_REGION#|${GCP_REGION}|"                                                      app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#GCP_REGION#|${GCP_REGION}|"                                                      app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -ibackup "s|#GKE_CLUSTER_NAME#|${GKE_CLUSTER_NAME}|"                                          app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -ibackup "s|#ETL_RUNNER#|${ETL_RUNNER}|"                                                      app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#JAS_TENANT_ID#|${JAS_TENANT_ID}|"                                                app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#OIDC_ENABLED#|${OIDC_ENABLED}|"                                                  app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#IGA_UI_SUBDOMAIN#|${IGA_UI_SUBDOMAIN}|"                                          app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#APPLICATION_TEMPLATE_FOLDER#|${APPLICATION_TEMPLATE_FOLDER}|"                    app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#PLATFORM_UI_SUBDOMAIN#|${PLATFORM_UI_SUBDOMAIN}|"                                app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#DOMAIN_NAME#|${DOMAIN_NAME}|"                                                    app/iga-api/overlays/iga_api_config_map.yaml
sed -ibackup "s|#JAS_TENANT_ID#|${JAS_TENANT_ID}|"                                                app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#JAS_AUDIT_HANDLER_TARGET_OUTPUT#|${JAS_AUDIT_HANDLER_TARGET_OUTPUT}|"            app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#AUTHORIZATION_ENDPOINT#|${AUTHORIZATION_ENDPOINT}|"                              app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#TOKEN_ENDPOINT#|${TOKEN_ENDPOINT}|"                                              app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#USER_INFO_ENDPOINT#|${USER_INFO_ENDPOINT}|"                                      app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#CLIENT_ID#|${CLIENT_ID}|"                                                        app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#CLIENT_SECRET#|${CLIENT_SECRET}|"                                                app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#SCOPE#|${SCOPE}|"                                                                app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#DOMAIN_NAME#|${DOMAIN_NAME}|"                                                    app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#PLATFORM_UI_SUBDOMAIN#|${PLATFORM_UI_SUBDOMAIN}|"                                app/openidm/overlays/openidm_config_map.yaml
sed -ibackup "s|#JAS_TENANT_ID#|${JAS_TENANT_ID}|"                                                app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#JAS_AUDIT_HANDLER_TARGET_OUTPUT#|${JAS_AUDIT_HANDLER_TARGET_OUTPUT}|"            app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#OIDC_ENABLED#|${OIDC_ENABLED}|"                                                  app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#AUTHORIZATION_ENDPOINT#|${AUTHORIZATION_ENDPOINT}|"                              app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#TOKEN_ENDPOINT#|${TOKEN_ENDPOINT}|"                                              app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#WELL_KNOWN_ENDPOINT#|${WELL_KNOWN_ENDPOINT}|"                                    app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#CLIENT_ID#|${CLIENT_ID}|"                                                        app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#CLIENT_SECRET#|${CLIENT_SECRET}|"                                                app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#OIDC_SCOPE#|${OIDC_SCOPE}|"                                                      app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#OIDC_REDIRECT_URL#|${OIDC_REDIRECT_URL}|"                                        app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#OIDC_AUTHENTICATIONID_KEY#|${OIDC_AUTHENTICATIONID_KEY}|"                        app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#OIDC_PROPERTY_MAPPING#|${OIDC_PROPERTY_MAPPING}|"                                app/openidm_bootstrap/openidm_config_map.yaml
sed -ibackup "s|#JAS_URL#|${JAS_URL}|"                                                            app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#OPENIDM_ADMIN_PASSWORD#|${OPENIDM_ADMIN_PASSWORD_ENC}|"                          app/iga-api/overlays/iga_api_secret.yaml
sed -ibackup "s|#OPENIDM_ADMIN_PASSWORD#|openidm-admin|"                                          app/openidm/overlays/boot.properties
sed -ibackup "s|#OPENIDM_PROMETHEUS_PASSWORD#|prometheus|"                                        app/openidm/overlays/boot.properties
sed -ibackup "s|#PG_HOST#|${PG_HOST}|"                                                            app/openidm/overlays/openidm_statefulset.yaml
sed -ibackup "s|#PG_ROOT_PASSWORD#|${PG_ROOT_PASSWORD}|"                                          app/openidm/overlays/openidm_statefulset.yaml
sed -ibackup "s|#PG_HOST#|${PG_HOST}|"                                                            app/openidm_bootstrap/openidm_statefulset.yaml
sed -ibackup "s|#PG_ROOT_PASSWORD#|${PG_ROOT_PASSWORD}|"                                          app/openidm_bootstrap/openidm_statefulset.yaml
sed -ibackup "s|#SECRET_ALIAS_ES_KEYSTORE_PASSWORD#|${SECRET_ALIAS_ES_KEYSTORE_PASSWORD}|"        app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_ES_KEYSTORE#|${SECRET_ALIAS_ES_KEYSTORE}|"                          app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_ES_PASSWORD#|${SECRET_ALIAS_ES_PASSWORD}|"                          app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_ES_TRUSTSTORE_PASSWORD#|${SECRET_ALIAS_ES_TRUSTSTORE_PASSWORD}|"    app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_ES_TRUSTSTORE#|${SECRET_ALIAS_ES_TRUSTSTORE}|"                      app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_ES_USERNAME#|${SECRET_ALIAS_ES_USERNAME}|"                          app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_JAS_SIGNATURE_KEY#|${SECRET_ALIAS_JAS_SIGNATURE_KEY}|"              app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_JAS_TLS_KEYSTORE_PASS#|${SECRET_ALIAS_JAS_TLS_KEYSTORE_PASS}|"      app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_JAS_TLS_KEYSTORE#|${SECRET_ALIAS_JAS_TLS_KEYSTORE}|"                app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_JAS_TLS_TRUSTSTORE_PASS#|${SECRET_ALIAS_JAS_TLS_TRUSTSTORE_PASS}|"  app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#SECRET_ALIAS_JAS_TLS_TRUSTSTORE#|${SECRET_ALIAS_JAS_TLS_TRUSTSTORE}|"            app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#PUB_SUB_ENABLED#|${PUB_SUB_ENABLED}|"                                            app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#PUB_SUB_PROJECT_ID#|${PUB_SUB_PROJECT_ID}|"                                      app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#PUB_SUB_OPENIDM_AUDIT_TOPIC#|${PUB_SUB_OPENIDM_AUDIT_TOPIC}|"                    app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#PUB_SUB_OPENIDM_AUDIT_SUBSCRIPTION#|${PUB_SUB_OPENIDM_AUDIT_SUBSCRIPTION}|"      app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#PUB_SUB_OPENIDM_AUDIT_BATCH_SIZE#|${PUB_SUB_OPENIDM_AUDIT_BATCH_SIZE}|"          app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#PUB_SUB_OPENIDM_AUDIT_POLL_INTERVAL#|${PUB_SUB_OPENIDM_AUDIT_POLL_INTERVAL}|"    app/jas/overlays/jas_config_map.yaml
sed -ibackup "s|#TLS_STORE_PASS#|${TLS_STORE_PASS_ENC}|"                                          app/jas/overlays/jas_secret.yaml
sed -ibackup "s|#ES_HOST#|${ES_HOST}|"                                                            app/etl/overlays/etl_config_map.yaml
sed -ibackup "s|#ES_PORT#|${ES_PORT}|"                                                            app/etl/overlays/etl_config_map.yaml
sed -ibackup "s|#ES_SSL_ENABLED#|${ES_SSL_ENABLED}|"                                              app/etl/overlays/etl_config_map.yaml
sed -ibackup "s|#ES_PASSWORD#|${ES_PASSWORD_ENC}|"                                                app/etl/overlays/etl_secret.yaml
sed -ibackup "s|#ES_USERNAME#|${ES_USERNAME_ENC}|"                                                app/etl/overlays/etl_secret.yaml
sed -ibackup "s|#TLS_STORE_PASS#|${TLS_STORE_PASS_ENC}|"                                          app/etl/overlays/etl_secret.yaml
sed -ibackup "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm/overlays/datasource.jdbc-default.json
sed -ibackup "s|#PG_OPENIDM_USER_PASSWORD#|${OPENIDM_DATABASE_USER_PASSWORD}|"                    app/openidm/overlays/datasource.jdbc-default.json
sed -ibackup "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm/overlays/openidm_database.env
sed -ibackup "s|#PG_OPENIDM_USER_PASSWORD#|${OPENIDM_DATABASE_USER_PASSWORD}|"                    app/openidm/overlays/openidm_database.env

sed -ibackup "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm_bootstrap/datasource.jdbc-default.json
sed -ibackup "s|#PG_OPENIDM_USER_PASSWORD#|${OPENIDM_DATABASE_USER_PASSWORD}|"                    app/openidm_bootstrap/datasource.jdbc-default.json
sed -ibackup "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm_bootstrap/openidm_database.env
sed -ibackup "s|#PG_OPENIDM_USER_PASSWORD#|${OPENIDM_DATABASE_USER_PASSWORD}|"                    app/openidm_bootstrap/openidm_database.env
sed -ibackup "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm_bootstrap/openidm_statefulset.yaml
sed -ibackup "s|#PG_OPENIDM_USER_PASSWORD#|${OPENIDM_DATABASE_USER_PASSWORD}|"                    app/openidm_bootstrap/openidm_statefulset.yaml

if [[ $DATABASE == "bigtable" ]]; then
  sed -ibackup "s|#BIG_TABLE_ENABLED#|true|"             app/jas/overlays/jas_config_map.yaml
  sed -ibackup "s|#CLOUD_DATASTORE_ENABLED#|false|"      app/jas/overlays/jas_config_map.yaml
  sed -ibackup "s|#EPS_DB_SOURCE#|bigtable|"             app/jas/overlays/jas_config_map.yaml
else
  sed -ibackup "s|#BIG_TABLE_ENABLED#|false|"            app/jas/overlays/jas_config_map.yaml
  sed -ibackup "s|#CLOUD_DATASTORE_ENABLED#|true|"       app/jas/overlays/jas_config_map.yaml
  sed -ibackup "s|#EPS_DB_SOURCE#|datastore|"            app/jas/overlays/jas_config_map.yaml
fi

echo "Initiating openidm bootstrap process"
# bootstrap_openidm.sh <namespace>
./bootstrap_openidm.sh $NAMESPACE
if [ $? -ne 0 ]
    then
        echo "ERROR: Failed to bootstrap openidm. Unable to continue!"
        exit 1
fi

kubectl -n $NAMESPACE apply -k app/

echo "Waiting for services to start..."
kubectl -n $NAMESPACE wait --for=condition=available --timeout=60s --all deployments
# extra wait time for OpenIDM and JAS services to initialize
sleep 180
kubectl -n $NAMESPACE create -f utils/iga_schema_seed_job.yaml
echo "Waiting for schema seeding job to run..."
sleep 60
kubectl -n $NAMESPACE logs -f --ignore-errors=true  job/iga-schema-seed-job

echo "Waiting for external IP address"

ip=""
while [ -z $ip ]; do
  ip=$(kubectl get svc nginx --namespace $NAMESPACE --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$ip" ] && sleep 10
done

echo "--------"

printf "External IP: ${YELLOW} $ip\n"

printf "${COLOR_OFF}"

echo "--------"
echo " "
