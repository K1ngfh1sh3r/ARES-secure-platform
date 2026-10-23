# ARES — Plan réseau provisoire

## 1. État de validation

Le plan ci-dessous est une proposition de conception.
Les adresses et interfaces seront confirmées après audit
du réseau domestique et de Proxmox.

## 2. VLAN prévus

| VLAN | Nom | Sous-réseau prévu | Usage |
|---|---|---|---|
| 10 | IT-ADMIN | 10.20.10.0/24 | Administration autorisée |
| 20 | DEVELOPMENT | 10.20.20.0/24 | Postes de développement |
| 30 | BUSINESS | 10.20.30.0/24 | Comptabilité et administration |
| 40 | SERVERS | 10.20.40.0/24 | Applications et services internes |

## 3. Flux principaux

| Source | Destination | Politique prévue |
|---|---|---|
| DEVELOPMENT | DevSecApp HTTPS | Autoriser |
| BUSINESS | DevSecApp HTTPS | Refuser |
| VLAN utilisateurs | PostgreSQL | Refuser |
| IT-ADMIN | Interfaces d'administration | Autoriser selon les ports nécessaires |
| VPN | Réseau d'administration | Autoriser selon les destinations nécessaires |
| Autres flux inter-VLAN | Toute destination | Refuser par défaut |

## 4. Services transverses

DNS, NTP, mises à jour, journaux et supervision feront l'objet
de règles dédiées selon les besoins réellement identifiés.

## 5. Précautions

- Vérifier les sous-réseaux existants avant de réserver l'adressage.
- Ne pas perturber le bridge qui porte l'accès actuel à Proxmox.
- Ne pas relier les VLAN au réseau domestique sans nécessité.
- Documenter les interfaces physiques et virtuelles.
- Tester les règles depuis les segments concernés.

## 6. Extensions éventuelles

Les VLAN de supervision, sauvegarde ou invités sont optionnels.
Ils ne seront ajoutés qu'après validation des quatre VLAN obligatoires.
