.PHONY: setup serve test test-watch lint

setup:
	bin/setup

serve: setup
	bin/dev

test: setup
	bundle exec bin/rake

#test-watch: setup
#	bundle exec guard -i --notify false -P rspec

lint:
	bundle exec rubocop -A
	bundle exec bundle-audit check
