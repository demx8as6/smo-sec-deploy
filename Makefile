
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


.PHONY: all venv install run stop clean system-check deploy teardown status logs rebuild gen-ca gen-server-cert clean-certs

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
SERVICES = gateway traefik keycloak oauth2-proxy test-service identity minio massages kafka-ui odlux.oam flows.oam test.oam controller.dcn ves-collector.dcn
CERT_DIR := docker/traefik/tls

$(CERT_DIR): ## [Security] Create directory for certificates
	mkdir -p $(CERT_DIR)

gen-ca: $(CERT_DIR) ## [Security] Generate root CA certificate for Gateway
	@echo "Generating CA private key..."
	@mkdir -p $(CERT_DIR)
	@openssl genrsa -out $(CERT_DIR)/mydomain-ca.key 4096
	@echo "Generating CA certificate..."
	@openssl req -x509 -new -nodes -key $(CERT_DIR)/mydomain-ca.key \
		-sha256 -days 3650 \
		-subj "/CN=GatewayRootCA" \
		-out $(CERT_DIR)/mydomain-ca.crt

gen-server-cert: gen-ca  ## [Security] Generate server cert signed by the above CA
	@echo "Generating server private key..."
	@openssl genrsa -out $(CERT_DIR)/mydomain.key 4096

	@echo "[ req ]" > $(CERT_DIR)/openssl-san.conf
	@echo "default_bits = 4096" >> $(CERT_DIR)/openssl-san.conf
	@echo "prompt = no" >> $(CERT_DIR)/openssl-san.conf
	@echo "distinguished_name = req_distinguished_name" >> $(CERT_DIR)/openssl-san.conf
	@echo "req_extensions = v3_req" >> $(CERT_DIR)/openssl-san.conf
	@echo "" >> $(CERT_DIR)/openssl-san.conf
	@echo "[ req_distinguished_name ]" >> $(CERT_DIR)/openssl-san.conf
	@echo "CN = ${HTTP_DOMAIN}" >> $(CERT_DIR)/openssl-san.conf
	@echo "" >> $(CERT_DIR)/openssl-san.conf
	@echo "[ v3_req ]" >> $(CERT_DIR)/openssl-san.conf
	@echo "subjectAltName = @alt_names" >> $(CERT_DIR)/openssl-san.conf
	@echo "basicConstraints = critical,CA:FALSE" >> $(CERT_DIR)/openssl-san.conf
	@echo "" >> $(CERT_DIR)/openssl-san.conf
	@echo "[ alt_names ]" >> $(CERT_DIR)/openssl-san.conf
	@echo "DNS.1 = ${HTTP_DOMAIN}" >> $(CERT_DIR)/openssl-san.conf

	$(eval n=2)
	@for s in $(SERVICES); do \
		echo "DNS.$$n = $$s.$(HTTP_DOMAIN)" >> $(CERT_DIR)/openssl-san.conf; \
		n=$$((n+1)); \
	done

	@echo "Generating CSR..."
	@openssl req -new -key $(CERT_DIR)/mydomain.key \
		-out $(CERT_DIR)/mydomain.csr \
		-config $(CERT_DIR)/openssl-san.conf

	@echo "Signing server cert with CA..."
	@openssl x509 -req -in $(CERT_DIR)/mydomain.csr \
		-CA $(CERT_DIR)/mydomain-ca.crt -CAkey $(CERT_DIR)/mydomain-ca.key -CAcreateserial \
		-out $(CERT_DIR)/mydomain.crt -days 825 -sha256 \
		-extfile $(CERT_DIR)/openssl-san.conf -extensions v3_req

	@echo "Server certificate with SANs generated at $(CERT_DIR)/mydomain.crt"
	@echo "CA certificate generated at $(CERT_DIR)/mydomain-ca.crt"

trust: ## [Security] Add the generated certificate to your local ubuntu system for easy browsing
	certutil -A -n "SMO-OAM-CA" -t "TC,C,C" -i docker/traefik/tls/mydomain-ca.crt -d sql:$HOME/.pki/nssdb

clean-certs: ## [Security] Delete directory with generated certs and keys
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
