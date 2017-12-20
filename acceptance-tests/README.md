# SSL-Gateway integration tests

This testsuite tests the integration of the SSL-Gateway into a CloudFoundry environment.

## Getting Started

### Prerequisites

- bosh CLI v2
- Ruby
- CloudFoundry installation
- a9s ConsulDNS
- a9s-pg

### Installing

To install the ruby dependencies:

```
cd integration-tests

bundle install
```

## Running the tests

Before the testsuite can be run, the appropriate ENV variables must be set

env variables:
- LOCALHOST_IP *required*  - ip of the localhost that runs the testsuite
- IAAS_CONFIG *required* 
- EXTERNAL_SECRETS *required* 
- OPS_FILE *optional* - if an ops file is required to deploy the SSL-Gateway
- CF_USERNAME *required* - you need to provide a user for cf
- CF_PASSWORD *required*
- CF_ORG *required* - you need to provide a org and space for cf
- CF_SPACE *required*

the app requires some domains that are registered in you `/etc/hosts` to resolve to
one of the ssl-gateway nodes.

These domain names need to be set to the following block of env vars.
- REACHABLE_SSL_BLACKLIST_DOMAIN
- UNREACHABLE_SSL_BLACKLIST_DOMAIN
- REACHABLE_BLACKLIST_DOMAIN
- UNREACHABLE_BLACKLIST_DOMAIN
- DEFAULT_APP_DOMAIN
- RANDOM_DOMAIN

E.g. :
```
cat <<EOF
172.27.2.12 checker.ssltest.com
172.27.2.12 checker.ssltest2.com
172.27.2.12 checker.ssltest3.com
172.27.2.12 checker.ssltest4.com
172.27.2.12 checker.misterX.com
172.27.2.12 de.a9sapp.eu
EOF > /etc/hosts

export DEFAULT_APP_DOMAIN=de.a9sapp.eu
export RANDOM_DOMAIN=checker.misterX.com
export UNREACHABLE_BLACKLIST_DOMAIN=checker.ssltest3.com
export REACHABLE_BLACKLIST_DOMAIN=checker.ssltest4.com
export UNREACHABLE_SSL_BLACKLIST_DOMAIN=checker.ssltest2.com
export REACHABLE_SSL_BLACKLIST_DOMAIN=checker.ssltest.com
```

(It doesnt matter which domain is assigned to which env var)

Then you need to make the domains accessable to the CloudFoundry org you specified in
CF_ORG.

```
cf login

cf target -o $CF_ORG -s $CF_SPACE

cf create-domain $CF_ORG $DEFAULT_APP_DOMAIN
cf create-domain $CF_ORG $RANDOM_DOMAIN
cf create-domain $CF_ORG $UNREACHABLE_BLACKLIST_DOMAIN
cf create-domain $CF_ORG $REACHABLE_BLACKLIST_DOMAIN
cf create-domain $CF_ORG $UNREACHABLE_SSL_BLACKLIST_DOMAIN
cf create-domain $CF_ORG $REACHABLE_SSL_BLACKLIST_DOMAIN
```

To run the testsuite

```
cd integration-tests

rspec
```

## Built With

* [RSpec](http://rspec.info)

## Authors

* **Dennis Groß** - *Initial work* - [gdenn](https://github.com/gdenn)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
