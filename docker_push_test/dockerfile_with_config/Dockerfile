#
# [config] IMAGE_NAME: "groovenauts/rails-example"
# [config] VERSION_SCRIPT: 'grep VERSION ./version.go | cut -f2 -d\"'
# [config] DOCKER_PUSH_COMMAND: "gcloud docker -- push"
# [config] DOCKER_PUSH_REGISTRY: "asia.gcr.io"
# [config] DOCKER_PUSH_USERNAME: "groovenauts"

FROM groovenauts/ruby:2.1.2
MAINTAINER tech@groovenauts.jp

ENV RAILS_ENV production

# for debug via HTTP dicrectly
EXPOSE 3000

ADD . /usr/src/app1
WORKDIR /usr/src/app1
VOLUME /usr/src/app1/log

RUN bundle install --system

CMD ["bundle", "exec", "rails", "s", "-e", "production"]
