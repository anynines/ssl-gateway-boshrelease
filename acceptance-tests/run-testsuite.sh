#!/usr/bin/env bash

export DEFAULT_APP_DOMAIN=de.a9sapp.eu
export RANDOM_DOMAIN=checker.misterX.com
export UNREACHABLE_BLACKLIST_DOMAIN=checker.ssltest3.com
export REACHABLE_BLACKLIST_DOMAIN=checker.ssltest4.com
export UNREACHABLE_SSL_BLACKLIST_DOMAIN=checker.ssltest2.com
export REACHABLE_SSL_BLACKLIST_DOMAIN=checker.ssltest.com

cf auth $CF_USER $CF_PASSWORD


cf create-org ssl-gateway-acceptance
cf target -o ssl-gateway-acceptance

cf create-space test
cf target -s test

cf create-domain $CF_ORG de.a9sapp.eu
cf create-domain $CF_ORG checker.misterX.com
cf create-domain $CF_ORG checker.ssltest3.com
cf create-domain $CF_ORG checker.ssltest4.com
cf create-domain $CF_ORG checker.ssltest2.com
cf create-domain $CF_ORG checker.ssltest.com

bundle install
rspec
