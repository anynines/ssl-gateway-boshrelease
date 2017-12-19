#!/bin/ruby
require 'pp'

NGINX_DOWNLOAD_URL = "http://nginx.org/download/nginx-__version__.tar.gz"
LIBYAML_DOWNLOAD_URL = "https://github.com/yaml/libyaml/archive/__version__.tar.gz"
RUBY_DOWNLOAD_URL = "https://github.com/ruby/ruby/archive/v__version__.tar.gz"
ZLIB_DOWNLOAD_URL = "https://github.com/madler/zlib/archive/v__version__.tar.gz"
PCRE_DOWNLOAD_URL = "https://github.com/embedthis/pcre/archive/v__version__.tar.gz"
POSTGRES_DOWNLOAD_URL = "https://github.com/postgres/postgres/archive/__version__.tar.gz"
RUBYGEMS_DOWNLOAD_URL = "https://github.com/rubygems/rubygems/archive/v__version__.tar.gz"
BUNDLER_DOWNLOAD_URL = "https://github.com/bundler/bundler/archive/v__version__.tar.gz"
AUTOCONF_DOWNLOAD_URL = "https://ftp.gnu.org/gnu/autoconf/autoconf-__version__.tar.gz"

def download_blob(name, template, version)
  blob_dir = "/tmp/#{name}/"
  `rm -rf #{blob_dir}`
  download_url = template.gsub("__version__", version)
  `wget #{download_url} -P #{blob_dir}`
  File.basename(Dir["/tmp/#{name}/*"][0])
end

def remove_blob(blob_dir, name)
  `bosh remove-blob -n /#{blob_dir}/#{name}`
end

def add_blob(blob_dir, name, blob)
  blob_name = name.split(".")[0]
  `bosh add-blob -n /tmp/#{blob_name}/#{blob} /#{blob_dir}/#{name}`
end

def upload_blobs
  `envsubst < config/private.yml.example > config/private.yml`
  `bosh upload-blobs`
end

# update nginx
remove_blob("nginx", "nginx.tar.gz")
blob =  download_blob("nginx", NGINX_DOWNLOAD_URL, ENV["NGINX_VERSION"])
add_blob("nginx", "nginx.tar.gz", blob)

# update postgres
remove_blob("postgres", "postgres.tar.gz")
blob =  download_blob("postgres", POSTGRES_DOWNLOAD_URL, ENV["POSTGRES_VERSION"])
add_blob("postgres", "postgres.tar.gz", blob)

# update libyaml
remove_blob("ruby", "ruby.tar.gz")
blob =  download_blob("ruby", RUBY_DOWNLOAD_URL, ENV["RUBY_VERSION"])
add_blob("ruby", "ruby.tar.gz", blob)

# update rubygems
remove_blob("ruby", "rubygems.tar.gz")
blob =  download_blob("rubygems", RUBYGEMS_DOWNLOAD_URL, ENV["RUBYGEMS_VERSION"])
add_blob("ruby", "rubygems.tar.gz", blob)

# update bundler
remove_blob("ruby", "bunlder.tar.gz")
blob =  download_blob("bundler", BUNDLER_DOWNLOAD_URL, ENV["BUNDLER_VERSION"])
add_blob("ruby", "bundler.tar.gz", blob)

upload_blobs
