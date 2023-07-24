# GOV.UK Forms Admin [![Tests](https://github.com/alphagov/forms-admin/actions/workflows/test.yml/badge.svg)](https://github.com/alphagov/forms-admin/actions/workflows/test.yml)

GOV.UK Forms is a service for creating forms. GOV.UK Forms Admin is a an application to handle the administration, design and publishing of those forms. It's a Ruby on Rails application built on a PostgreSQL database.

## Before you start

To run the project you will need to install:

- [Ruby](https://www.ruby-lang.org/en/) - we use version 3 of Ruby. Before running the project, double check the [.ruby-version](.ruby-version) file to see the exact version.
- [Node.js](https://nodejs.org/en/) - the frontend build requires Node.js. We use Node 18 LTS versions.
- a running [PostgreSQL](https://www.postgresql.org/) database

We recommend using a version manager to install and manage these, such as:

- [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv) for Ruby
- [nvm](https://github.com/nvm-sh/nvm) for Node.js
- [asdf](https://github.com/asdf-vm/asdf) for both

## Getting started

### Installing for the first time

```bash
# 1. Clone the git repository and change directory to the new folder
git clone git@github.com:alphagov/forms-admin.git
cd forms-admin

# 2. Run the setup script
./bin/setup
```

### Running the app

You can either run the development task:

```bash
# Run the foreman dev server. This will also start the frontend dev task
bin/dev
```

or run the rails server:

```bash
# Run a local Rails server
bin/rails server

# When running the server, you can use any of the frontend tasks, e.g.:
npm run dev
```

## Development tools

### Running the tests

The app tests are written with [rspec-rails] and can be run with:

```bash
bundle exec rspec
```

There are also unit tests for JavaScript code (look for files named `*.test.js`), written with [Jest]. These can be run with:

```bash
npm run test
```

[rspec-rails]: https://github.com/rspec/rspec-rails
[Jest]: https://jest.io

### Linting

We use [RuboCop GOV.UK] for linting code, to autocorrect issues run:

```bash
bundle exec rubocop -A
```

We also use the [i18n-tasks] tool to keep our locales files in a consistent order. When the tests run they will check if the locale files are normalised, and fail if they are not. To fix the locale files automatically you can run:

```bash
bundle exec i18n-tasks normalize
```

On GitHub pull requests we also check our dependencies for security issues using [bundler-audit], you can run this locally with:

```bash
bundle audit
```

[RuboCop GOV.UK]: https://github.com/alphagov/rubocop-govuk
[i18n-tasks]: https://github.com/glebm/i18n-tasks
[bundle-audit]: https://github.com/rubysec/bundler-audit

### Running tasks with rake

We have a [Rakefile](./Rakefile) that is setup to follow the [GOV.UK conventions for Rails applications].

To lint your changes and run tests with one command you can run

```bash
bundle exec rake
```

[GOV.UK conventions for Rails applications]: https://docs.publishing.service.gov.uk/manual/configure-linting.html#configuring-rails

## Setting up the database

In order to run this project, your database will need to have a user in it. The `bin/setup` script will normally take care of this for you, but if you need to quickly add some users you can do so by loading the database seed:

```bash
bin/rails db:seed
```

## Changing configuration

### Secrets vs Settings

Refer to the [the config gem](https://github.com/railsconfig/config#accessing-the-settings-object) to understand the `file based settings` loading order.

To override file based via `Machine based env variables settings`

```bash
cat config/settings.yml
file
  based
    settings
      env1: 'foo'
```

```bash
export SETTINGS__FILE__BASED__SETTINGS__ENV1="bar"
```

```ruby
puts Settings.file.based.setting.env1
bar
```

Refer to the [settings file](config/settings.yml) for all the settings required to run this app

### Environment variables

| Name           | Purpose                                                            |
| -------------- | ------------------------------------------------------------------ |
| `DATABASE_URL` | The URL to the postgres instance (without the database at the end) |

### Feature flags

This repo supports the ability to set up feature flags. To do this, add your feature flag in the [settings file](config/settings.yml) under the `features` property. eg:

```yaml
features:
  some_feature: true
```

You can then use the [feature service](app/service/feature_service.rb) to check whether the feature is enabled or not. Eg. `FeatureService.enabled?(:some_feature)`.

You can also nest features:

```yaml
features:
  some:
    nested_feature: true
```

And check with `FeatureService.enabled?("some.nested_feature")`.

### Testing with features

Rspec tests can also be tagged with `feature_{name}: true`. This will turn that feature on just for the duration of that test.

## Configuring GOV.UK Notify

We use [GOV.UK Notify] to send emails from our apps.

If you want to test the Notify functionality locally, you will need to get a test API key from the Notify service. Add it as an environment variable under `SETTINGS__GOVUK_NOTIFY__API_KEY` or add it to a local config file:

```
# config/settings.local.yml

# Settings for GOV.UK Notify api & email templates
govuk_notify:
  api_key: <API key from Notify>
```

Example emails can be seen locally by visiting `http://localhost:3000/rails/mailers`

[GOV.UK Notify]: https://www.notifications.service.gov.uk/

## Configuring Sentry

We use [Sentry] to catch exceptions in production apps and alert us.

We currently have a very basic setup for Sentry in this repo for testing, which we will continue to build upon.

In order to use this locally you will need to sign up to Sentry and create a new project. Then add the Sentry DSN to your environment as `SETTINGS__SENTRY__DSN`, or add it to a local config file:

```
# config/settings.local.yml

sentry:
  DSN: <DSN from Sentry>
```

If you want to deliberately raise an exception to test, uncomment out the triggers in the [Sentry initializer script](config/initializers/sentry.rb). Whenever you run the app errors will be raised and should also come through on Sentry.

[Sentry]: https://sentry.io

## Deployment

The forms-admin app is containerised (see [Dockerfile](Dockerfile)) and can be deployed however you would normally deploy a containerised app.

We host our apps using Amazon Web Services, you can [read about how deployments happen on our team wiki, if you have access](https://github.com/alphagov/forms-team/wiki/Deploying-code-changes-AWS).

### Logging

- HTTP access logs are managed using [Lograge](https://github.com/roidrage/lograge) and configured within [the application config](./config/application.rb)
- The output format is JSON using the [JsonLogFormatter](./app/lib/json_log_formatter.rb) to enable simpler searching and visbility especially in Splunk.
- **DO NOT** use [log_tags](https://guides.rubyonrails.org/configuring.html#config-log-tags) since it breaks the JSON formatting produced by Lograge.

### Updating Docker files

To update the version of [Alpine Linux] and Ruby used in the Dockerfile, use the [update_app_versions.sh script in forms-deploy](https://github.com/alphagov/forms-deploy/blob/main/support/update_app_versions.sh)

[Alpine Linux]: https://www.alpinelinux.org/

## Support

Raise a Github issue if you need support.

## How to contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).
