#!/usr/bin/env bash
set -e
cd $GITHUB_WORKSPACE
zip -r $HOME/solrconfig.zip . -x ".git*" \
  Gemfile Gemfile.lock "spec/*" "vendor/*" \
  Makefile ".circle*" ".github/*" "bin/*" LICENSE "README*" \
