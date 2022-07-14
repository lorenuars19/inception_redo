DOCKER = docker
DOCKERCP = $(DOCKER) compose
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env_config
SECR_ENV_FILE = srcs/.env_secret

LOG_FILE= .log

DOCKERCP += -p inception --project-directory ./srcs/ -f ./srcs/docker-compose.yml --env-file $(ENV_FILE)

SHELL=/bin/bash

define get_passwd
@if [[ ! -f $(SECR_ENV_FILE) ]]; then touch $(SECR_ENV_FILE); fi ;\
if [[ -f $(SECR_ENV_FILE) ]];then export $$(cat $(SECR_ENV_FILE) | xargs ) 2>&1 >/dev/null; fi ;\
while [[ -z "$${${1}}" ]] ;do \
	echo "Please Enter [${1}] Password : " ;\
	read ${1} ;\
	echo "${1}=$${${1}}" >> $(SECR_ENV_FILE) ;\
	if [[ -f $(SECR_ENV_FILE) ]];then export $$(cat $(SECR_ENV_FILE) | xargs) 2>&1 >/dev/null; fi ;\
	cat $(SECR_ENV_FILE) ;\
	done
endef

all: set_password down up

test:
	sudo rm -rf ./data/
	mkdir -p ./data/
	# mkdir -p ./data/www
	# mkdir -p ./data/mysql
	docker build . -t test && docker run -v $(shell pwd)/data/www/:/www/ -v $(shell pwd)/data/mysql:/var/lib/mysql/ -it --privileged -p'443:443' test "/bin/zsh"



up:
	mkdir -p $(HOME)/data
	$(DOCKERCP) up --detach --build --wait
	@-URL=http://localhost:80 ;\
	URLSSL=https://localhost:443 ;\
	echo $${URL} ;\
	echo $${URLSSL} ;\
	curl $${URL} ;\
	curl -k $${URLSSL} ;

# volumes:
# 	@mkdir -p /home/gregoire/data/wordpress
# 	@mkdir -p /home/gregoire/data/mariadb

force: down re
	$(DOCKERCP) up --detach --build --wait --force-recreate

down:
	$(DOCKERCP) down --rmi all --volumes --remove-orphans
	rm -rf $(HOME)/data

set_password:
	$(call get_passwd,MY_SQL_ROOT_PASWD)
	$(call get_passwd,WP_DB_PSWD)
	$(call get_passwd,ROOT_PASWD)
	$(call get_passwd,WP_ADMIN_PASWD)
	$(call get_passwd,WP_EDIT_PASWD)

	# $(DOCKERCP) config > $(LOG_FILE)_dockercp_config

ifeq (cp,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
cp:
	$(DOCKERCP) $(filter-out $@, $(MAKECMDGOALS))

ips:
	$(DOCKER) ps -a
	-if [[ ! -z $$(docker ps -aq) ]];then $(DOCKER) inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress }}' $(shell docker ps -aq); fi

list :
	$(DOCKER) images

stop :
	-if [[ ! -z $$(docker ps -aq) ]];then $(DOCKER) stop $(shell docker images -q) ;fi

kill:
	-if [[ ! -z $$(docker ps -aq) ]];then $(DOCKER) kill $(shell docker ps -aq) ;fi

rm_all:
	-if [[ ! -z $$(docker images -q) ]];then $(DOCKER) image rm -f $(shell docker images -q) ;fi

clr: stop kill rm_all
	$(DOCKER) system prune -f
	$(DOCKER) image prune -f
	$(DOCKER) volume prune -f
	$(DOCKER) container prune -f
	$(DOCKER) builder prune -f

re: clr all
