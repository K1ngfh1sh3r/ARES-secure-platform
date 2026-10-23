# ARES — Automated Resilient Enterprise Security

ARES is an infrastructure-as-code and secure platform project
designed for a fictional small software development company.

## Objectives

- Build an isolated and segmented enterprise lab on Proxmox.
- Use OPNsense to enforce network security policies.
- Provide secure remote administration through a VPN.
- Automate infrastructure provisioning with Terraform.
- Configure Linux systems with Ansible.
- Deploy DevSecApp and PostgreSQL using Docker Compose.
- Enforce HTTPS and protect application secrets.
- Test network restrictions and application-level authorization.
- Document backup, recovery, deployment and security validation.

## Planned network segmentation

| VLAN | Name | Planned subnet |
|---|---|---|
| 10 | IT-ADMIN | 10.20.10.0/24 |
| 20 | DEVELOPMENT | 10.20.20.0/24 |
| 30 | BUSINESS | 10.20.30.0/24 |
| 40 | SERVERS | 10.20.40.0/24 |

These subnets are provisional until the existing homelab network
has been audited and address conflicts have been ruled out.

## Remote access

A VPN is a mandatory project requirement and an early priority.
It must provide secure remote access to the lab without exposing
the Proxmox administration interface directly to the Internet.

The VPN design and deployment depend on the initial Proxmox,
network and router audit.

## Security requirements

- Deny unauthorized traffic between network segments by default.
- Prevent direct PostgreSQL access from user VLANs.
- Restrict administrative interfaces to authorized administrators.
- Enforce application authorization on the server side.
- Keep real secrets, private keys and Terraform state out of Git.
- Validate backup restoration and document recovery procedures.

## Planned technologies

- Proxmox VE
- OPNsense
- WireGuard or another suitable VPN solution
- Terraform
- Ansible
- Debian
- Docker Compose
- FastAPI and PostgreSQL
- HTTPS reverse proxy

## Project status

Initial repository structure and project scope are being prepared.
Infrastructure deployment and validation have not yet been completed.

## Documentation

- [Project specification](docs/cahier-des-charges.md)
- [Architecture](docs/architecture.md)
- [Network plan](docs/network-plan.md)
- [Security policy](docs/security-policy.md)
