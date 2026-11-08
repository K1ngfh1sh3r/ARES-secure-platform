# ARES — Plan réseau

## 1. État de validation

Les quatre VLAN obligatoires sont déployés dans l'infrastructure ARES.

Les sous-réseaux ci-dessous correspondent à la configuration réellement utilisée lors des tests réseau.

Les politiques de sécurité sont documentées séparément de leurs résultats de test. Un flux n'est considéré comme validé qu'après vérification effective.

## 2. VLAN déployés

| VLAN | Nom | Sous-réseau | Usage |
|---|---|---|---|
| 10 | IT-ADMIN | 10.20.10.0/24 | Administration de l'infrastructure |
| 20 | DEVELOPMENT | 10.20.20.0/24 | Postes de développement |
| 30 | BUSINESS | 10.20.30.0/24 | Comptabilité et administration |
| 40 | SERVERS | 10.20.40.0/24 | Applications et services internes |

## 3. Flux et politiques de sécurité

| Source | Destination | Politique |
|---|---|---|
| DEVELOPMENT | DevSecApp HTTPS (TCP 443) | Autoriser |
| BUSINESS | DevSecApp HTTPS (TCP 443) | Refuser |
| VLAN utilisateurs | PostgreSQL (TCP 5432) | Refuser |
| IT-ADMIN | Interfaces d'administration | Autoriser selon les ports nécessaires |
| VPN | Réseau d'administration | Prévu pour l'accès distant |
| Autres flux inter-VLAN | Toute destination | Refuser par défaut |

## 4. Tests de segmentation

### 4.1 BUSINESS vers DevSecApp

| Paramètre | Valeur |
|---|---|
| VLAN source | VLAN 30 — BUSINESS |
| Adresse source | 10.20.30.110 |
| VLAN destination | VLAN 40 — SERVERS |
| Adresse destination | 10.20.40.10 |
| Protocole | HTTPS |
| Port destination | TCP 443 |
| Interface source utilisée | enp0s31f6.30 |
| Résultat attendu | Connexion refusée |
| Résultat observé | Échec de connexion |

**Commande exécutée depuis le poste de test :**

```bash
curl -k -v \
  --interface enp0s31f6.30 \
  --connect-timeout 5 \
  --max-time 8 \
  https://10.20.40.10/health
```
```text
socket successfully bound to interface 'enp0s31f6.30'
connect to 10.20.40.10 port 443 from 10.20.30.110
failed: Aucun chemin d'accès pour atteindre l'hôte cible
curl: (7) Failed to connect to 10.20.40.10 port 443
```

**Conclusion :**

Le test confirme que le poste du VLAN BUSINESS ne parvient pas à établir une connexion HTTPS vers DevSecApp hébergée sur le VLAN SERVERS.

### 4.2 Autres tests de segmentation

Les autres flux feront l'objet de validations complémentaires :

- DEVELOPMENT vers DevSecApp : accès HTTPS autorisé.
- BUSINESS vers DevSecApp : accès HTTPS refusé.
- VLAN utilisateurs vers PostgreSQL : accès direct refusé.
- SSH inter-VLAN : blocage observé dans OPNsense Live View.

Les résultats doivent être associés à des tests effectifs et à des preuves correspondantes.

## 5. Services transverses

Les services transverses et mécanismes d'exploitation comprennent :

- DNS : résolution des noms.
- NTP : synchronisation horaire.
- Mises à jour : accès aux dépôts nécessaires.
- Journaux : conservation et rotation des journaux Docker et Nginx.
- Supervision : surveillance de la disponibilité des services avec Uptime Kuma.

## 6. Précautions d'exploitation

- Ne pas perturber le bridge qui porte l'accès actuel à Proxmox.
- Ne pas relier les VLAN au réseau domestique sans nécessité.
- Conserver une politique restrictive entre les segments.
- Tester les règles depuis les segments concernés.
- Ne pas considérer une règle comme validée sans preuve de test.
- Protéger les interfaces et services d'administration.

## 7. Extensions éventuelles

Les VLAN de supervision, sauvegarde ou invités sont optionnels.

Ils ne sont pas nécessaires à la validation des quatre VLAN obligatoires.
