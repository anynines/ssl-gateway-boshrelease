#! /bin/bash
set -o errexit
set -o nounset

BOSH_CLI=${BOSH_CLI:-bosh}
BOSH_DEPLOYMENT_FLAGS="${BOSH_DEPLOYMENT_FLAGS:-"--no-redact"}"
BOSH_DEPLOYMENT_ACTION="${BOSH_DEPLOYMENT_ACTION:-"deploy"}"
BOSH_DEPLOYMENT_ARGS="${BOSH_DEPLOYMENT_ARGS:-""}"
REPO_BASE_PATH=${REPO_BASE_PATH:-~/bosh/epo-deployments-a9s}


$BOSH_CLI $BOSH_DEPLOYMENT_ARGS -e overbosh ${BOSH_DEPLOYMENT_ACTION} -d ssl-gateway-haproxy $REPO_BASE_PATH/deployments/ssl-gateway-haproxy/${STAGE}/ssl-gateway.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/ssl-gw-no-elb-haproxy.yml \
  -o ${REPO_BASE_PATH}/shared/ops/generic/parallel-updates.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/enable_hsts.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/log4shell-acl.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/haproxy-config.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/use-main-rabbitmq.yml \
  -l ${REPO_BASE_PATH}/iaas-config/aws-s1/iaas-config.yml \
  $BOSH_DEPLOYMENT_FLAGS

