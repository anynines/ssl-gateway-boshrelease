# SSL-Gateway bosh release

The SSL-Gateway bosh release provides SSL - termination for CloudFoundry apps and load balancing for the cfcommunity gorouter

### Prerequisites

- bosh CLI v2

## Running the tests
Create CloudFoundry user or use CF - admin user credentials 
```
cf create-user max@mustermann.com test123
export CF_USER=max@mustermann.com
export CF_PASSWORD=test123
```

The test script holds default values for the a9s vSphere staging system. Change them if needed (@see [env_vars](https://github.com/anynines/ssl-gateway-boshrelease/blob/enable-tcp-proxy-pass/scripts/accceptance-tests.sh#L5-L15))

```
scripts/accceptance-tests.sh
```

## Testcases
- Check if ssl certs are bundled correctly (security_spec.rb)
- Check if version token in server header is off (security_spec.rb)
- Check if https-redirect is working and returns *301 moved permanently* (reachability_spec.rb)
- Check if port 443, 4443 is reachable in vserver with ssl on (security_spec.rb)
- Check if port 80 is reachable in vserver (reachability_spec.rb)
- [Cipherscan](https://github.com/mozilla/cipherscan) CloudFoundry API and check if supported ciphers are used (security_spec.rb)
- [Cipherscan](https://github.com/mozilla/cipherscan) CloudFoundry API and check if supported TLS protocols are used (security_spec.rb)
- Check whitelist feature is working (reachability_spec.rb)
- Check deny_all flag is working (reachability_spec.rb)
- Check tcp fowarding is working for port 222 (reachability_spec.rb)

## Dependencies
- a9s-consul-dns boshrelease
- rabbitmq installation / release colocated
- PostgreSQL installation / release colocated

## Deployment
You need to provide a proper deployment manifest in order to use this release. Furthermore a rabbitmq installation is required to use the vhost API. We look forward to make the vhost API optional so the release can be used without rabbitmq.

Here is an example deployment manifest:

```
---
name: ssl-gateway

releases:
- name: ssl-gateway
  version: MY_RELEASE_VERSION
  url: MY_RELEASE_TARBALL_URL
- name: rabbitmq36
  version: 5
  url: https://s3-eu-west-1.amazonaws.com/anynines-bosh-releases/rabbitmq36-5.tgz
- name: a9s-consul
  version: latest

stemcells:
- os: ubuntu-trusty
  alias: ubuntu-trusty
  version: ((iaas.stemcells.ubuntu-trusty.version))

update:
  canaries: 1
  canary_watch_time: 1000-180000
  max_in_flight: 50
  serial: true
  update_watch_time: 1000-180000

instance_groups:

- name: rabbitmq
  azs: [z1, z2, z3]
  vm_type: small
  persistent_disk_type: small
  instances: 1
  stemcell: ubuntu-trusty
  networks:
  - name: dynamic
  jobs:
  - name: rabbitmq
    release: rabbitmq36
  - name: consul
    release: a9s-consul
  properties:
    consul:
      service_name: rabbitmq

- name: ssl-gateway
  azs: [z1, z2, z3]
  vm_type: small
  persistent_disk_type: small
  instances: ((iaas.ssl_gateway.gateway_instances))
  stemcell: ubuntu-trusty
  jobs:
  - name: consul
    release: a9s-consul
  - name: nginx
    release: ssl-gateway
  - name: virtual_host_service_worker
    release: ssl-gateway
  networks:
  - name: dynamic

  properties:
    network: public

- name: gateway-api
  templates:
  - name: consul
    release: a9s-consul
  - name: virtual_host_service_api
    release: ssl-gateway
  azs: [z1, z2, z3]
  vm_type: small
  persistent_disk_type: small
  instances: 1
  stemcell: ubuntu-trusty
  networks:
  - name: dynamic
  properties:
    consul:
      service_name: vhost-api

properties:
  network: dynamic

  vhost_api:
    postgresql_host: ((my_postgres_ip))
    postgresql_db: sslgateway
    postgresql_username: sslgateway
    postgresql_password: ((my_postgres_password))
    port: 3000

  rabbitmq:
    admin_username: admin
    admin_password: ((my_rabbitmq_password))
    host: ((my_rabbitmq_ip)

  a9s_ssl_gateway:
    cf_routers: ((my_cf_router_ips))
    ssh_routers: ((my_cf_router_ips))
    enable_https_redirect: true

    vserver:
      - domain: ((iaas.cf.app_domain))
        ca: ((default_app.ca))
        certificate: ((default_app.certificate))
        private_key: ((default_app.private_key))
        default_server: true
      - domain: checker.ssltest.com
        ca: ((ssltest.ca))
        certificate: ((ssltest.certificate))
        private_key: ((ssltest.private_key))
        deny_all: true
        allow:
        - MY_AWS_VPC
      - domain: ssltest2.com
        ca: ((ssltest2.ca))
        certificate: ((ssltest2.certificate))
        private_key: ((ssltest2.private_key))
        deny_all: true
      - domain: only_got_port_80.com
      - domain: you_are_not_allowed_to_enter.com
        deny_all: true

  default_app:
    ca: |
      -----BEGIN CERTIFICATE-----
      -----END CERTIFICATE-----
    certificate: |
      -----BEGIN CERTIFICATE-----
      -----END CERTIFICATE-----
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      -----END RSA PRIVATE KEY-----

  ssltest:
    ca: |
      -----BEGIN CERTIFICATE-----
      -----END CERTIFICATE-----
    certificate: |
      -----BEGIN CERTIFICATE-----
      -----END CERTIFICATE-----
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      -----END CERTIFICATE-----
    certificate: |
      -----BEGIN CERTIFICATE-----
      -----END CERTIFICATE-----
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      -----END CERTIFICATE-----
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      -----END RSA PRIVATE KEY-----

  consul:
    domain: ((MY_CONSUL_DOMAIN))
    dc: dc1
    agent_address: ((MY_CONSUL_IP))
    server: false
    encrypt: ((/cdns_encrypt))
    cluster:
      join_hosts: ((MY_CONSUL_CLUSTER))
    ssl_ca: ((/cdns_ssl.ca))
    ssl_cert: ((/cdns_ssl.certificate))
    ssl_key: ((/cdns_ssl.private_key))
```

## Properties

| Property | Description |
|----------|-------------|
| a9s_ssl_gateway.cf_routers | [ List IP's ] List of upstream ips to which the SSL-Gateway will proxy (e.g. CloudFoundry gorouter IP's) |
| a9s_ssl_gateway.load_balancer_address | [ List IP / IP - range] sets the [real_ip_from](http://nginx.org/en/docs/http/ngx_http_realip_module.html) directive. Use this to specify the network from which the SSL-Gateway will only accept requests (e.g. AWS VPC to which the ELB belongs) |
| a9s_ssl_gateway.enable_proxy_protocol | [ true / false ] if set to true enables the [proxy_protocol](https://www.nginx.com/resources/admin-guide/proxy-protocol/). The proxy protocol is used to receive the client's IP through e.g. Loadbalancer (tcp forwarding) which are in front of the SSL-Gateway. __NOTE__ if proxy_protocol is set to true Nginx will enforce it! |
| a9s_ssl_gateway.enable_https_redirect | [ true / false ] if set to true all requests on port 80 are redirect to the same url via https |
| a9s_ssl_gateway.ssh_routers | mostly gorouter IP's |
| a9s_ssl_gateway.failover_ip | mostly gorouter IP's |
| a9s_ssl_gateway.z1.network_address | [ IP ] network address for availability zone z1 |
| a9s_ssl_gateway.z2.network_address | [ IP ] network address for availability zone z2 |
| a9s_ssl_gateway.z3.network_address | [ IP ] network address for availability zone z3 |
| a9s_ssl_gateway.vserver | List of vservers which will be created in the nginx http config |
| a9s_ssl_gateway.vserver[n].default_server | Sets the label [default_server](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen) on all ports of this vserver |
| a9s_ssl_gateway.vserver[n].domain | Sets the [server_name](http://nginx.org/en/docs/http/ngx_http_core_module.html#server_name) directive in the vserver entry to match __domain__ and __*.domain___ (all subdomains) |
| a9s_ssl_gateway.vserver[n].ca | (TLS) ca - cert for TLS (Port 443, 4443 are automatically activated if you specify a valid value for ca, certificate and private_key) |
| a9s_ssl_gateway.vserver[n].certificate | (TLS) certificate for TLS |
| a9s_ssl_gateway.vserver[n].private_key | (TLS) private_key for TLS |
| a9s_ssl_gateway.vserver[n].deny_all | [true / false] if set to true, all incoming requests are denied (can be combined with allow to implement whitelist) |
| a9s_ssl_gateway.vserver[n].allow | [ IP / IP - range] Explicitly allows incoming requests from IP / IP - range (use this for whitelisting) |

*a9s_ssl_gateway.vserver[n].foo* - stands for property *foo* of an array element *n* in *a9s_ssl_gateway.vserver*

## Built With
* [Bosh](https://bosh.io)

## Versioning
We use [SemVer](http://semver.org/) for versioning.

## Contributing
@see [CONTRIBUTING.md](./CONTRIBUTING.md)

## Changelog
@see [CHANGELOG.md](./CHANGELOG.md)

## Authors
* **Dennis Groß** - *v1.2.0* - [gdenn](https://github.com/gdenn)
* **Dennis Groß** - *v1.1.0* - [gdenn](https://github.com/gdenn)
* **Dennis Groß** - *Initial work* - [gdenn](https://github.com/gdenn)
* **Sven Schmidt** - *Initial work* - [schmidtsv](https://github.com/schmidtsv)

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Limitations

## Known Issues

## TODO
- Modify vhost api include directives to use the same ssl config and default location headers as in vserver.conf.erb
- Implement feature that lets us scale the vhost worker instances and syncs certs / vservers (also for failover)
- Add migration testcases which check if values in store/nginx[site-enabled/ site-available/ ssl/ ] are kept upon migration
- Add migration testcases which check if old config file in store/nginx are removed and updated upon migration
- Add reachability testcases with https-redirect disabled


