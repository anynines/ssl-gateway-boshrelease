#! /bin/bash
set -o errexit
set -o nounset

BOSH_CLI=${BOSH_CLI:-bosh}
BOSH_DEPLOYMENT_FLAGS="${BOSH_DEPLOYMENT_FLAGS:-"--no-redact"}"
BOSH_DEPLOYMENT_ACTION="${BOSH_DEPLOYMENT_ACTION:-"deploy"}"
BOSH_DEPLOYMENT_ARGS="${BOSH_DEPLOYMENT_ARGS:-""}"
REPO_BASE_PATH=${REPO_BASE_PATH:-~/bosh/epo-deployments-a9s}

if [ $BOSH_DEPLOYMENT_ACTION != "deploy" ]; then
  BOSH_DEPLOYMENT_FLAGS=""
fi

$BOSH_CLI $BOSH_DEPLOYMENT_ARGS -e overbosh $BOSH_DEPLOYMENT_ACTION -d ssl-gateway $REPO_BASE_PATH/deployments/ssl-gateway/${STAGE}/ssl-gateway.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/add-sni.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/ssl-gw-elb-v2.yml \
  -o ${REPO_BASE_PATH}/shared/ops/generic/parallel-updates.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/enable_hsts.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/log4shell-acl.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/haproxy-config-v2.yml \
  -l ${REPO_BASE_PATH}/iaas-config/${STAGE}/iaas-config.yml \
  $BOSH_DEPLOYMENT_FLAGS
