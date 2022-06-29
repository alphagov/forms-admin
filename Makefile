.PHONY: setup
setup:
	bin/setup

.PHONY: serve
serve: setup
	bin/dev

.PHONY: test
test:
	bundle exec rspec

.PHONY: lint
lint:
	bundle exec rubocop

.PHONY: lint-fix
lint-fix:
	bundle exec rubocop -A
