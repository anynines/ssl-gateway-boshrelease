#!/usr/bin/env bash

export DEFAULT_APP_DOMAIN=de.a9sapp.eu
export RANDOM_DOMAIN=misterX.com
export UNREACHABLE_BLACKLIST_DOMAIN=ssltest3.com
export REACHABLE_BLACKLIST_DOMAIN=ssltest4.com
export UNREACHABLE_SSL_BLACKLIST_DOMAIN=ssltest2.com
export REACHABLE_SSL_BLACKLIST_DOMAIN=ssltest.com
export OPS_FILE=/home/vcap/bosh/anynines-PaaS-deployment/ssl-gateway/ops/vSphere-networks.yml
export IAAS_CONFIG=/home/vcap/bosh/anynines-PaaS-deployment/iaas-config/a9s-staging-vsphere.yml
export EXTERNAL_SECRETS=/home/vcap/bosh/anynines-deployment/secrets/external-secrets.yml
export LOCALHOST_IP=172.27.1.5

cf auth $CF_USER $CF_PASSWORD


cf create-org ssl-gateway-acceptance
cf target -o ssl-gateway-acceptance

cf create-space test
cf target -s test

cf create-domain ssl-gateway-acceptance de.a9sapp.eu
cf create-domain ssl-gateway-acceptance misterX.com
cf create-domain ssl-gateway-acceptance ssltest3.com
cf create-domain ssl-gateway-acceptance ssltest4.com
cf create-domain ssl-gateway-acceptance ssltest2.com
cf create-domain ssl-gateway-acceptance ssltest.com

bundle install
rspec

cf delete-org ssl-gateway-acceptance
