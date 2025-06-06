# Open Source SIEM-SOAR Stack
A fully containerized Security Information and Event Management (SIEM) and Security Orchestration, Automation, and Response (SOAR) lab environment designed for cybersecurity research, incident response automation, and threat detection experiments. A lab environment for exploring and integrating open-source SIEM and SOAR tools. This Docker-based setup includes Wazuh, Graylog, Shuffle, TheHive, Cortex, Velociraptor, Grafana, and supporting services.

## 🎯 Overview

This Docker-based security stack integrates multiple open-source tools to provide a complete security operations center (SOC) environment:

- **SIEM Capabilities**: Log collection, analysis, and correlation
- **SOAR Functionality**: Security orchestration and automated response
- **Threat Hunting**: Advanced endpoint detection and response
- **Visualization**: Real-time security dashboards and reporting

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
git clone https://github.com/your-username/siem-soar-lab.git
cd siem-soar-lab
```

### 2. Pre-Deployment Configuration

#### Generate Wazuh SSL Certificates

Secure communication requires SSL certificates for Wazuh components:

```bash
# Generate certificates using the official Wazuh script
docker compose -f wazuh/generate-indexer-certs.yml run --rm generate-certs

# Move certificates to the appropriate directory
mv generated-certs/* wazuh/config/wazuh_indexer_ssl_certs/
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

# Configure Wazuh-Graylog integration (required for secure communication)
./graylog/graylog-wrapper.sh

# Deploy Shuffle SOAR separately
cd shuffle && docker compose up -d && cd ..
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
> This option is particularly useful for practice environments and testing scenarios where you want to start fresh.


### 4. Verify Deployment

Check that all services are running:

```bash
# View running containers
docker ps

# Check service health
docker compose ps
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
docker compose ps

# View specific service logs
docker compose logs -f wazuh.manager
docker compose logs -f graylog
docker compose logs -f shuffle

# Monitor resource usage
docker stats
```

### Integration Testing

1. **Log Ingestion**: Verify logs are flowing from the test agent to Wazuh and Graylog
2. **Alert Generation**: Confirm security rules are triggering alerts
3. **SOAR Workflows**: Test automated response playbooks in Shuffle
4. **Incident Management**: Create and manage test incidents in TheHive

## 🔧 Troubleshooting

### Common Issues

**Services Not Starting**
```bash
# Check container logs
docker compose logs <service-name>

# Restart specific service
docker compose restart <service-name>
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
docker compose logs -f --tail=100
```

## 📚 Documentation

### Additional Resources

- [Wazuh Docker](https://github.com/wazuh/wazuh-docker)
- [Graylog Docker](https://github.com/Graylog2/graylog-docker)
- [TheHive Docker](https://github.com/StrangeBeeCorp/docker)
- [Shuffle Docker](https://github.com/Shuffle/Shuffle/tree/main)
- [Velociraptor Docker](https://github.com/weslambert/velociraptor-docker)

## 🎉 Post-Deployment

Congratulations! You've successfully deployed a complete SIEM-SOAR stack. After you've reached this point, you can take a short break to pat yourself on the back, it's all downhill from here on out.

Please make sure to create any necessary users in each of the tools for the integrations to work correctly.


## 📄 License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute this software for personal or commercial purposes, provided that the original copyright and license notice are included.

See [LICENSE](LICENSE) for full license text.



**Built with ❤️ for the cybersecurity community**

*Empowering security professionals with open-source tools and collaborative innovation.*
