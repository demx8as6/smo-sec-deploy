# SMO secure deployment

A project which ensures a secure deployment of an service management and orchestration framework.


### With Docker

From the project root:

```bash
docker compose -f docker/docker-compose.yaml up --build

Then visit:

http://smo.o-ran-sc.org:8080

http://smo.o-ran-sc.org:8080/ready


#
make gen-server-cert
certutil -A -n "SMO-OAM-CA" -t "TC,C,C" -i docker/traefik/tls/mydomain-ca.crt -d sql:$HOME/.pki/nssdb
restart or open broswer
