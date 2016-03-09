#!/bin/sh
# build.sh -- invoke gen_website and the CoffeeScript compiler
# (c) 2016 nilsding
# Licensed under the terms of the FreeBSD license.  See the LICENSE file in
# the repository's root for the full license text.

require() {
  if ! which "$1" >/dev/null 2>&1; then
    echo "!! $2 was not found."
    printf "   Please install it using \033[1;33m$3\033[0m\n"
    exit 1
  fi
}

require_success() {
  if [ $1 -ne 0 ]; then
    printf "\033[1;31m        Build failed!\033[0m\n"
    exit 1
  fi
}

require 'ruby' 'Ruby' 'your favourite package manager or RVM/rbenv'
require 'coffee' 'The CoffeeScript compiler' 'npm install -g coffee-script'

echo "-- Building website"
ruby gen_website.rb
require_success $?

echo "-- Compiling CoffeeScript sources"
coffee -co public/js site.coffee
require_success $?

printf "\033[1;32m        Build complete!\033[0m\n"
