DOCKER_COMPOSE = srcs/docker-compose.yml
MY_VOLUMES_DIRS = ./srcs/data/mdb ./srcs/data/wp
VOLUMES_DIRS = /home/margarida/data/mariadb /home/margarida/data/wordpress

CONTAINER := $(filter-out exec,$(MAKECMDGOALS))

all: up

up:
	mkdir -p $(VOLUMES_DIRS)
	docker compose -f $(DOCKER_COMPOSE) up -d --build

exec:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "Usage: make exec <container_name>"; \
	else \
		echo "Entering bash of container $(CONTAINER)..."; \
		docker exec -it $(CONTAINER) /bin/bash; \
	fi

clean:
	docker compose -f $(DOCKER_COMPOSE) down --rmi all

ResetAll: 
	docker compose -f $(DOCKER_COMPOSE) down --rmi all -v
	rm -rf $(VOLUMES_DIRS)

re: clean up

stop:
	docker compose -f $(DOCKER_COMPOSE) stop

start:
	docker compose -f $(DOCKER_COMPOSE) start

status:
	docker ps

logs:
	docker compose -f $(DOCKER_COMPOSE) logs

migrate_data:
	@echo "📦 Copying Wordpress files..."
	cp -a ./srcs/data/wp/html/. /home/margarida/data/wordpress/
	chown -R www-data:www-data /home/margarida/data/wordpress
	@echo "🗄 Importing MariaDB dump into container..."
	@sh -c '\
		DB_PASS=$$(grep DB_ROOT_PASSWORD ./srcs/.env | cut -d "=" -f2); \
		DB_NAME=$$(grep MYSQL_DATABASE ./srcs/.env | cut -d "=" -f2); \
		cat ./srcs/data/wordpress.sql | docker exec -i mariadb mariadb -u root -p$$DB_PASS $$DB_NAME \
	'
hosts:
	@echo "🛠  Adding margarida.42.fr to /etc/hosts..."
	@if ! grep -q "margarida.42.fr" /etc/hosts; then \
		echo "127.0.0.1 margarida.42.fr" | sudo tee -a /etc/hosts > /dev/null && \
		echo "✅  Added margarida.42.fr to /etc/hosts"; \
	else \
		echo "✅  margarida.42.fr already exists in /etc/hosts"; \
	fi
	
help:


.phony: hosts migrate_data logs status start stop re ResetAll clean up all help