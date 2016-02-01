#
# [config] IMAGE_NAME: "new_app2"
# [config]
# [config] WORKING_DIR: ".."
# [config] GIT_TAG_PREFIX: "app2/"
#

FROM groovenauts/ruby:2.1.2
MAINTAINER tech@groovenauts.jp

ENV RAILS_ENV production

# for debug via HTTP dicrectly
EXPOSE 3000

ADD app1 /usr/src/app1
ADD app2 /usr/src/app2
WORKDIR /usr/src/app2
VOLUME /usr/src/app2/log

RUN bundle install --system

CMD ["bundle", "exec", "rails", "s", "-e", "production"]
