#!/bin/ruby
require 'pp'

NGINX_DOWNLOAD_URL = "http://nginx.org/download/nginx-__version__.tar.gz"

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
