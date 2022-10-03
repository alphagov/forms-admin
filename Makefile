.PHONY: setup serve test test-watch lint db db-down

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

db:
	docker-compose up -d
clean:
	docker-compose down
