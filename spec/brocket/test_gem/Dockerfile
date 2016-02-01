#
# [config] IMAGE_NAME: "test_gem"
# [config]
# [config] VERSION_SCRIPT: "ruby -r ./lib/test_gem/version.rb -e 'puts TestGem::VERSION'"
# [config] GIT_TAG_PREFIX: "test_gem/"
#

FROM ruby:2.3.0
MAINTAINER tech@groovenauts.jp

COPY ./test_gem $TEST_GEM_HOME

WORKDIR $TEST_GEM_HOME

RUN bundle install --without test development \
  && echo "export PATH=\$TEST_GEM_HOME/docker:\$PATH" >> $HOME/.bashrc

CMD [ "/bin/bash" ]
