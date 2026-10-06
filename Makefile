
include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d postgres 

env-down:
	@docker compose down postgres 

env-cleanup:
	@read -p "Are you sure you want to remove the database volume? This action cannot be undone. (y/n): " confirm; \
	if [ "$$confirm" = "y" ]; then \
		docker compose down postgres && \
		rm -rf out/pgdata && \
		echo "Database volume removed."; \
	else \
		echo "Operation canceled."; \
	fi

migrate:
	@if [ -z "$(seq)" ]; then \
		echo "Error: Please provide a sequence number using the 'seq' variable."; \
		exit 1; \
	fi; \
	docker compose run --rm postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Error: Please provide an action using the 'action' variable."; \
		exit 1; \
	fi; \
	docker compose run --rm postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"

env-port-forwarder:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

