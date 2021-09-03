#!/usr/bin/env bash

YELLOW='\033[0;33m'
COLOR_OFF='\033[0m'

kustomize_dir=app
echo " "
if [ "$#" -eq "0" ]; then
  printf "Deploying in ${YELLOW}default${COLOR_OFF} mode\n"
else
  if [[ $1 == "dev" ]] ; then
  printf "Deploying in ${YELLOW}dev${COLOR_OFF} mode\n"
    kustomize_dir=dev
  elif [[ $1 == "default" ]] ; then
    print "Deploying in ${YELLOW}default${COLOR_OFF} mode"
    kustomize_dir=app
  else
    echo "Deployment mode $1 is no supported.  Available modes are 'default' and 'dev'\n"
    exit 1
  fi

fi
echo " "

cat readme.txt
echo " "

source ./config.env

ES_USERNAME_ENC=`echo -n $ES_USERNAME | base64`
ES_PASSWORD_ENC=`echo -n $ES_PASSWORD | base64`
TLS_STORE_PASS_ENC=`echo -n $TLS_STORE_PASS | base64`
OPENIDM_ADMIN_PASSWORD_ENC=`echo -n $OPENIDM_ADMIN_PASSWORD | base64`

sed -i .template "s|#CLOUD_DATASTORE_PROJECT_ID#|${GCP_PROJECT_ID}|"                                  app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#DATAFLOW_PROJECT_ID#|${GCP_PROJECT_ID}|"                                         app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#DATAFLOW_WORKER_SERVICE_ACCOUNT#|${DATAFLOW_WORKER_SERVICE_ACCOUNT}|"            app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#DOMAIN_NAME#|${DOMAIN_NAME}|"                                                    app/nginx/overlays/nginx_config_map.yaml
sed -i .template "s|#ES_HOST#|${ES_HOST}|"                                                            app/etl/overlays/etl_config_map.yaml
sed -i .template "s|#ES_HOST#|${ES_HOST}|"                                                            app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#ES_PASSWORD#|${ES_PASSWORD_ENC}|"                                                app/etl/overlays/etl_secret.yaml
sed -i .template "s|#ES_PASSWORD#|${ES_PASSWORD_ENC}|"                                                app/jas/overlays/jas_secret.yaml
sed -i .template "s|#ES_PORT#|${ES_PORT}|"                                                            app/etl/overlays/etl_config_map.yaml
sed -i .template "s|#ES_PRIMARY_SHARDS_PER_INDEX#|${ES_PRIMARY_SHARDS_PER_INDEX}|"                    app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#ES_REPLICA_SHARDS_PER_INDEX#|${ES_REPLICA_SHARDS_PER_INDEX}|"                    app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#ES_USERNAME#|${ES_USERNAME_ENC}|"                                                app/etl/overlays/etl_secret.yaml
sed -i .template "s|#ES_USERNAME#|${ES_USERNAME_ENC}|"                                                app/jas/overlays/jas_secret.yaml
sed -i .template "s|#ETL_RUNNER#|${ETL_RUNNER}|"                                                      app/iga-api/overlays/iga_api_config_map.yaml
sed -i .template "s|#GCP_PROJECT#|${GCP_PROJECT_ID}|"                                                 app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#GCP_PROJECT#|${GCP_PROJECT_ID}|"                                                 app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -i .template "s|#GCP_REGION#|${GCP_REGION}|"                                                      app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#GCP_REGION#|${GCP_REGION}|"                                                      app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -i .template "s|#GKE_CLUSTER_NAME#|${GKE_CLUSTER_NAME}|"                                          app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -i .template "s|#JAS_TENANT_ID#|${JAS_TENANT_ID}|"                                                app/iga-api/overlays/iga_api_config_map.yaml
sed -i .template "s|#JAS_TENANT_ID#|${JAS_TENANT_ID}|"                                                app/openidm/overlays/openidm_config_map.yaml
sed -i .template "s|#JAS_URL#|${JAS_URL}|"                                                            app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#OPENIDM_ADMIN_PASSWORD#|${OPENIDM_ADMIN_PASSWORD_ENC}|"                          app/iga-api/overlays/iga_api_secret.yaml
sed -i .template "s|#OPENIDM_ADMIN_PASSWORD#|${OPENIDM_ADMIN_PASSWORD}|"                              utils/iga_schema_seed_job.yaml
sed -i .template "s|#OPENIDM_ADMIN_PASSWORD#|${OPENIDM_ADMIN_PASSWORD}|"                              app/openidm/overlays/boot.properties
sed -i .template "s|#OPENIDM_KEYSTORE_PASSWORD#|${OPENIDM_KEYSTORE_PASSWORD}|"                        app/openidm/overlays/openidm_secretagent_secret.yaml
sed -i .template "s|#OPENIDM_PROMETHEUS_PASSWORD#|${OPENIDM_PROMETHEUS_PASSWORD}|"                    app/openidm/overlays/boot.properties
sed -i .template "s|#PG_HOST#|${PG_HOST}|"                                                            app/openidm/overlays/openidm_deployment.yaml
sed -i .template "s|#PG_OPENIDM_USER_PASSWORD#|${PG_OPENIDM_USER_PASSWORD}|"                          app/openidm/overlays/openidm_config_map.yaml
sed -i .template "s|#PG_OPENIDM_USER_PASSWORD#|$PG_OPENIDM_USER_PASSWORD}|"                           app/openidm/overlays/openidm_deployment.yaml
sed -i .template "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm/overlays/openidm_config_map.yaml
sed -i .template "s|#PG_OPENIDM_USER#|openidm|"                                                       app/openidm/overlays/openidm_deployment.yaml
sed -i .template "s|#PG_ROOT_PASSWORD#|${PG_ROOT_PASSWORD}|"                                          app/openidm/overlays/openidm_deployment.yaml
sed -i .template "s|#PROMETHEUS_BASIC_AUTH#|${PROMETHEUS_BASIC_AUTH}|"                                app/prometheus-metrics/overlays/prometheus-metrics_deployment.yaml
sed -i .template "s|#SECRET_ALIAS_ES_KEYSTORE_PASSWORD#|${SECRET_ALIAS_ES_KEYSTORE_PASSWORD}|"        app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_ES_KEYSTORE#|${SECRET_ALIAS_ES_KEYSTORE}|"                          app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_ES_PASSWORD#|${SECRET_ALIAS_ES_PASSWORD}|"                          app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_ES_TRUSTSTORE_PASSWORD#|${SECRET_ALIAS_ES_TRUSTSTORE_PASSWORD}|"    app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_ES_TRUSTSTORE#|${SECRET_ALIAS_ES_TRUSTSTORE}|"                      app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_ES_USERNAME#|${SECRET_ALIAS_ES_USERNAME}|"                          app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_JAS_SIGNATURE_KEY#|${SECRET_ALIAS_JAS_SIGNATURE_KEY}|"              app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_JAS_TLS_KEYSTORE_PASS#|${SECRET_ALIAS_JAS_TLS_KEYSTORE_PASS}|"      app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_JAS_TLS_KEYSTORE#|${SECRET_ALIAS_JAS_TLS_KEYSTORE}|"                app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_JAS_TLS_TRUSTSTORE_PASS#|${SECRET_ALIAS_JAS_TLS_TRUSTSTORE_PASS}|"  app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#SECRET_ALIAS_JAS_TLS_TRUSTSTORE#|${SECRET_ALIAS_JAS_TLS_TRUSTSTORE}|"            app/jas/overlays/jas_config_map.yaml
sed -i .template "s|#TLS_STORE_PASS#|${TLS_STORE_PASS_ENC}|"                                          app/etl/overlays/etl_secret.yaml
sed -i .template "s|#TLS_STORE_PASS#|${TLS_STORE_PASS_ENC}|"                                          app/jas/overlays/jas_secret.yaml

# update boot.properties
export BOOT_PROPERTIES_ENC=`cat app/openidm/overlays/boot.properties | base64`
sed -i .template "s|#BOOT_PROPERTIES_ENC#|${BOOT_PROPERTIES_ENC}|"                                    app/openidm/overlays/openidm_secret.yaml

kubectl apply -f ../common/secret-agent/base/secret-agent.yaml
echo "Waiting for FRSA system..."
sleep 30
kubectl -n iga apply -k ${kustomize_dir}/
echo "Waiting for services to start..."
kubectl -n iga wait --for=condition=available --timeout=60s --all deployments
# extra wait time for OpenIDM and JAS services to initialize
sleep 30
kubectl -n iga create -f utils/iga_schema_seed_job.yaml
echo "Waiting for schema seeding job to run..."
sleep 30
kubectl -n iga logs -f --ignore-errors=true  job/iga-schema-seed-job

echo "Waiting for external IP address"

ip=""
while [ -z $ip ]; do
  ip=$(kubectl get svc nginx --namespace iga --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$ip" ] && sleep 10
done

echo "--------"

printf "External IP: ${YELLOW} $ip\n"

printf "${COLOR_OFF}"

echo "--------"
echo " "
