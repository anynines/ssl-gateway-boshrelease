#!/usr/bin/env bash

export DEFAULT_APP_DOMAIN=de.a9sapp.eu
export RANDOM_DOMAIN=checker.misterX.com
export UNREACHABLE_BLACKLIST_DOMAIN=checker.ssltest3.com
export REACHABLE_BLACKLIST_DOMAIN=checker.ssltest4.com
export UNREACHABLE_SSL_BLACKLIST_DOMAIN=checker.ssltest2.com
export REACHABLE_SSL_BLACKLIST_DOMAIN=checker.ssltest.com
export OPS_FILE=/home/vcap/bosh/anynines-PaaS-deployment/ssl-gateway/ops/vSphere-networks.yml
export IAAS_CONFIG=/home/vcap/bosh/anynines-PaaS-deployment/iaas-config/a9s-staging-vsphere.yml
export EXTERNAL_SECRETS=/home/vcap/bosh/anynines-deployment/secrets/external-secrets.yml

cf auth $CF_USER $CF_PASSWORD


cf create-org ssl-gateway-acceptance
cf target -o ssl-gateway-acceptance

cf create-space test
cf target -s test

cf create-domain ssl-gateway-acceptance de.a9sapp.eu
cf create-domain ssl-gateway-acceptance checker.misterX.com
cf create-domain ssl-gateway-acceptance checker.ssltest3.com
cf create-domain ssl-gateway-acceptance checker.ssltest4.com
cf create-domain ssl-gateway-acceptance checker.ssltest2.com
cf create-domain ssl-gateway-acceptance checker.ssltest.com

bundle install
rspec

cf delete-org ssl-gateway-acceptance
