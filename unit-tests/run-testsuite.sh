#!/bin/bash

set -eu

gem install bundler

bundle install

rspec