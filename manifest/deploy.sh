#! /bin/bash
set -o errexit
set -o nounset

BOSH_CLI=${BOSH_CLI:-bosh}
#BOSH_DEPLOYMENT_FLAGS="${BOSH_DEPLOYMENT_FLAGS:-"--no-redact"}"
BOSH_DEPLOYMENT_FLAGS="--no-redact"
BOSH_DEPLOYMENT_ARGS="${BOSH_DEPLOYMENT_ARGS:-""}"
REPO_BASE_PATH=${REPO_BASE_PATH:-~/bosh/epo-deployments-a9s}

$BOSH_CLI $BOSH_DEPLOYMENT_ARGS -e overbosh deploy -d ssl-gateway ./ssl-gateway.yml \
  -o ${REPO_BASE_PATH}/shared/ops/ssl-gateway/ssl-gw-elb.yml \
  -o ${REPO_BASE_PATH}/shared/ops/generic/parallel-updates.yml \
  -o ops/haproxy-config.yml \
  -o ops/log4shell-acl.yml \
  -l ${REPO_BASE_PATH}/iaas-config/aws-s1/iaas-config.yml \
  $BOSH_DEPLOYMENT_FLAGS
