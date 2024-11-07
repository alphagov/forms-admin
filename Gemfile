source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "7.2.1.1"

gem "activeresource", "~> 6.1"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4.3"

# Used for handling authentication
gem "gds-sso"
gem "omniauth-auth0"
gem "omniauth-rails_csrf_protection"
gem "warden"

# Used for handling authorisation policies
gem "pundit"

# Use Sentry (https://sentry.io/for/ruby/?platform=sentry.ruby.rails#)
gem "sentry-rails"
gem "sentry-ruby"

gem "config"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo"
gem "tzinfo-data"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# For compiling our frontend assets
gem "vite_rails"

# For GOV.UK branding
gem "govuk-components"
gem "govuk_design_system_formbuilder"

# The autocomplete component is not currently published as a gem, if changing
# the hash, also change in package.json
gem "dfe-autocomplete", require: "dfe/autocomplete", github: "DFE-Digital/dfe-autocomplete", ref: "11738c0e25778162e26eb7ab5e22a6ffce671b08"

# Our own custom markdown renderer
gem "govuk-forms-markdown", require: "govuk_forms_markdown", github: "alphagov/govuk-forms-markdown", tag: "0.5.0"

# For structured logging
gem "lograge"

# Use GOV.UK Nofity api to send emails
gem "govuk_notify_rails"

# Use validate_url so we don't have to write custom URL validation
gem "validate_url"

# For auditing tables
gem "paper_trail"

# For AWS interactions
gem "aws-sdk-cloudwatch", "~> 1.105"
gem "aws-sdk-codepipeline", "~> 1.89"

# For Mailchimp audience integration
gem "MailchimpMarketing", "~> 3.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]

  gem "factory_bot_rails"
  gem "faker"

  gem "i18n-tasks", "~> 1.0.14"
  gem "rails-controller-testing"
  gem "rspec-rails", ">= 3.9.0"
  gem "rubocop-govuk", require: false

  # For security auditing gem vulnerabilities. RUN IN CI
  gem "bundler-audit", "~> 0.9.2"

  # For detecting security vulnerabilities in Ruby on Rails applications via static analysis.
  gem "brakeman", "~> 6.2.2"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  gem "pundit-matchers"

  # Code coverage reporter
  gem "simplecov", "~> 0.22.0", require: false

  gem "webmock"

  # axe-core for running automated accessibility checks
  gem "axe-core-rspec"
end
