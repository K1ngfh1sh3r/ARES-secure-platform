# Infrastructure as Code — ARES

## 1. Présentation

Le projet ARES utilise Terraform et Ansible pour automatiser le
provisionnement et la configuration des machines virtuelles hébergées
sur Proxmox VE.

L'objectif est de disposer d'un processus reproductible permettant
de créer une machine virtuelle, de configurer son accès réseau et
d'appliquer automatiquement une configuration système de base.

La démonstration actuelle repose sur une machine de test :

- Nom : `ares-tf-test`
- Identifiant Proxmox : `140`
- Système : Debian 13
- Adresse IP : `10.20.20.20/24`
- VLAN : 20 — DEVELOPMENT

Cette machine est indépendante de la VM hébergeant DevSecApp.
Elle sert à démontrer les capacités d'automatisation de la plateforme.

## 2. Architecture générale

La chaîne d'automatisation repose sur quatre composants :

1. **Proxmox VE** : héberge les machines virtuelles.
2. **Terraform** : provisionne et configure les ressources Proxmox.
3. **Cloud-Init** : réalise la configuration initiale de Debian.
4. **Ansible** : applique la configuration système après le démarrage.

### 2.1. Déroulement

Le processus est organisé de la manière suivante :

1. Terraform contacte l'API Proxmox à l'aide d'un token dédié.
2. Terraform clone le template Debian 13 (VM 9000).
3. Les ressources CPU, mémoire et réseau sont configurées.
4. Cloud-Init configure le compte `aresadmin`, sa clé SSH,
   l'adresse IP, la passerelle et le DNS.
5. La machine virtuelle démarre.
6. Ansible se connecte en SSH.
7. Le rôle `base` installe les paquets nécessaires et active
   QEMU Guest Agent.

## 3. Configuration de Terraform

### 3.1. Environnement

La configuration utilise :

- Terraform : version 1.17.1
- Provider : `bpg/proxmox`
- Version du provider : `0.120.0`
- API Proxmox : `https://192.168.1.70:8006/`
- Nœud Proxmox : `pve`

La version minimale déclarée dans le projet est Terraform 1.6.0.

Le fichier `.terraform.lock.hcl` conserve les versions sélectionnées
et les sommes de contrôle des providers.

### 3.2. Authentification

Terraform utilise un token API Proxmox dédié :

`terraform@pam!ares-automation`

Le secret du token est transmis par la variable :

`proxmox_api_token_secret`

Cette variable est déclarée avec `sensitive = true`.

Le secret ne doit jamais être intégré directement dans les fichiers
de configuration versionnés.

Le certificat TLS de l'API Proxmox est accepté avec le paramètre
`insecure = true`, dans le contexte du laboratoire. En production,
il est préférable de déployer un certificat reconnu et de vérifier
sa validité.

### 3.3. Provisionnement de la VM

Le fichier `terraform/main.tf` déclare la ressource :

`proxmox_virtual_environment_vm.ares_tf_test`

Les caractéristiques principales sont :

| Paramètre | Valeur |
|---|---|
| Nom | ares-tf-test |
| VM ID | 140 |
| Nœud | pve |
| Template source | VM 9000 |
| CPU | 2 cœurs |
| Mémoire | 2048 Mo |
| Stockage Cloud-Init | local-lvm |
| Bridge réseau | vmbr1 |
| Modèle réseau | VirtIO |
| VLAN | 20 |
| Adresse IPv4 | 10.20.20.20/24 |
| Passerelle | 10.20.20.1 |
| DNS | 10.20.20.1 |
| Utilisateur | aresadmin |

Le compte est configuré avec une clé publique SSH présente sur
la machine exécutant Terraform.

La configuration active également QEMU Guest Agent pour permettre
à Proxmox de communiquer avec l'agent installé dans la machine invitée.

### 3.4. Connexion à Proxmox

Le fichier `terraform/test-connection.tf` utilise une source de
données du provider pour interroger les nœuds Proxmox.

Deux sorties permettent de consulter les nœuds détectés et leur
état de disponibilité :

- `proxmox_nodes`
- `proxmox_nodes_online`

Cette configuration permet notamment de vérifier la communication
entre Terraform et l'API Proxmox.

## 4. Cloud-Init

Cloud-Init assure la configuration initiale de la machine lors
de son premier démarrage.

Dans ARES, Terraform lui transmet les paramètres suivants :

- Nom du compte : `aresadmin`.
- Clé publique SSH : `~/.ssh/id_ed25519.pub`.
- Adresse IPv4 : `10.20.20.20/24`.
- Passerelle : `10.20.20.1`.
- Serveur DNS : `10.20.20.1`.

L'utilisation d'une adresse IP statique permet de conserver une
configuration réseau prévisible pour l'inventaire Ansible.

Le DNS est assuré par OPNsense via Unbound.

## 5. Configuration d'Ansible

### 5.1. Organisation des fichiers

L'organisation actuelle est la suivante :

```text
ansible.cfg
ansible/
├── inventory/
│   └── hosts.ini
├── playbooks/
│   └── base.yml
└── roles/
    └── base/
        └── tasks/
            └── main.yml
```

### 5.2. Configuration générale

Le fichier `ansible.cfg` définit :

- Le chemin de l'inventaire.
- Le répertoire des rôles.
- L'activation de la vérification des clés SSH.
- Le mode de sélection de l'interpréteur Python.

La vérification des clés SSH est conservée pour éviter
d'accepter silencieusement une nouvelle identité distante.

