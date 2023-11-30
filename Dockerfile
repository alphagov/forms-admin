FROM ruby:3.2.2-alpine3.18@sha256:198e97ccb12cd0297c274d10e504138f412f90bed50c36ebde0a466ab89cf526 AS build

WORKDIR /app

RUN apk update
RUN apk upgrade --available
RUN apk add libc6-compat openssl-dev build-base libpq-dev nodejs=~20 npm git python3
RUN adduser -D ruby
RUN mkdir /node_modules && chown ruby:ruby -R /node_modules /app

USER ruby

COPY --chown=ruby:ruby Gemfile* ./
RUN gem install bundler -v 2.4.10
RUN bundle config set --local without development:test \
  && bundle config set --local jobs "$(nproc)"

RUN bundle install

COPY --chown=ruby:ruby package.json package-lock.json ./
RUN npm ci --ignore-scripts

ENV RAILS_ENV="${RAILS_ENV:-production}" \
  NODE_ENV="${NODE_ENV:-production}" \
  PATH="${PATH}:/home/ruby/.local/bin:/node_modules/.bin" \
  USER="ruby" \
  REDIS_URL="${REDIS_URL:-redis://notset/}" \
  GOVUK_APP_DOMAIN="${GOVUK_APP_DOMAIN:-https://not-set}"

COPY --chown=ruby:ruby . .

# you can't run rails commands like assets:precompile without a secret key set
# even though the command doesn't use the value itself
RUN SECRET_KEY_BASE=dummyvalue rails vite:build_all

# Remove devDependencies once assets have been built
RUN npm ci --ignore-scripts --only=production

FROM ruby:3.2.2-alpine3.18@sha256:198e97ccb12cd0297c274d10e504138f412f90bed50c36ebde0a466ab89cf526 AS app

ENV RAILS_ENV="${RAILS_ENV:-production}" \
  PATH="${PATH}:/home/ruby/.local/bin" \
  USER="ruby"

WORKDIR /app

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

CMD ["/bin/sh", "-o", "xtrace", "-c", "rails s -b 0.0.0.0"]
