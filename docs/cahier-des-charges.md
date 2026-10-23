# ARES — Cahier des charges

## 1. Présentation

ARES (Automated Resilient Enterprise Security) est un projet
d'infrastructure as code et de sécurisation d'une plateforme
informatique pour une PME fictive spécialisée dans le développement
logiciel et les services numériques.

Le projet s'appuie sur un laboratoire virtualisé avec Proxmox VE.
Il vise à fournir une infrastructure segmentée, automatisable,
administrable à distance et documentée.

## 2. Objectifs

- Préserver et auditer l'environnement Proxmox existant.
- Mettre en place un VPN distant sécurisé en priorité.
- Segmenter le réseau avec quatre VLAN obligatoires.
- Filtrer les flux inter-réseaux avec OPNsense.
- Provisionner les machines avec Terraform.
- Configurer les systèmes avec Ansible.
- Déployer DevSecApp et PostgreSQL avec Docker Compose.
- Fournir un accès HTTPS à l'application.
- Contrôler les accès réseau et applicatifs.
- Documenter les sauvegardes, restaurations et procédures
  d'exploitation.

## 3. Contexte de l'entreprise

La PME fictive comprend notamment :
- une équipe informatique chargée de l'administration ;
- une équipe de développement logiciel ;
- un service comptabilité et administration ;
- des serveurs hébergeant les applications internes.

Les utilisateurs disposent uniquement des accès nécessaires
à leurs fonctions.

## 4. Périmètre obligatoire

### 4.1 Accès distant

Un VPN est obligatoire et constitue une priorité de réalisation.
Il doit permettre l'administration autorisée du laboratoire
depuis un réseau extérieur, sans connexion Ethernet locale
au MiniForum et sans exposition directe de l'interface
d'administration Proxmox sur Internet.

Le fonctionnement devra être testé depuis un réseau extérieur.
Une procédure de récupération d'accès doit être documentée.

### 4.2 Segmentation réseau

Quatre VLAN sont obligatoires :

| VLAN | Fonction | Sous-réseau prévu |
|---|---|---|
| 10 | IT-ADMIN | 10.20.10.0/24 |
| 20 | DEVELOPMENT | 10.20.20.0/24 |
| 30 | BUSINESS | 10.20.30.0/24 |
| 40 | SERVERS | 10.20.40.0/24 |

L'adressage est provisoire jusqu'à l'audit du réseau existant.
La mise en place doit préserver l'accès actuel à Proxmox.

### 4.3 Filtrage

- Le VLAN DEVELOPMENT peut accéder à DevSecApp en HTTPS.
- Le VLAN BUSINESS ne peut pas accéder à DevSecApp.
- Les VLAN utilisateurs ne peuvent pas accéder directement
  à PostgreSQL.
- Les interfaces d'administration sont réservées aux accès
  autorisés du VLAN IT-ADMIN et au VPN selon la politique retenue.
- Les flux nécessaires au DNS, au NTP, aux mises à jour et à
  l'exploitation sont autorisés explicitement et documentés.
- Les autres flux inter-VLAN sont refusés par défaut.

### 4.4 Infrastructure et automatisation

- Utiliser Terraform pour provisionner les ressources compatibles.
- Utiliser Ansible pour configurer les systèmes.
- Utiliser Docker Compose pour le déploiement applicatif.
- Documenter les paramètres et les procédures de déploiement.

### 4.5 Application

DevSecApp, application FastAPI existante, sera intégrée à la
plateforme avec sa base PostgreSQL.

L'état réel de l'application, ses routes, son authentification,
ses tests et son interface seront audités avant toute modification.

Une interface utilisable devra être disponible. Si nécessaire,
une interface simple rendue côté serveur sera privilégiée afin
de conserver un périmètre réaliste.

Les autorisations applicatives devront être contrôlées côté serveur.

### 4.6 Sécurité et exploitation

- HTTPS pour l'accès utilisateur à l'application.
- Aucun secret réel dans Git.
- Aucun état Terraform sensible dans le dépôt.
- Contrôles de santé et consultation des journaux.
- Sauvegarde des données et test de restauration.
- Documentation des procédures de reprise.

## 5. Éléments hors périmètre initial

Kubernetes, Helm et les politiques Kubernetes détaillées sont
réservés au projet suivant. Les extensions de VLAN et la
supervision avancée seront réalisées uniquement si le socle
obligatoire est fonctionnel.

## 6. Critères de validation

Le projet sera considéré comme validé lorsque :

1. L'accès d'administration Proxmox reste opérationnel.
2. Le VPN permet un accès distant testé.
3. Les quatre VLAN sont déployés ou toute contrainte réelle
   est explicitement documentée et justifiée.
4. Les règles de filtrage sont démontrées par des tests.
5. DevSecApp est déployée et accessible en HTTPS depuis
   le réseau de développement.
6. L'accès depuis le réseau BUSINESS est refusé.
7. L'accès direct des VLAN utilisateurs à PostgreSQL est refusé.
8. Le provisionnement et la configuration sont reproductibles.
9. Les secrets ne sont pas versionnés.
10. Une restauration de sauvegarde a été testée.
11. La documentation et les preuves de validation sont fournies.

## 7. Contraintes et précautions

Aucune modification réseau ne doit être effectuée avant l'audit
de l'environnement Proxmox et la définition d'une procédure
de récupération d'accès.

Le système d'exploitation de l'hôte Proxmox ne doit pas être
réinstallé pour ce projet.

Les changements doivent être progressifs, vérifiables et
documentés.

## 8. Échéance

Date de livraison prévue : 16 novembre 2026.

Le projet privilégie un socle fonctionnel, sécurisé et démontrable
plutôt qu'une multiplication de fonctionnalités inachevées.

## 9. État d'avancement

Le dépôt et le périmètre initial sont en préparation.
Les composants ne sont considérés comme déployés ou validés
qu'après réalisation et test.
