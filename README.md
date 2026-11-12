# ARES — Automated Resilient Enterprise Security

ARES is an infrastructure-as-code and secure infrastructure project designed for a fictional small software development company.

The project focuses on network segmentation, infrastructure automation, secure application deployment, access control, and infrastructure monitoring.

## Objectives

- Build an isolated and segmented enterprise lab on Proxmox.
- Enforce network security policies using OPNsense.
- Automate virtual machine provisioning with Terraform.
- Configure Linux systems using Ansible.
- Deploy DevSecApp and PostgreSQL using Docker Compose.
- Secure application traffic with HTTPS and Nginx.
- Enforce network-level and application-level access controls.
- Monitor critical services and document backup procedures.

## Architecture

The infrastructure is deployed on a Proxmox VE hypervisor. OPNsense provides routing and firewall enforcement between the internal network segments.

### Network segmentation

| VLAN | Name | Subnet | Gateway |
|---|---|---|---|
| 10 | IT-ADMIN | 10.20.10.0/24 | 10.20.10.1 |
| 20 | DEVELOPMENT | 10.20.20.0/24 | 10.20.20.1 |
| 30 | BUSINESS | 10.20.30.0/24 | 10.20.30.1 |
| 40 | SERVERS | 10.20.40.0/24 | 10.20.40.1 |

The network policy restricts inter-VLAN communications according to the role of each segment.

- IT-ADMIN provides authorized administrative access.
- DEVELOPMENT can access the DevSecApp application.
- BUSINESS is isolated from internal application and administration services.
- SERVERS hosts the application infrastructure.

## Infrastructure as Code

The infrastructure automation uses:

- **Terraform:** Proxmox virtual machine provisioning.
- **Cloud-Init:** Initial Debian virtual machine configuration.
- **Ansible:** Linux system configuration and base provisioning.

A Debian 13 Cloud-Init template is used to provision test virtual machines. Terraform and Ansible workflows have been validated on a dedicated test VM.

The complete configuration of the existing application server is not yet automated.

## Application platform

DevSecApp is deployed on the SERVERS VLAN.

| Component | Technology | Role |
|---|---|---|
| Application API | FastAPI | Application backend |
| Database | PostgreSQL 17 | Persistent data storage |
| Reverse proxy | Nginx | HTTPS termination and reverse proxy |
| Containers | Docker Compose | Application deployment |
| Monitoring | Uptime Kuma | Service availability monitoring |

The API is exposed only through the local loopback interface. Nginx provides the HTTPS entry point on the application server.

Application authorization distinguishes between IT and Developer roles. Access restrictions are enforced server-side.

## Security measures

- Inter-VLAN filtering enforced by OPNsense.
- Restricted access to administrative interfaces.
- PostgreSQL is not published directly on the host network.
- The application API listens only on loopback.
- HTTPS reverse proxy with TLS 1.2 and TLS 1.3.
- SSH administration using public-key authentication.
- Unnecessary system services disabled.
- Application authorization enforced server-side.
- Application secrets excluded from Git.
- Docker log rotation configured.

The current TLS certificate is self-signed and intended for the laboratory environment.

## Monitoring and backups

Uptime Kuma monitors:

- DevSecApp HTTPS health endpoint.
- Nginx TCP/443 availability.
- PostgreSQL TCP/5432 availability.

A PostgreSQL custom-format backup has been created and its archive integrity checked. A restoration test was successfully completed in a temporary database: the restored row count matched production and the sequence state was verified. Full Proxmox virtual machine backups remain outstanding.

## Repository structure

```text
.
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   └── roles/
├── docs/
│   ├── IA.md
│   ├── cahier-des-charges.md
│   ├── architecture.md
│   ├── infrastructure-as-code.md
│   ├── monitoring.md
│   ├── network-plan.md
│   ├── progress.md
│   └── security-policy.md
├── terraform/
├── ansible.cfg
├── .gitignore
└── README.md
```

## Project status — 12 November 2026

| Area | Status |
|---|---|
| Proxmox infrastructure | Deployed |
| OPNsense firewall | Configured and validated |
| VLAN segmentation | Configured and tested |
| DevSecApp deployment | Operational |
| HTTPS and Nginx | Configured and validated |
| Application authorization | Tested |
| Automated application tests | 24 passing |
| Terraform provisioning | Validated |
| Ansible configuration | Validated |
| Uptime Kuma monitoring | Operational |
| PostgreSQL backup and restoration | Archive integrity checked; temporary restore successful, with 1 row matching production |
| VPN remote access | Not yet deployed |
| Full Proxmox VM backups | Not yet configured |

## Documentation

- [Project specification](docs/cahier-des-charges.md)
- [Architecture](docs/architecture.md)
- [Network plan](docs/network-plan.md)
- [Security policy](docs/security-policy.md)
- [Infrastructure as Code](docs/infrastructure-as-code.md)
- [Monitoring](docs/monitoring.md)
- [Project progress](docs/progress.md)
- [AI usage journal](docs/IA.md)

## Future improvements

- Deploy and validate a VPN for secure remote access.
- Configure automated Proxmox virtual machine backups.
- Extend Terraform and Ansible automation to the application server.
- Replace the self-signed TLS certificate with a trusted certificate where appropriate.

---

ARES demonstrates a segmented enterprise lab combining network security, infrastructure automation, secure application deployment, access control, and service monitoring. Remaining improvements are explicitly documented and are not presented as completed features.
