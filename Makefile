
# -------------------------------------------------------------------------
# [Variables]
# -------------------------------------------------------------------------
ifneq (,$(wildcard ./docker/.env))
  include ./docker/.env
  export
endif

VENV_DIR := .venv
PYTHON := $(VENV_DIR)/bin/python
PIP := $(VENV_DIR)/bin/pip
UVICORN := $(VENV_DIR)/bin/uvicorn
APP := src.main:app

ACTIVATE = . .venv/bin/activate
DOCKER_COMPOSE_FILES = $(shell find docker/ -name "docker-compose*.yaml" | sort | sed 's/^/-f /')
DOCKER_COMPOSE = docker compose $(DOCKER_COMPOSE_FILES)


.PHONY: all venv install run stop clean system-check deploy teardown status logs rebuild certs clean-certs

all: run ## [Dev] Default target

venv: # [Dev] Create virtual environment
	@test -d $(VENV_DIR) || python3 -m venv $(VENV_DIR)

install: venv ## [Dev] Install dependencies
	$(PIP) install --upgrade pip
	$(PIP) install -r src/requirements.txt

run: install ## [Dev] Run the FastAPI server
	$(UVICORN) $(APP) --reload --host 0.0.0.0 --port 8080

stop: ## [Dev] Kill running uvicorn process (based on pattern)
	pkill -f "uvicorn.*$(APP)" || echo "No uvicorn process found."


clean: ## [Dev] Clean virtualenv and __pycache__
	rm -rf $(VENV_DIR) __pycache__ src/__pycache__
	$(DOCKER_COMPOSE) down

# -------------------------------------------------------------------------
# [Deployment]
# -------------------------------------------------------------------------

deploy: ## [Deployment] Deploy all services
	$(DOCKER_COMPOSE) up -d

teardown: ## [Deployment] Stop and remove all containers, mydomain, etc.
	$(DOCKER_COMPOSE) down

status: ## [Deployment] Show status of running services
	$(DOCKER_COMPOSE) ps -a --format "table {{.Name}}\t{{.Image}}\t{{.Status}}"

logs: ## [Deployment] Print last 100 lines of logs
	$(DOCKER_COMPOSE) logs -f --tail=100

rebuild: ## [Deployment] Rebuild and start the containers
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d --force-recreate


# -------------------------------------------------------------------------
# [Certs]
# -------------------------------------------------------------------------

# --- TLS Self-Signed Certificate Generation ---
CERT_DIR := docker/traefik/tls
CA_KEY := $(CERT_DIR)/ca.key.pem
CA_CERT := $(CERT_DIR)/ca.cert.pem
TRAEFIK_KEY := $(CERT_DIR)/traefik.key.pem
TRAEFIK_CSR := $(CERT_DIR)/traefik.csr.pem
TRAEFIK_CERT := $(CERT_DIR)/traefik.cert.pem

certs: $(CA_KEY) $(CA_CERT) $(TRAEFIK_KEY) $(TRAEFIK_CERT)

$(CERT_DIR):
	mkdir -p $(CERT_DIR)

$(CA_KEY) $(CA_CERT): | $(CERT_DIR)
	openssl genrsa -out $(CA_KEY) 4096
	openssl req -x509 -new -nodes -key $(CA_KEY) -sha256 -days 3650 -out $(CA_CERT) -subj "/CN=SMO Local CA"

$(TRAEFIK_KEY) $(TRAEFIK_CSR): | $(CERT_DIR)
	openssl genrsa -out $(TRAEFIK_KEY) 2048
	openssl req -new -key $(TRAEFIK_KEY) -out $(TRAEFIK_CSR) -subj "/CN=localhost"

$(TRAEFIK_CERT): $(TRAEFIK_CSR) $(CA_CERT) $(CA_KEY)
	openssl x509 -req -in $(TRAEFIK_CSR) -CA $(CA_CERT) -CAkey $(CA_KEY) -CAcreateserial \
	-out $(TRAEFIK_CERT) -days 825 -sha256

clean-certs:
	rm -rf $(CERT_DIR)

# -------------------------------------------------------------------------
# [System]
# -------------------------------------------------------------------------

system-check: hello ## [System] Get an overview of the system
	@echo "## Get an overview of the system"
	@cat /etc/os-release | grep -i pretty
	@docker version
	@docker compose version
	@git --version
	@python3 --version
	@go version
	@timedatectl
	@echo "  Domain: ${HTTP_DOMAIN}"
	@echo "Identity: ${IDENTITY_PROVIDER_URL}"

# -------------------------------------------------------------------------
# [Help]
# -------------------------------------------------------------------------

TEXT_FILE := banner.txt
hello: ## [Help] Displays a banner
	@echo "Reading lines from $(TEXT_FILE):"
	@while IFS= read -r line; do \
		echo "$$line"; \
	done < $(TEXT_FILE)

help: hello ## [Help] Show this help
	@echo ""
	@echo "Available Make targets:"
	@awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## / { \
		split($$2, parts, "] "); \
		group = substr(parts[1], 2); \
		desc = parts[2]; \
		if (group != last_group) { \
			printf "\n\033[1m[%s]\033[0m\n", group; \
			last_group = group; \
		} \
		printf "  \033[36m%-25s\033[0m %s\n", $$1, desc \
	}' $(MAKEFILE_LIST)
	@echo ""
