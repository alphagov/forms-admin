# GOV.UK Forms Admin [![Ruby on Rails CI](https://github.com/alphagov/forms-admin/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/alphagov/forms-admin/actions/workflows/rubyonrails.yml) [![Deploy to GOV.UK PaaS](https://github.com/alphagov/forms-admin/actions/workflows/deploy.yml/badge.svg)](https://github.com/alphagov/forms-admin/actions/workflows/deploy.yml)

GOV.UK Forms is a service for creating forms. GOV.UK Forms Admin is a an application to handle the administration, design and publishing of those forms. It's a Ruby on Rails application built on a PostgreSQL database.

## Before you start

To run the project you will need to install:

- [Ruby](https://www.ruby-lang.org/en/) - we use version 3 of Ruby. Before running the project, double check the [.ruby-version] file to see the exact version.
- [Node.js](https://nodejs.org/en/) - the frontend build requires Node.js. We use Node 16 LTS versions.
- a running [PostgreSQL](https://www.postgresql.org/) database
- [Yarn](https://yarnpkg.com/) - we use Yarn rather than `npm` to install and run the frontend.

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
make setup
```

`make setup` runs `bin/setup` which is idempotent, so you can also run it whenever you pull new changes.

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

| Name                  | Purpose                                                            |
| --------------------- | ------------------------------------------------------------------ |
| `DATABASE_URL`        | The URL to the postgres instance (without the database at the end) |
| `API_BASE`            | The base url for the API - E.g. `http://localhost:9090`            |
| `RUNNER_BASE`         | The base url for the Runner - E.g. `http://localhost:3001`         |
| `SERVICE_UNAVAILABLE` | All pages will render 'Service unavailable' if set to `true`       |
| `API_KEY`             | The API key for authentication                                     |

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

### Running the app

You can run this using the make command:

```bash
make serve
```

Without make, you can either run the development task:

```bash
# Run the foreman dev server. This will also start the frontend dev task
bin/dev
```

or run the rails server:

```bash
# Run a local Rails server
bin/rails server

# When running the server, you can use any of the frontend tasks, e.g.:
yarn dev
```

### Running the tests

The tests run with Rspec and can be run via make:

```bash
make test
```

To run specific tests, you can also call rspec directly with

```bash
bundle exec rspec
```

### Linting

To run linting with fixes you can use

```bash
make lint-fix
```

## Configuration and deployment

The forms-admin app is containerised (see [Dockerfile](https://github.com/alphagov/forms-admin/blob/main/Dockerfile)) and can be deployed however you would normally deploy a containerised app.

If you are planning to deploy to GOV.UK PaaS without using the container, you can see how this runs in our [Deployment CI action](https://github.com/alphagov/forms-admin/blob/main/.github/workflows/deploy.yml).

## Explain how to test the project

```bash
# Run the Ruby test suite
bin/rake
# To run the Javascript test suite, run
yarn test
```

## Explain how to add a user to the database

In order to run this project, your database will need to have a user in it. To add one, run the follwing commands:

```bash
bin/rails db:seed
```

## Explain how to use GOV.UK Notify

If you want to test the notify function, you will need to get a test API key
from the [notify service](https://www.notifications.service.gov.uk/) Add it as
an environment variable under `SETTINGS__GOVUK_NOTIFY__API_KEY=` or creating/edit
a `config/settings/development.local.yml` and adding the following to it.

```
# Settings for GOV.UK Notify api & email templates
govuk_notify:
  api_key: KEY_FROM_NOTIFY_SERVICE
```

Example emails can be seen locally by visiting `http://localhost:3000/rails/mailers`

## Explain how to use Sentry

We currently have a very basic setup for Sentry in this repo for testing, which we will continue to build upon.

In order to use this:

- first sign up to [Sentry](https://sentry.io) and create a new project
- create a file called `.env` in the root of this repo
- add the Sentry DNS to local settings config file eg. `config/settings.local.yml` ((more details)[https://github.com/alphagov/forms-admin/blob/fbefdea6de9dbbee75b0f67e4bc9f4e1080acffd/README.md])
- uncomment out the exception triggers in [this file](config/initializers/sentry.rb)
- Build the project and watch the errors come through on Sentry

## Support

Raise a Github issue if you need support.

## Explain how users can contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).
