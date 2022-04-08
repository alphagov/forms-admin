# GOV.UK Forms Admin

GOV.UK Forms is a service for creating forms. GOV.UK Forms Admin is a an application to handle the administration, design and publishing of those forms. It's a Ruby on Rails application built on a PostgreSQL database.

## Before you start

To run the project you will need to install:

- [Ruby](https://www.ruby-lang.org/en/) - we use version 3 of Ruby. Before running the project, double check the [.ruby-version] file to see the exact version.
- [Node.js](https://nodejs.org/en/) - the frontend build requires Node.js. We use Node 16 LTS versions.
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
# 2. Install the ruby dependencies
bundle install
# 3. Install the node dependencies
yarn
# 4. Run the frontend build task
npm run build
```

### Running the app

You can either run the development task:

```bash
# Run the foreman dev server and start the frontend dev task
bin/dev
```

or run the rails server:

```bash
# Run a local Rails server
bin/rails server
# When running the server, you can use any of the frontend tasks, e.g.:
yarn dev
```

## Configuration and deployment

TODO: Add these details once we've got our deployment running.

## Explain how to test the project

```bash
# Run the Ruby test suite
bin/rake
# To run the Javascript test suite, run
yarn test
# To run the end-to-end tests, run
yarn cypress
```

## Support

Raise a Github issue if you need support.

## Explain how users can contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).
