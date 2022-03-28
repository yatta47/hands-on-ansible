#
# Environment Variables
#

#
# Default Rules
#

#
# Build Rules
#

.PHONY: build
build:
	@docker build --target ansible -t handson-ansible:latest -f Dockerfile .
	@docker build --target node -t handson-node:latest -f Dockerfile .

.PHONY: up
up: down
	@docker-compose up -d

.PHONY: log
log:
	@docker-compose logs

.PHONY: down
down:
	@docker-compose down

.PHONY: login
login:
	@docker-compose exec ansible /bin/bash

.PHONY: clean
clean: down
	@docker system prune -f
	@docker volume prune -f