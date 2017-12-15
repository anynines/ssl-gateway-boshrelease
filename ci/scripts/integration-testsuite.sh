set -o errexit # Exit immediately if a simple command exits with a non-zero status
set -o nounset # Report the usage of uninitialized variables

: ${LOCALHOST_IP?"Env variable CF_API not set"}
: ${IAAS_CONFIG?"Env variable CF_API not set"}
: ${EXTERNAL_SECRETS?"Env variable CF_API not set"}
: ${OPS_FILE?"Env variable CF_API not set"}
: ${CF_USERNAME?"Env variable CF_API not set"}
: ${CF_PASSWORD?"Env variable CF_API not set"}
: ${CF_ORG?"Env variable CF_API not set"}
: ${CF_SPACE?"Env variable CF_API not set"}
: ${DEFAULT_APP_DOMAIN?"Env variable CF_API not set"}
: ${RANDOM_DOMAIN?"Env variable CF_API not set"}
: ${UNREACHABLE_BLACKLIST_DOMAIN?"Env variable CF_API not set"}
: ${REACHABLE_BLACKLIST_DOMAIN?"Env variable CF_API not set"}
: ${UNREACHABLE_SSL_BLACKLIST_DOMAIN?"Env variable CF_API not set"}
: ${REACHABLE_SSL_BLACKLIST_DOMAIN?"Env variable CF_API not set"}


cd ssl-gateway-boshrelease/integration-tests/
gem install bundler
bundle install
rspec
cd ..