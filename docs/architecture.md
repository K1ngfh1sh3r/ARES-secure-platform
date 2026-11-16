# ARES — Architecture

## 1. Project Overview

ARES (Automated Resilient Enterprise Security) is a virtualized and segmented infrastructure designed to host and secure the DevSecApp application.

The project combines network segmentation, firewall filtering, Infrastructure as Code, configuration management, containerized services, HTTPS access, monitoring, and database backup and restoration.

This document describes the infrastructure as it is currently deployed and tested, rather than an initial target architecture.

## 2. Physical and Virtual Infrastructure

### 2.1. Proxmox Environment

The infrastructure runs on a MiniForum host using Proxmox VE.

The host has two physical Ethernet interfaces connected to two Linux bridges:

| Interface | Bridge | Role |
|---|---|---|
| `nic0` | `vmbr0` | WAN / domestic network connectivity |
| `nic1` | `vmbr1` | Internal ARES network and VLAN connectivity |

Proxmox management is available on the domestic network:

- Proxmox node: `pve`
- Management address: `192.168.1.70`
- Web interface: `https://192.168.1.70:8006`

The Proxmox management interface is not intended to be exposed directly to the Internet.

### 2.2. Virtual Machine Inventory

The following virtual machines and templates are currently present:

| VM ID | Name | Role |
|---|---|---|
| 100 | `ares-opnsense` | Firewall, routing and network filtering |
| 101 | `ares-test-vlan20` | Development VLAN test machine |
| 102 | `ares-app-vlan40` | Application and monitoring server |
| 130 | `ares-test-vlan30` | BUSINESS VLAN test machine |
| 140 | `ares-tf-test` | Terraform and Ansible provisioning test machine |
| 9000 | `debian-13-cloudinit-template` | Debian 13 Cloud-Init template |

VM 102 hosts the application stack. VM 140 is used to validate automated provisioning independently of the production-like application server.

The inventory may evolve as the infrastructure is extended.

## 3. Network Architecture

### 3.1. Network Topology

The network is organized around OPNsense, which acts as the central firewall and routing point for the ARES internal network.

The physical and logical topology is represented below:

                    Domestic Network
                           |
                      Home Router
                           |
                    Physical nic0
                           |
                         vmbr0
                           |
                  +------------------+
                  |     OPNsense     |
                  |      VM 100      |
                  |                  |
                  | WAN          LAN |
                  +------------------+
                                  |
                                vmbr1
                                  |
                       Internal ARES Network
                                  |
              +-----------------+-----------------+
              |                 |                 |
           VLAN 10           VLAN 20           VLAN 30           VLAN 40
           IT-ADMIN        DEVELOPMENT         BUSINESS          SERVERS
              |                 |                 |                 |
       Administration        VM 101          Test host            VM 102
                            10.20.20.10      10.20.30.110      10.20.40.10
                              VM 140
                            10.20.20.20
                                                                  |
                                                            +-----------+
                                                            |  Nginx    |
                                                            | DevSecApp |
                                                            | PostgreSQL|
                                                            | Uptime    |
                                                            | Kuma      |
                                                            +-----------+

The four VLANs are separate logical network segments connected through the internal network infrastructure and managed by OPNsense.

The diagram represents the logical architecture. Actual connectivity and access between segments are controlled by firewall rules.

### 3.2. VLAN Addressing Plan

The internal network is divided into four VLANs:

| VLAN ID | Name | Network | Purpose |
|---|---|---|---|
| 10 | IT-ADMIN | `10.20.10.0/24` | IT and infrastructure administration |
| 20 | DEVELOPMENT | `10.20.20.0/24` | Development workstations and testing |
| 30 | BUSINESS | `10.20.30.0/24` | Business users |
| 40 | SERVERS | `10.20.40.0/24` | Application and infrastructure services |

Each VLAN uses its own IP subnet. Inter-VLAN communication is controlled by OPNsense.

### 3.3. Test Machines

Several machines are used to validate the network and automation:

- VM 101 (`10.20.20.10`) is used for development network testing.
- VM 140 (`10.20.20.20`) is used to validate Terraform provisioning and Ansible configuration.
- The BUSINESS test virtual machine at `10.20.30.110` is used to verify that unauthorized access to application services is blocked.

These test systems are not application production services.

## 4. OPNsense Firewall and Network Filtering

### 4.1. Firewall Role

OPNsense runs as VM 100 and provides the central network security functions:

