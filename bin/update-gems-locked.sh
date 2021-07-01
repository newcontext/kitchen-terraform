#!/bin/bash

set -e
source /usr/local/share/chruby/chruby.sh
set +x
for RUBY in . ruby-2.7 ruby-2.6 ruby-2.5 ruby-2.4
do
  pushd "$RUBY"
  if [ "$RUBY" != "." ]
  then
    chruby "$RUBY"
  fi
  ruby --version
  set -x
  gem install bundler
  if [ -e gems.locked ]
  then
    bundle update --all
  else
    bundle install
  fi
  bundle clean
  bundle binstubs --force bundler guard middleman-cli pry rake reek rspec-core rufo test-kitchen travis yard
  set +x
  popd
done
