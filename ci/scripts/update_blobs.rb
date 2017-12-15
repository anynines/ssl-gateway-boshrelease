#!/bin/ruby
require 'pp'

NGINX_DOWNLOAD_URL = "https://github.com/nginx/nginx/archive/release-__version__.tar.gz"
LIBYAML_DOWNLOAD_URL = "https://github.com/yaml/libyaml/archive/__version__.tar.gz"
RUBY_DOWNLOAD_URL = "https://github.com/ruby/ruby/archive/v__version__.tar.gz"
ZLIB_DOWNLOAD_URL = "https://github.com/madler/zlib/archive/v__version__.tar.gz"
PCRE_DOWNLOAD_URL = "https://github.com/embedthis/pcre/archive/v__version__.tar.gz"
POSTGRES_DOWNLOAD_URL = "https://github.com/postgres/postgres/archive/__version__.tar.gz"
RUBYGEMS_DOWNLOAD_URL = "https://github.com/rubygems/rubygems/archive/v__version__.tar.gz"
BUNDLER_DOWNLOAD_URL = "https://github.com/bundler/bundler/archive/v__version__.tar.gz"

def download_blob(name, template, version)
  blob_dir = "/tmp/#{name}/"
  `rm -rf #{blob_dir}`
  download_url = template.gsub("__version__", version)
  `wget #{download_url} -P #{blob_dir}`
  File.basename(Dir["/tmp/#{name}/*"][0])
end

def remove_blob(name)
  blob_name = name.split(".")[0]
  `bosh remove-blob -n /#{blob_name}/#{name}`
end

def add_blob(name, blob)
  blob_name = name.split(".")[0]
  download_name = File.basename(Dir["/tmp/*"][0])
  `bosh add-blob -n /tmp/#{blob_name}/#{blob} /#{blob_name}/#{name}`
end

def upload_blobs
  `envsubst < config/private.yml.example > config/private.yml`
  `bosh upload-blobs`
end

# update nginx
remove_blob("nginx.tar.gz")
blob =  download_blob("nginx", NGINX_DOWNLOAD_URL, ENV["NGINX_VERSION"])
add_blob("nginx.tar.gz", blob)

# update libyaml
remove_blob("libyaml.tar.gz")
blob =  download_blob("libyaml", LIBYAML_DOWNLOAD_URL, ENV["LIBYAML_VERSION"])
add_blob("libyaml.tar.gz", blob)

# update libyaml
remove_blob("ruby.tar.gz")
blob =  download_blob("ruby", RUBY_DOWNLOAD_URL, ENV["RUBY_VERSION"])
add_blob("ruby.tar.gz", blob)

# update zlib
remove_blob("zlib.tar.gz")
blob =  download_blob("zlib", ZLIB_DOWNLOAD_URL, ENV["ZLIB_VERSION"])
add_blob("zlib.tar.gz", blob)

# update pcre
remove_blob("pcre.tar.gz")
blob =  download_blob("pcre", PCRE_DOWNLOAD_URL, ENV["PCRE_VERSION"])
add_blob("pcre.tar.gz", blob)

# update postgres
remove_blob("postgres.tar.gz")
blob =  download_blob("postgres", POSTGRES_DOWNLOAD_URL, ENV["POSTGRES_VERSION"])
add_blob("postgres.tar.gz", blob)

# update rubygems
remove_blob("rubygems.tar.gz")
blob =  download_blob("rubygems", RUBYGEMS_DOWNLOAD_URL, ENV["RUBYGEMS_VERSION"])
add_blob("rubygems.tar.gz", blob)

# update bundler
remove_blob("bunlder.tar.gz")
blob =  download_blob("bundler", BUNDLER_DOWNLOAD_URL, ENV["BUNDLER_VERSION"])
add_blob("bundler.tar.gz", blob)

upload_blobs