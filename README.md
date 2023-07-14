# GOV.UK Forms Admin [![Ruby on Rails CI](https://github.com/alphagov/forms-admin/actions/workflows/test.yml/badge.svg)](https://github.com/alphagov/forms-admin/actions/workflows/test.yml)

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
bin/setup
```

The setup script is idempotent, so you can also run it whenever you pull new changes.

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

On GitHub pull requests we also check our dependencies for security issues using [bundler-audit], you can run this locally with:

```bash
bundle audit
```

[RuboCop GOV.UK]: https://github.com/alphagov/rubocop-govuk
[bundle-audit]: https://github.com/rubysec/bundler-audit

### Running tasks before pushing

Before pushing code changes, it's a good idea to run the tests, use RuboCop to format your code, and [normalize the locales]. We have a [rake] task for running all of these commands in parallel:

```bash
bin/rake run_code_quality_checks
```

[normalize the locales]: https://github.com/glebm/i18n-tasks#normalize-data
[rake]: https://ruby.github.io/rake/

## Configuration and deployment

The forms-admin app is containerised (see our [Dockerfile](./Dockerfile)) and can be deployed however you would normally deploy a containerised app.

We host our apps using Amazon Web Services, you can [read about how deployments happen on our team wiki](https://github.com/alphagov/forms-team/wiki/Deploying-code-changes-AWS).

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

## Updating versions

Use the [update_app_versions.sh script in forms-deploy](https://github.com/alphagov/forms-deploy/blob/main/support/update_app_versions.sh)

## Support

Raise a Github issue if you need support.

## Explain how users can contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).
