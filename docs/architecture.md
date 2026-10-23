# ARES — Architecture cible

## 1. Environnement existant

ARES sera hébergé sur le MiniForum exécutant Proxmox VE.
L'hôte est actuellement accessible depuis le PC Debian.

La configuration des interfaces, des bridges, des VM, des
conteneurs et du stockage doit être auditée avant toute modification.

Le système Proxmox ne sera pas réinstallé.

## 2. Architecture logique envisagée

```text
PC Debian
   |
   | VPN distant chiffre
   |
Routeur domestique
   |
MiniForum / Proxmox VE
   |
OPNsense
   |
Réseaux virtuels segmentés
   |
   +-- VLAN 10 : IT-ADMIN
   +-- VLAN 20 : DEVELOPMENT
   +-- VLAN 30 : BUSINESS
   +-- VLAN 40 : SERVERS
                    |
                    +-- Reverse proxy HTTPS
                    +-- DevSecApp
                    +-- PostgreSQL
```

Ce schéma représente la cible logique, pas une configuration
déjà déployée. Le câblage virtuel exact dépendra de l'audit.

## 3. Composants

### Proxmox VE

Hyperviseur hébergeant les VM du laboratoire. L'accès actuel
doit rester disponible durant la mise en place du VPN.

### OPNsense

Pare-feu chargé du filtrage inter-VLAN et du routage des réseaux
du laboratoire. Il pourra héberger le VPN si la configuration
existante et les contraintes réseau le permettent.

### VPN

Le VPN est obligatoire et prioritaire. Il doit permettre
l'administration distante autorisée sans exposer directement
l'interface Proxmox sur Internet.

### Terraform

Terraform provisionnera les ressources compatibles avec
l'environnement retenu. Le fournisseur et les méthodes d'accès
seront confirmés avant l'écriture du code.

### Ansible

Ansible configurera les systèmes cibles de façon reproductible.

### Docker Compose

Docker Compose déploiera DevSecApp, PostgreSQL et le reverse
proxy selon la conception validée.

### DevSecApp

L'application existante sera auditée avant intégration. Son
interface, son authentification et ses autorisations seront
adaptées uniquement si nécessaire.

## 4. Segmentation prévue

| VLAN | Fonction | Sous-réseau provisoire |
|---|---|---|
| 10 | IT-ADMIN | 10.20.10.0/24 |
| 20 | DEVELOPMENT | 10.20.20.0/24 |
| 30 | BUSINESS | 10.20.30.0/24 |
| 40 | SERVERS | 10.20.40.0/24 |

Les sous-réseaux seront confirmés après vérification de
l'adressage déjà utilisé.

## 5. Flux applicatifs prévus

- DEVELOPMENT vers DevSecApp en HTTPS : autorisé.
- BUSINESS vers DevSecApp : refusé.
- VLAN utilisateurs vers PostgreSQL : accès direct refusé.
- Administration depuis IT-ADMIN et le VPN : accès limité
  aux destinations et ports nécessaires.
- Autres flux inter-VLAN : refusés par défaut.

Les besoins DNS, NTP, mises à jour et journaux seront définis
dans la conception détaillée.

## 6. Ordre de réalisation

1. Auditer Proxmox et documenter l'existant.
2. Définir une méthode de récupération d'accès.
3. Déployer et tester le VPN distant.
4. Valider les bridges et l'architecture réseau.
5. Configurer les VLAN et les règles OPNsense.
6. Provisionner les VM avec Terraform.
7. Configurer les systèmes avec Ansible.
8. Déployer et sécuriser DevSecApp.
9. Tester les restrictions, la persistance et la restauration.
10. Finaliser la documentation et la démonstration.

## 7. Décisions en attente

- Bridges Proxmox et raccordement des VLAN.
- Emplacement définitif du VPN.
- Compatibilité du routeur avec l'accès VPN entrant.
- Fournisseur Terraform.
- Adaptations nécessaires à DevSecApp.