- Routing between the internal network segments.
- Filtering of traffic between VLANs.
- Control of access to application services.
- Control of administrative and infrastructure traffic.
- Network access restrictions based on source, destination and service.

The firewall is a central security component of the ARES architecture.

### 4.2. Network Access Policy

The network follows a restrictive access model.

The main principles are:

- Development users can access the application through authorized HTTPS traffic.
- Business users are not authorized to access the DevSecApp interface.
- Direct access to PostgreSQL from user VLANs is not permitted.
- Administrative access is restricted to authorized sources and services.
- Other inter-VLAN communications are denied by default unless explicitly authorized by a firewall rule.

### 4.3. Network Filtering Validation

A network access test was performed from the BUSINESS test host:

- Source: `10.20.30.110`
- Destination: `10.20.40.10`
- Destination port: TCP `443`

The connection was refused as expected.

This confirms that the BUSINESS network cannot directly access the DevSecApp HTTPS service under the tested conditions.

Additional network tests are documented in the network plan and project progress documentation.

## 5. Application Infrastructure

### 5.1. Application Server

The DevSecApp application is deployed on VM 102.

| Property | Value |
|---|---|
| VM ID | 102 |
| Hostname | `ares-app-vlan40` |
| Operating system | Debian 13 |
| IP address | `10.20.40.10` |
| Application directory | `/opt/devsecapp` |

The server belongs to the SERVERS network (VLAN 40).

### 5.2. Application Stack

The application stack is composed of the following services:

| Component | Role |
|---|---|
| FastAPI | Application API |
| PostgreSQL 17 | Application database |
| Docker | Container runtime |
| Docker Compose | Service orchestration |
| Nginx | HTTPS reverse proxy |

The API and database run in Docker containers managed through Docker Compose.

The API is bound to the local host interface on port `8000`, so it is not directly exposed to the internal network.

Nginx acts as the HTTPS entry point and forwards authorized requests to the API.

PostgreSQL is accessible internally by the application service and is not directly published as a host network service.

### 5.3. HTTPS Access

The application is accessible through:

`https://10.20.40.10`

Nginx handles TLS termination and forwards requests to the FastAPI service.

The current deployment uses a self-signed TLS certificate. HTTPS is operational, but the certificate is not issued by a publicly trusted Certificate Authority.

A trusted certificate remains a possible improvement.

### 5.4. Application Validation

The following endpoints have been tested:

| Endpoint | Purpose | Result |
|---|---|---|
| `/health` | Application health check | HTTP 200 |
| `/docs` | API documentation | HTTP 200 |
| `/api/vulnerabilities` | Vulnerability API | HTTP 200 |

The application is deployed and accessible through the reverse proxy.

## 6. Monitoring

### 6.1. Uptime Kuma

Uptime Kuma is deployed on VM 102 to monitor the availability of the application infrastructure.

Its web interface is available internally at:

`http://10.20.40.10:3001`

The monitoring service uses persistent storage and is connected to the application Docker network.

### 6.2. Configured Monitors

The following monitors are configured:

| Monitor | Target | Purpose |
|---|---|---|
| DevSecApp HTTPS | `https://10.20.40.10/health` | Application availability |
| Nginx TCP | Port `443` | Reverse proxy availability |
| PostgreSQL TCP | Port `5432` | Database service availability |

These checks provide basic visibility into the availability of the application stack.

The monitoring configuration and screenshots are documented in `docs/monitoring.md`.

## 7. Backup and Restoration

### 7.1. PostgreSQL Backup

A PostgreSQL backup procedure has been implemented using `pg_dump`.

The database is exported using PostgreSQL custom-format archives.

Backup files are stored in:

`/var/backups/ares/devsecapp`

The backup directory is restricted to the root user.

### 7.2. Restoration Validation

A real PostgreSQL restoration test was successfully performed on 12 November 2026.

The backup was restored into an independent temporary database.

The restored data and database sequence state were checked successfully.

This validates the database backup and restoration procedure.

### 7.3. Remaining Backup Limitations

The current backup procedure covers the PostgreSQL application database.

Full Proxmox virtual machine backup and restoration procedures have not yet been implemented and tested.

They remain planned infrastructure improvements.

## 8. Infrastructure as Code

### 8.1. Terraform

Terraform is used to automate virtual machine provisioning on Proxmox.

The project uses the `bpg/proxmox` provider.

