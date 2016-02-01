#
# [config] IMAGE_NAME: "old_app1"
# [config]
# [config] WORKING_DIR: ".."
# [config] VERSION_FILE: "VERSION.txt"
#

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
