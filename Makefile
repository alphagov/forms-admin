.PHONY: setup serve serve-watch test test watch lint lint-fix install db db-down

setup:
	bundle install

serve: setup
	bundle exec bin/rails s

test: setup
	bundle exec bin/rake

#test-watch: setup
#	bundle exec guard -i --notify false -P rspec

lint:
	bundle exec rubocop

lint-fix:
	bundle exec rubocop -A
db:
	docker-compose up -d
clean:
	docker-compose down