A Debian 13 Cloud-Init template (VM 9000) is used as the base for provisioning.

The Terraform configuration has been used to create VM 140 (`ares-tf-test`) on the DEVELOPMENT network.

The test machine was provisioned with its intended resources and network configuration.

Terraform validation and planning have been successfully performed.

### 8.2. Ansible

Ansible is used to configure provisioned Linux machines.

The current automation includes:

- An inventory for the ARES test environment.
- SSH connectivity validation.
- Privilege escalation validation.
- A base configuration playbook.
- A reusable base role.

The base playbook has been executed successfully on VM 140.

The configuration has also been checked for idempotence.

### 8.3. Current Automation Scope

Terraform and Ansible successfully demonstrate automated provisioning and base configuration of a test virtual machine.

However, the complete deployment of the DevSecApp application server and all its services is not yet fully automated from an empty Proxmox environment.

The application deployment still requires additional automation work.

The existing Terraform and Ansible implementation is documented in `docs/infrastructure-as-code.md`.

## 9. Remote Access and VPN

A VPN is planned to provide secure remote access to the ARES internal network.

WireGuard on OPNsense is the planned implementation.

The VPN has not yet been deployed and validated.

Its intended purpose is to allow authorized remote users to access permitted internal resources without exposing the Proxmox management interface directly to the Internet.

The VPN configuration will require:

- WireGuard configuration on OPNsense.
- Client configuration.
- Appropriate firewall rules.
- Routing to authorized internal networks.
- Validation from an external network.

The VPN must only be considered operational after successful external connectivity and access-control tests.

## 10. Security and Operational Measures

The current infrastructure includes several security measures:

- Network segmentation through four VLANs.
- Centralized network filtering through OPNsense.
- Restrictive inter-VLAN access rules.
- HTTPS access through Nginx.
- Internal-only exposure of the application API.
- PostgreSQL not directly published to user networks.
- Application secrets stored outside the Git repository.
- Terraform state files excluded from version control.
- Docker container log rotation configured with size and file limits.
- Restricted permissions on the PostgreSQL backup directory.
- Application and infrastructure monitoring through Uptime Kuma.
- Database restoration procedure tested successfully.

Some security improvements remain planned, including a trusted TLS certificate, full virtual machine backups and a fully reproducible application deployment process.

## 11. Project Documentation

The ARES repository contains the following documentation:

| Document | Purpose |
|---|---|
| `README.md` | Project overview and entry point |
| `docs/architecture.md` | Deployed infrastructure architecture |
| `docs/network-plan.md` | Network addressing, VLANs and filtering |
| `docs/security-policy.md` | Security principles and access policy |
| `docs/infrastructure-as-code.md` | Terraform and Ansible implementation |
| `docs/monitoring.md` | Monitoring configuration and validation |
| `docs/progress.md` | Project progress and completed tests |
| `docs/IA.md` | AI assistance and contribution log |

The documentation describes the implementation, the validation performed and the remaining limitations.

## 12. Planned Improvements

The following improvements have been identified for future work:

1. **VPN deployment:** Configure and validate WireGuard on OPNsense to provide secure remote access.
2. **Complete application automation:** Extend Terraform and Ansible to automate the deployment and configuration of the DevSecApp server and services.
3. **Reproducible deployment:** Document and validate a complete deployment procedure from the infrastructure provisioning stage to application availability.
4. **Virtual machine backups:** Implement and test full Proxmox VM backup and restoration procedures.
5. **Additional security tests:** Expand automated tests covering network access controls, application security and service availability.
6. **Trusted TLS certificate:** Replace the current self-signed certificate with a certificate trusted by the intended clients.

These improvements are intended to strengthen the infrastructure's security, maintainability and reproducibility.

## 13. Conclusion

ARES provides a virtualized and segmented infrastructure hosting the DevSecApp application.

The current implementation includes:

- A Proxmox virtualization environment.
- An OPNsense firewall.
- Four internal VLANs.
- Network access filtering.
- A containerized application stack.
- HTTPS access through Nginx.
- PostgreSQL database backup and tested restoration.
- Uptime Kuma monitoring.
- Terraform-based virtual machine provisioning.
- Ansible-based Linux configuration.
- Technical documentation describing the implementation and its limitations.

The project demonstrates the integration of infrastructure automation, network security, application deployment and operational monitoring.

The remaining improvements are identified separately to distinguish implemented and tested features from planned extensions.
