COMPOSE_PATH = ./srcs/docker-compose.yml

all :
	make build
	make up

build:
	@if [ ! -d "../data/volume1" ]; then \
		mkdir -p "../data/volume1"; \
	fi
	@if [ ! -d "../data/volume2" ]; then \
		mkdir -p "../data/volume2"; \
	fi
	@docker-compose -f $(COMPOSE_PATH) build

up :
	@docker-compose -f $(COMPOSE_PATH) up -d

down :
	@docker-compose -f $(COMPOSE_PATH) down -v

stop :
	@docker compose -f $(COMPOSE_PATH) stop

clean : stop down
	@CONTAINERS=$$(docker ps -aq); \
	if [ -n "$$CONTAINERS" ]; then \
		echo "Removing all containers..."; \
		docker rm -f $$CONTAINERS; \
	fi

fclean: clean
	@docker system prune -af

downup: down up

re: fclean all

.PHONY : all build up down stop clean fclean downup re