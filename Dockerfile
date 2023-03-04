FROM ruby:3.2.0-alpine3.17@sha256:c690d3b45ef65e0098104c272f1736b0595b824908d5639c3a3d17636581a905  AS build

WORKDIR /app

# Edge repo is necessary for Node 16 and openssl 3
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update
RUN apk upgrade --available
RUN apk add libc6-compat openssl-dev build-base libpq-dev nodejs=18.15.0-r0 npm
RUN adduser -D ruby
RUN mkdir /node_modules && chown ruby:ruby -R /node_modules /app

USER ruby

COPY --chown=ruby:ruby Gemfile* ./
RUN gem install bundler -v 2.4.10
RUN bundle install --jobs "$(nproc)"

COPY --chown=ruby:ruby package.json ./
RUN npm install --ignore-scripts

ENV RAILS_ENV="${RAILS_ENV:-production}" \
    NODE_ENV="${NODE_ENV:-production}" \
    PATH="${PATH}:/home/ruby/.local/bin:/node_modules/.bin" \
    USER="ruby" \
    REDIS_URL="${REDIS_URL:-redis://notset/}" \
    GOVUK_APP_DOMAIN="${GOVUK_APP_DOMAIN:-https://not-set}"

COPY --chown=ruby:ruby . .

# you can't run rails commands like assets:precompile without a secret key set
# even though the command doesn't use the value itself
RUN SECRET_KEY_BASE=dummyvalue rails assets:precompile

FROM ruby:3.2.0-alpine3.17@sha256:c690d3b45ef65e0098104c272f1736b0595b824908d5639c3a3d17636581a905  AS app

ENV RAILS_ENV="${RAILS_ENV:-production}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="ruby"

WORKDIR /app

# Edge repo is necessary for Node 16 and openssl 3
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update
RUN apk upgrade --available
RUN apk add libc6-compat openssl-dev libpq

RUN adduser -D ruby
RUN chown ruby:ruby -R /app

USER ruby

COPY --chown=ruby:ruby bin/ ./bin
RUN chmod 0755 bin/*

COPY --chown=ruby:ruby --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=ruby:ruby --from=build /app /app

EXPOSE 3000

CMD ["/bin/sh", "-c", "rake db:migrate && rails s -b 0.0.0.0"]
