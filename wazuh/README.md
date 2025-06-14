# Wazuh Docker Certificate Generation Script/Image

This instructions are taken from the <a href="https://github.com/wazuh/wazuh-docker">Official Wazuh Docker Repo</a>. For our purposes only the first two steps are needed.

## Deploy Wazuh Docker in single node configuration

This deployment is defined in the `docker-compose.yml` file with one Wazuh manager containers, one Wazuh indexer containers, and one Wazuh dashboard container. It can be deployed by following these steps: 

1) Increase max_map_count on your host (Linux). This command must be run with root permissions:
```
$ sysctl -w vm.max_map_count=262144
```
2) Run the certificate creation script:
```
$ docker-compose -f generate-indexer-certs.yml run --rm generator
```
