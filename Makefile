DOCKER_COMPOSE = srcs/docker-compose.yml
MY_VOLUMES_DIRS = ./srcs/data/mdb ./srcs/data/wp
VOLUMES_DIRS = /home/mvalerio/data/mariadb /home/mvalerio/data/wordpress

CONTAINER := $(filter-out exec,$(MAKECMDGOALS))

all: up

#Rebuilds the images, and, if the images changed, recreates the container.
up:
	mkdir -p $(VOLUMES_DIRS)
	docker compose -f $(DOCKER_COMPOSE) up -d --build

#Gets into the bash of a specific container
exec:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "Usage: make exec <container_name>"; \
	else \
		echo "Entering bash of container $(CONTAINER)..."; \
		docker exec -it $(CONTAINER) /bin/bash; \
	fi

#Stops and removes all containers, deletes images
clean:
	docker compose -f $(DOCKER_COMPOSE) down --rmi all
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

hosts:
	@echo "🛠  Adding mvalerio.42.fr to /etc/hosts..."
	@if ! grep -q "mvalerio.42.fr" /etc/hosts; then \
		echo "127.0.0.1 mvalerio.42.fr" | sudo tee -a /etc/hosts > /dev/null && \
		echo "✅  Added mvalerio.42.fr to /etc/hosts"; \
	else \
		echo "✅  mvalerio.42.fr already exists in /etc/hosts"; \
	fi

.phony: hosts migrate_data logs status start stop re ResetAll clean up all help