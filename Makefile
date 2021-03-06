.PHONY: build

SHELL := /bin/bash
CONTAINERNAME_BACKEND=wagtail_vue_backend
IMAGENAME_BACKEND=wagtail_vue:backend
CONTAINERNAME_FRONTEND=wagtail_vue_frontend
IMAGENAME_FRONTEND=wagtail_vue:frontend

build: ## Build the Docker images
	docker-compose -p wagtail_vue build

up: build ## Bring the  Docker containers up
	docker-compose -p wagtail_vue up -d || echo 'Already up!'

upwin:  ## Bring the Docker container up for bash on ubuntu folk
	export WINDIR="$(subst /mnt/c,//c,$(CURDIR))/" && make up

lint: build ## Lint the python code.
	docker run -v $(CURDIR)/django:/app $(IMAGENAME_BACKEND) /bin/bash -c 'flake8 website'

down: ## Stop the backend Docker container
	docker-compose -p wagtail_vue stop

enter: ## Enter backend container
	docker exec -it $(CONTAINERNAME_BACKEND) /bin/bash

enter_fe: ## Enter frontend container
	docker exec -it $(CONTAINERNAME_FRONTEND) /bin/sh

clean: ## Stop and remove all Docker containers
	docker-compose down
