#!/usr/bin/env bash

export BOSH="bosh -n"
export CF=cf
export DEFAULT_APP_DOMAIN=de.a9sapp.eu
export RANDOM_DOMAIN=misterX.com
export UNREACHABLE_DOMAIN=ssltest3.com
export REACHABLE_DOMAIN=ssltest4.com
export UNREACHABLE_SSL_DOMAIN=ssltest2.com
export REACHABLE_SSL_DOMAIN=ssltest.com
export OPS_FILE=/home/vcap/bosh/anynines-PaaS-deployment/ssl-gateway/ops/vSphere-networks.yml
export IAAS_CONFIG=/home/vcap/bosh/anynines-PaaS-deployment/iaas-config/a9s-staging-vsphere.yml
export LOCALHOST_IP=172.27.1.5
export ANYNINES_PAAS_DEPLOYMENT=/home/vcap/bosh/anynines-PaaS-deployment


# create org and space
$CF auth $CF_USER $CF_PASSWORD

# $CF create-org ssl-gateway-acceptance
$CF create-org ssl-gateway-acceptance
$CF target -o ssl-gateway-acceptance

# $CF create-space test
$CF create-space test
$CF target -s test

#$CF create-domain ssl-gateway-acceptance de.a9sapp.eu
#$CF create-domain ssl-gateway-acceptance misterX.com
#$CF create-domain ssl-gateway-acceptance ssltest3.com
#$CF create-domain ssl-gateway-acceptance ssltest4.com
#$CF create-domain ssl-gateway-acceptance ssltest2.com
#$CF create-domain ssl-gateway-acceptance ssltest.com

# push binding checkers
#pushd ../acceptance-tests/service-binding-checker > /dev/null
#$CF push checker
#$CF push checker -d ssltest.com
#$CF push checker -d ssltest2.com
#$CF push checker -d ssltest3.com
#$CF push checker -d ssltest4.com
#popd > /dev/null

# upload dev release
#pushd ../ > /dev/null
#$BOSH create-release --force
#release=$(ls -1t dev_releases/ssl-gateway | tr " " "\n"|sed -n '2p')
#prefix="ssl-gateway-"
#suffix=".yml"
#release_version=${release#$prefix}
#release_version=${release_version%$suffix}
#export RELEASE_VERSION=$release_version
#$BOSH upload-release dev_releases/ssl-gateway/$release
#popd > /dev/null

# run test cases
pushd ../acceptance-tests > /dev/null
bundle install

#ruby -r erb -e "puts ERB.new(File.read('manifests/reachability.yml.erb')).result" > 'manifests/reachability.yml'
#$BOSH deploy -d ssl-gateway manifests/reachability.yml -o $OPS_FILE -l $IAAS_CONFIG
#rspec spec/reachability_spec.rb
rspec spec/ssl_spec.rb
popd > /dev/null

# clean-up
# $BOSH clean-up --all

