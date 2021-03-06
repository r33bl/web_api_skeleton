APP_NAME:= $(notdir $(CURDIR))
APP_ENV=local
COMPOSE_FILE=docker-compose-$(APP_ENV).yml

.PHONY: backend frontend

image:
	@docker build -t $(APP_NAME):latest-$(APP_ENV) .

start:
	@echo "== Starting $(APP_ENV) environment for $(APP_NAME) project"
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) up

start-build:
	@echo "== Rebuilding image and starting $(APP_ENV) environment for $(APP_NAME) project"
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) up --build

stop:
	@echo "== Stoping $(APP_ENV) environment for $(APP_NAME) project"
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) down

stop-v:
	@echo "== Stoping $(APP_ENV) environment and deleting database for $(APP_NAME) project"
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) down -v

stop-all:
	@echo "== Stoping $(APP_ENV) environment, deleting database and related images for $(APP_NAME) project"
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) down -v --rm all

restart:
	@echo "== Restarting $(APP_ENV) environment for $(APP_NAME) project"
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) down
	@cd envs/$(APP_ENV) && docker-compose -f $(COMPOSE_FILE) -p $(APP_NAME)_$(APP_ENV) up

new_app:
	@read -p "What will the new app be called: " app_name; \
	docker container exec $(APP_NAME)_$(APP_ENV)_backend_1 python manage.py startapp $$app_name
	@echo "App created"

migrations:
	@echo "== Creating migration file(s) in $(APP_ENV) environment for $(APP_NAME) project"
	@docker container exec $(APP_NAME)_$(APP_ENV)_backend_1 python manage.py makemigrations

migrate:
	@echo "== Applying migrations in $(APP_ENV) environment for $(APP_NAME) project"
	@docker container exec $(APP_NAME)_$(APP_ENV)_backend_1 python manage.py migrate

superuser:
	@echo "== Creating superuser in $(APP_ENV) environment for $(APP_NAME) project"
	@docker container exec -it $(APP_NAME)_$(APP_ENV)_backend_1 python manage.py createsuperuser

collectstatic:
	@echo "== Collecting staticfiles in $(APP_ENV) environment for $(APP_NAME) project"
	@docker container exec $(APP_NAME)_$(APP_ENV)_backend_1 python manage.py collectstatic

lint:
	@echo "== Starting style check in $(APP_ENV) environment for $(APP_NAME) project"
	@docker container exec $(APP_NAME)_$(APP_ENV)_backend_1 flake8

psql:
	@echo "== Entering $(APP_ENV) env's psql tty for $(APP_NAME) project"
	@echo "== Connecting to database"
	@docker container exec -it $(APP_NAME)_$(APP_ENV)_db_1 psql -U postgres postgres

abc:
	@echo docker container exec -it $(APP_NAME)_$(APP_ENV)_backend_1 bash
backend:
	@echo "== Entering $(APP_ENV) backend container for $(APP_NAME) project"
	@docker container exec -it $(APP_NAME)_$(APP_ENV)_backend_1 bash

frontend:
	@echo "== Entering $(APP_ENV) frontend container for $(APP_NAME) project"
	@docker container exec -it $(APP_NAME)_$(APP_ENV)_frontend_1 bash

docker-list:
	@echo "============ ALL CONTAINERS ============"
	@docker container ls -a
	@echo ""
	@echo "============ IMAGES ============"
	@docker image ls
	@echo ""
	@echo "============ NETWORKS ============"
	@docker network ls
	@echo ""
	@echo "============ VOLUMES ============"
	@docker volume ls
	@echo ""


#sound:
#	# usage: make sound=aaaaa
#	@echo "sound is $(sound)"