### 5.3. Inventaire

Le fichier `ansible/inventory/hosts.ini` déclare le groupe
`ares_test`, qui contient la machine `ares-tf-test`.

Les paramètres de connexion sont :

- Hôte : `10.20.20.20`.
- Utilisateur : `aresadmin`.
- Authentification : clé privée SSH locale.
- Interpréteur Python : `/usr/bin/python3`.

L'utilisation d'un inventaire permet d'ajouter d'autres machines
à la configuration automatisée.

### 5.4. Playbook de base

Le fichier `ansible/playbooks/base.yml` exécute le rôle `base`
sur le groupe `ares_test`.

L'élévation de privilèges est activée avec `become: true`,
afin de permettre les opérations d'administration du système.

### 5.5. Rôle base

Le rôle `ansible/roles/base/tasks/main.yml` réalise trois opérations.

**1. Mise à jour du cache APT**

Le cache des paquets Debian est actualisé.
La durée de validité du cache est fixée à 3600 secondes.

**2. Installation des paquets de base**

Les paquets installés sont :

- `ca-certificates` : gestion des certificats.
- `curl` : tests et requêtes HTTP/HTTPS.
- `vim` : édition de fichiers.
- `qemu-guest-agent` : communication entre la VM et Proxmox.

**3. Activation de QEMU Guest Agent**

Le service `qemu-guest-agent` est configuré pour démarrer
automatiquement et son état est vérifié.

## 6. Procédure de déploiement

Les commandes suivantes sont exécutées depuis la machine
d'administration ARES.

### 6.1. Initialisation Terraform

```bash
cd ~/projects/ares-secure-platform/terraform

terraform init
```

### 6.2. Vérification de la configuration

```bash
terraform fmt
terraform validate
terraform plan
```

Le plan permet de vérifier les modifications qui seront
appliquées à l'infrastructure.

### 6.3. Application

```bash
terraform apply
```

Terraform applique les modifications après validation.

### 6.4. Vérification de la connexion Ansible

Depuis la racine du projet :

```bash
cd ~/projects/ares-secure-platform

ansible-inventory --graph
ansible ares_test -m ping
```

### 6.5. Application du playbook

```bash
ansible-playbook ansible/playbooks/base.yml
```

Le playbook peut être exécuté à nouveau pour vérifier que
la machine conserve l'état souhaité.

## 7. Tests et validation

Plusieurs vérifications ont été réalisées sur la VM 140.

| Vérification | Résultat |
|---|---|
| Connexion à l'API Proxmox | Réussie |
| Détection du nœud Proxmox | Réussie |
| Provisionnement Terraform | Réussi |
| Configuration Cloud-Init | Réussie |
| Connectivité SSH | Réussie |
| Résolution DNS | Réussie |
| Accès HTTPS vers Internet | Réussi |
| QEMU Guest Agent | Actif |
| Test Ansible Ping | Réussi |
| Exécution du playbook | Réussie |

### 7.1. Validation de QEMU Guest Agent

Le service a été contrôlé sur Debian avec :

```bash
systemctl status qemu-guest-agent --no-pager
ls -l /dev/virtio-ports/
```

Le service était actif et le périphérique
`org.qemu.guest_agent.0` était présent.

La communication avec l'agent a également été observée
dans les journaux de QEMU Guest Agent.

### 7.2. Validation de l'idempotence

Le playbook Ansible a été exécuté deux fois consécutivement.

Les deux exécutions ont retourné :

```text
ok=4
changed=0
unreachable=0
failed=0
```

Le résultat `changed=0` indique qu'aucune modification
supplémentaire n'était nécessaire lors de la seconde exécution.

L'idempotence du rôle `base` est ainsi vérifiée dans
l'environnement de test.

## 8. Gestion des fichiers sensibles

Les fichiers d'état Terraform peuvent contenir des informations
sensibles sur l'infrastructure.

Les éléments suivants ne doivent pas être versionnés :

- `terraform.tfstate`
- `terraform.tfstate.backup`
- Les fichiers `*.tfvars`
- Les fichiers de plan Terraform `*.tfplan`
- Les secrets et clés privées
- Les répertoires `.terraform/`

Le fichier `.terraform.lock.hcl` doit en revanche être conservé
dans le dépôt afin de verrouiller les versions des providers.

Le fichier `.gitignore` du projet contient les règles nécessaires
à cette exclusion.

Pour un environnement de production, un stockage distant du state,
sécurisé et avec gestion des accès, est recommandé.

## 9. Limites et évolutions

L'automatisation présentée constitue une première base fonctionnelle.

Les évolutions possibles comprennent :

- L'ajout d'autres rôles Ansible spécialisés.
- L'automatisation de configurations de sécurité supplémentaires.
- L'extension de l'inventaire à d'autres VLAN.
- La gestion sécurisée des secrets avec Ansible Vault.
- La mise en place d'un stockage distant du state Terraform.

Ces évolutions devront conserver les principes de reproductibilité,
de sécurité et d'idempotence.

## 10. Conclusion

Cette mise en œuvre démontre la complémentarité de Terraform
et Ansible dans l'automatisation d'une infrastructure virtualisée.

Terraform assure le provisionnement des ressources Proxmox,
Cloud-Init réalise la configuration initiale de la machine,
et Ansible applique une configuration système reproductible.

Les tests réalisés confirment le bon fonctionnement de la chaîne
d'automatisation ainsi que l'idempotence du rôle Ansible de base.
