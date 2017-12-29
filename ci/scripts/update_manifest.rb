#!/bin/ruby
require 'pp'
require 'yaml'

release_version = File.read("new-release/version")
ssl_gateway_manifest = YAML.parse(File.read("anyines-PaaS-deployment/ssl-gateway/ssl-gateway.yml"))
ssl_gateway_manifest["releases"].each do |release|
  release["version"] = release_version if release["name"] == "ssl-gateway"
end

Dir.chdir("anynines-PaaS-deployment") do
  system("git config --global user.email concourse@anynines.com")
  system("git config --global user.name concourse")
  system("git commit -am 'Update ssl-gateway release version to v#{release_version}'")
end
