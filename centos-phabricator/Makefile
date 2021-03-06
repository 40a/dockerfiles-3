# Substitute your own Docker index username, if you like. 
# Database-related variables.
DB_DOCKER_USER=internavenue
DB_DOCKER_REPO_NAME=centos-percona:centos7
DB_CONTAINER_NAME:=lon-dev-db1

# Change this to suit your needs.
DB_USER:=super
DB_PASS:=Whatz03v3r

DB_PORT:=127.0.0.1:3306
DB_SSH_PORT:=127.0.0.1:2222

# These directories will be mounted in the containers.
DB_DATA_DIR:=/srv/docker/$(DB_CONTAINER_NAME)/mysql
DB_LOGS_DIR:=/srv/docker/$(DB_CONTAINER_NAME)/log
DB_RUN_DIR:=/srv/docker/$(DB_CONTAINER_NAME)/run

DB_RUNNING:=$(shell docker ps | grep "$(DB_CONTAINER_NAME) "| cut -f 1 -d ' ')
DB_ALL:=$(shell docker ps -a | grep "$(DB_CONTAINER_NAME) " | cut -f 1 -d ' ')

DB_DOCKER_RUN_COMMON=--name="$(DB_CONTAINER_NAME)" \
	-p $(DB_PORT):3306 \
	-p $(DB_SSH_PORT):22 \
	-v $(DB_DATA_DIR):/data \
	-v $(DB_RUN_DIR):/run \
	-v $(DB_LOGS_DIR):/var/log \
	-e USER="$(DB_USER)" -e PASS="$(DB_PASS)" $(DB_DOCKER_USER)/$(DB_DOCKER_REPO_NAME)


# Phabricator-related variables.

PH_DOCKER_USER=internavenue
PH_DOCKER_REPO_NAME=centos-phabricator:centos7

PH_PORT:=127.0.0.1:80

PH_DATA_DIR:=/srv/docker/$(PH_CONTAINER_NAME)/www
PH_REPO_DIR:=/srv/docker/$(PH_CONTAINER_NAME)/git
PH_LOGS_DIR:=/srv/docker/$(PH_CONTAINER_NAME)/log
PH_RUN_DIR:=/srv/docker/$(PH_CONTAINER_NAME)/run

PH_CONTAINER_NAME:=lon-dev-ph

PH_RUNNING:=$(shell docker ps | grep "$(PH_CONTAINER_NAME) " | cut -f 1 -d ' ')
PH_ALL:=$(shell docker ps -a | grep "$(PH_CONTAINER_NAME) " | cut -f 1 -d ' ')

PH_DOCKER_RUN_COMMON=--name="$(PH_CONTAINER_NAME)" -p $(PH_PORT):80 \
	-v $(PH_DATA_DIR):/srv/www/phabricator \
	-v $(PH_REPO_DIR):/srv/git \
	-v $(PH_LOGS_DIR):/var/log \
	-v $(PH_RUN_DIR):/var/log \
	--link $(DB_CONTAINER_NAME):mysql $(PH_DOCKER_USER)/$(PH_DOCKER_REPO_NAME)


all: build

ph_dir:
	mkdir -p $(PH_DATA_DIR)
	mkdir -p $(PH_REPO_DIR)
	mkdir -p $(PH_LOGS_DIR)

db_dir:
	mkdir -p $(DB_DATA_DIR)
	mkdir -p $(DB_RUN_DIR)
	mkdir -p $(DB_LOG_DIR)

clean: db_clean ph_clean

build:
	docker build -t="$(PH_DOCKER_USER)/$(PH_DOCKER_REPO_NAME)" .

ph_run: ph_clean ph_dir
	docker run -d $(PH_DOCKER_RUN_COMMON)

db_bash: clean
	mkdir -p $(DB_DATA_DIR)
	docker run -t -i $(DB_DOCKER_RUN_COMMON) /bin/bash

db_run: db_clean
	docker run -d $(DB_DOCKER_RUN_COMMON)
	# FIXME: at this stage we don't know that the access has been granted.
	sleep 5

run: db_run ph_run

bash: ph_clean db_clean db_run ph_dir
	docker run -t -i $(PH_DOCKER_RUN_COMMON) /bin/bash

PH_RUNNING:=$(shell docker ps | grep "$(PH_CONTAINER_NAME) " | cut -f 1 -d ' ')
PH_ALL:=$(shell docker ps -a | grep "$(PH_CONTAINER_NAME) " | cut -f 1 -d ' ')

db_clean:
ifneq ($(strip $(DB_RUNNING)),)
	docker stop $(DB_RUNNING)
endif
ifneq ($(strip $(DB_ALL)),)
	docker rm $(DB_ALL)
endif

ph_clean:
ifneq ($(strip $(PH_RUNNING)),)
	docker stop $(PH_RUNNING)
endif
ifneq ($(strip $(PH_ALL)),)
	docker rm $(PH_ALL)
endif

# Destroys the data directory.
ph_deepclean: ph_clean
	sudo rm -rf $(PH_DATA_DIR)
	sudo rm -rf $(PH_REPO_DIR)
	sudo rm -rf $(PH_LOGS_DIR)

