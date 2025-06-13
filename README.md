# Open Source SIEM-SOAR Stack
A fully containerized Security Information and Event Management (SIEM) and Security Orchestration, Automation, and Response (SOAR) lab environment designed for cybersecurity research, incident response automation, and threat detection experiments. A lab environment for exploring and integrating open-source SIEM and SOAR tools. This Docker-based setup includes Wazuh, Graylog, Shuffle, TheHive, Cortex, Velociraptor, Grafana, and supporting services.

## 🎯 Overview

This Docker-based security stack integrates multiple open-source tools to provide a complete security operations center (SOC) environment:

### 🛠️ Included Components

| Component | Purpose | Version |
|-----------|---------|---------|
| **Wazuh** | Host-based intrusion detection system (HIDS) | `4.12.0` |
| **Graylog** | Log management and analysis platform | `6.2.2` |
| **Shuffle** | Security Orchestration, Automation and Response (SOAR) | Latest |
| **TheHive** | Incident response platform | Latest |
| **Cortex** | Security analysis engine | Latest |
| **Velociraptor** | Endpoint visibility and collection | Latest |
| **Grafana** | Monitoring and observability dashboards | Latest |

> **Note**: The stack includes a **custom Linux agent container** specifically designed for testing and validation purposes.
## 📋 Prerequisites

### System Requirements

- **Operating System**: Linux (recommended) or macOS
- **Memory**: Minimum 16GB RAM (32GB+ recommended)
- **Storage**: At least 50GB free disk space
- **Network**: Internet access for pulling Docker images

### Software Dependencies

- [Docker](https://docs.docker.com/get-docker/) (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0+)

> ⚠️ **Performance Note**: Running the complete stack on 16GB RAM may result in performance degradation. Consider deploying individual components separately for resource-constrained environments.

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone git@github.com:KLYMS/SIEM-SOAR.git
cd SIEM-SOAR
```

### 2. Pre-Deployment Configuration

#### Generate Wazuh SSL Certificates
Instructions for running this container/script can be found in the <a href="https://github.com/wazuh/wazuh-docker">Official Wazuh Docker Repo</a> and also under the specific subdirectory.
Secure communication requires SSL certificates for Wazuh components:

```bash
# Generate certificates using the official Wazuh script
cd wazuh/
docker-compose -f generate-indexer-certs.yml run --rm generate-certs
```

#### Configure TLS for TheHive & Cortex
 **Auto-Generated Certificates**
- The deployment will automatically generate certificates using the included `cert-gen.sh` script

#### Environment Configuration

1. Copy and customize your environment file in its specific directory:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to match your environment:
   - Update passwords and Ports
   - Configure network settings
   - Set resource limits


## 🔧 Management Commands

### Starting the Stack

```bash
# Deploy all services (except Shuffle)
./scripts/up.sh -d

# Deploy Shuffle SOAR separately
cd shuffle && docker compose up -d && cd ..

# Configure Wazuh-Graylog integration (required for secure communication)
./graylog/graylog-wrapper.sh
```

### Stopping and Cleanup

```bash
# Stop all containers (preserves data and configurations)
./scripts/cleanup.sh

# Complete cleanup - removes containers, volumes, and generated data
./scripts/cleanup.sh --del-all
```

> ⚠️ **Important**: The `--del-all` option will permanently delete:
> - All Docker containers and images
> - Persistent volumes and stored data
> - Generated logs in service directories
> - Configuration files created during deployment
> 
> This option is handy for practice environments and testing scenarios where you want to start fresh.


### 4. Verify Deployment

Check that all services are running:

```bash
# View running containers
docker ps

# Check service health
docker-compose ps
```

## 🌐 Service Access

| Service | URL | Default Credentials | Purpose |
|---------|-----|-------------------|---------|
| **Wazuh Dashboard** | http://localhost:5601 | `admin / SecretPassword` | SIEM dashboard and management |
| **Graylog** | http://localhost:9000 | `admin / password` | Log management interface |
| **Grafana** | http://localhost:3000 | `admin / password` | Metrics and visualization |
| **Shuffle** | http://localhost:3443 | *Set on first run* | SOAR workflow management |
| **TheHive** | http://localhost/thehive | `admin@thehive.local / secret` | Incident response platform |
| **Cortex** | http://localhost/cortex | *Set on first run* | Analysis engine |
| **Velociraptor** | http://localhost:8889 | `admin / admin` | Endpoint response platform |

> 🔐 **Security Notice**: Change all default passwords immediately after deployment for production use.
> ⚙️ **Custom Configuration Notice**: If you have modified the `.env` file with custom ports, domains, or credentials, the URLs and passwords above may not apply. Please refer to your customized `.env` settings for the correct access information.

## 🧪 Testing and Validation

### Health Checks

Verify component functionality:

```bash
# Check all services status
docker ps

# View specific service logs
docker logs -f wazuh.manager
docker logs -f graylog
docker logs -f shuffle

# Monitor resource usage
docker stats
```

## 🔧 Troubleshooting

### Common Issues

**Services Not Starting**
```bash
# Check container logs
docker logs <service-name>

# Restart a specific service
docker restart <service-name>
```

**Memory Issues**
- Reduce the number of concurrent services
- Increase Docker memory allocation
- Consider using Docker swarm for distributed deployment

**Certificate Problems**
- Regenerate certificates using the provided scripts
- Verify certificate paths in configuration files
- Check file permissions on certificate directories

### Log Analysis

Monitor service health through logs:

```bash
# Real-time log monitoring
docker logs -f <service-name> --tail=100
```

## 📚 Documentation

### Additional Resources

- [Wazuh Docker](https://github.com/wazuh/wazuh-docker)
- [Graylog Docker](https://github.com/Graylog2/graylog-docker)
- [TheHive Docker](https://github.com/StrangeBeeCorp/docker)
- [Shuffle Docker](https://github.com/Shuffle/Shuffle/tree/main)
- [Velociraptor Docker](https://github.com/weslambert/velociraptor-docker)

## 🎉 Post-Deployment

Congratulations! You've successfully deployed a complete SIEM-SOAR stack. After you've reached this point, you can take a short break to pat yourself on the back; it's all downhill from here on out.

Please ensure that you create any necessary users in each of the tools for the integrations to function correctly.


## 📄 License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute this software for personal or commercial purposes, provided that the original copyright and license notice are included.

See [LICENSE](LICENSE) for full license text.



**Built with ❤️ for the cybersecurity community**
