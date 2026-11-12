# Journal IA

## Contexte et méthode d'utilisation

L'intelligence artificielle a été utilisée tout au long du projet ARES comme un outil d'accompagnement technique et pédagogique.

Son utilisation a principalement reposé sur trois axes :

- **Planification :** aide à organiser les différentes étapes du projet, identifier les dépendances entre les tâches et définir les priorités.
- **Accompagnement technique :** aide ponctuelle à la compréhension de notions techniques et au dépannage de problèmes rencontrés pendant le développement.
- **Conception de l'interface :** assistance à la conception visuelle de l'interface web de DevSecApp.

L'IA n'a pas réalisé le projet dans son intégralité. J'ai personnellement réalisé la majorité du développement, les configurations de l'infrastructure, les tests et les validations.

En particulier, j'ai conçu et mis en place l'infrastructure ARES, développé l'API backend et réalisé la logique JavaScript de DevSecApp. L'IA est principalement intervenue sur la conception visuelle de l'interface, l'explication de notions techniques et l'aide ponctuelle au dépannage.

Ce journal est une reconstitution établie à partir des échanges disponibles et de l'historique Git. Il ne prétend pas constituer un relevé quotidien exhaustif.

---

## 1. Planification et organisation du projet

**Outil :** ChatGPT

**Demande :** Accompagnement dans la définition des étapes du projet ARES, l'organisation des tâches et l'identification des priorités techniques.

**Utilisation :**
- Proposition d'un ordre de réalisation des différentes briques.
- Identification des dépendances entre infrastructure, réseau, application et sécurité.
- Aide à la définition de périmètres de travail réalisables.
- Réajustement du planning selon les contraintes du projet.

**Contribution personnelle :**

J'ai défini les orientations du projet, choisi les priorités et organisé la réalisation des différentes tâches. Les propositions de l'IA ont servi de support à la réflexion et à la planification.

**Décision :** Les suggestions ont été évaluées et adaptées en fonction de l'avancement réel du projet.

---

## 2. Assistance ponctuelle sur l'infrastructure et apprentissage technique

**Outil :** ChatGPT

**Objectif :** Obtenir une aide ponctuelle lors de difficultés techniques et approfondir la compréhension de notions rencontrées pendant le développement du projet.

**Domaines concernés :**
- Proxmox et virtualisation.
- OPNsense et segmentation réseau.
- VLAN et règles de filtrage.
- Terraform et Ansible.
- Linux et administration système.
- Docker et Docker Compose.
- Nginx et TLS.

**Utilisation :**

L'IA a principalement été utilisée comme une ressource pédagogique et une aide au dépannage.

Lorsqu'une difficulté apparaissait dans l'infrastructure, ChatGPT pouvait aider à interpréter un message d'erreur, proposer des commandes de diagnostic ou suggérer plusieurs pistes de résolution.

Elle m'a également permis de mieux comprendre certaines notions techniques que je ne maîtrisais pas encore, en expliquant leur fonctionnement et leur utilité dans le contexte du projet.

**Contribution personnelle :**

J'ai personnellement conçu, mis en place et configuré l'infrastructure du projet. J'ai réalisé les configurations réseau, la segmentation en VLAN, le déploiement des machines virtuelles, l'automatisation avec Terraform et Ansible ainsi que le déploiement des services.

Les choix techniques, les configurations, les manipulations sur l'environnement réel et les validations ont été effectués par mes soins.

**Décision :** ChatGPT a été utilisé comme un outil d'apprentissage et de dépannage ponctuel, et non comme un outil de réalisation de l'infrastructure. Les explications et suggestions ont été évaluées avant toute utilisation.

---

## 3. Conception de l'interface DevSecApp

**Outil :** ChatGPT

**Demande :** Concevoir l'identité visuelle et l'organisation de l'interface web de DevSecApp.

**Contribution de l'IA :**
- Proposition de la direction graphique.
- Conception de l'apparence générale et de l'organisation visuelle.
- Proposition d'une interface cohérente avec le contexte professionnel du projet.

**Contribution personnelle :**
- Intégration et adaptation de l'interface.
- Vérification du rendu dans le navigateur.
- Corrections de présentation et ajustements.
- Validation des différentes pages.

**Décision :** La proposition visuelle a été utilisée comme base, puis adaptée et validée au cours du développement.

---

## 4. Développement de l'API et de la logique JavaScript

**Outil :** ChatGPT, utilisé ponctuellement comme assistant technique.

**Demande :** Assistance ponctuelle pour comprendre certains problèmes et vérifier le fonctionnement de l'application.

**Contribution personnelle :**
- Conception et développement de l'API backend.
- Implémentation des fonctionnalités métier.
- Développement de la logique JavaScript.
- Gestion des interactions avec l'API.
- Intégration des mécanismes d'authentification et d'autorisation.
- Tests et corrections du comportement de l'application.

**Décision :** Le développement de l'API et de la logique JavaScript a été réalisé personnellement. Les éventuelles suggestions de l'IA ont été utilisées comme aide ponctuelle et soumises à vérification.

---

## 5. Tests, sécurité et débogage

**Outil :** ChatGPT

**Demande :** Aide à identifier les causes de dysfonctionnements, définir des scénarios de test et interpréter les résultats.

**Utilisation :**
- Proposition de commandes de diagnostic.
- Aide à la compréhension des erreurs.
- Proposition de scénarios de validation.
- Assistance à l'analyse des résultats des tests.

**Contribution personnelle :**

J'ai exécuté les tests, analysé les résultats, identifié les problèmes dans l'environnement réel et appliqué les corrections nécessaires.

**Décision :** Les modifications ont été conservées uniquement après vérification de leur fonctionnement.

---

## 6. Documentation et finalisation

**Outil :** ChatGPT

**Demande :** Aide à structurer les documents techniques, clarifier les explications et améliorer la présentation du projet.

**Utilisation :**
- Assistance à l'organisation des documents.
- Suggestions pour améliorer la clarté des explications.
- Aide à la structuration du README et des procédures techniques.

**Contribution personnelle :**

J'ai vérifié les informations, assuré leur cohérence avec l'infrastructure réellement déployée et validé le contenu final.

**Décision :** Les propositions rédactionnelles ont été adaptées pour refléter fidèlement le fonctionnement réel du projet.

---

## Remarque sur la traçabilité

Les contributions assistées par IA doivent être rapprochées des commits Git correspondants lorsque cela est possible.

Les références de commits seront ajoutées aux entrées concernées après vérification de l'historique.

Ce journal vise à présenter de manière transparente l'utilisation de l'intelligence artificielle, les contributions personnelles et les décisions prises au cours du projet.

Aucun historique Git ne sera réécrit pour reconstituer artificiellement la traçabilité.

---

## 7. Repères Git associés aux contributions

Les commits suivants permettent de retrouver les principales étapes du projet et de rapprocher les contributions assistées par IA du travail réalisé.

### Architecture et planification
- `a30e1f3` — Définition du périmètre et de l'architecture ARES.

### Infrastructure et automatisation
- `a2ab2f5` — Mise en place initiale du homelab ARES.
- `b7f0118` — Automatisation du provisionnement Proxmox avec Terraform et Ansible.

### Application et sécurité
- `58565ad` — Mise en place de l'autorisation basée sur les réseaux.
- `90fab76` — Ajout des tests d'authentification et d'autorisation.
- `01d7bec` — Corrections de l'interface et du profil utilisateur.

### Documentation et validation
- `6be520b` — Documentation de la segmentation VLAN.
- `d81114d` — Documentation de la supervision Uptime Kuma.
- `44238bc` — Finalisation de la documentation ARES.
- `42480c3` — Documentation de la restauration PostgreSQL et de la validation IaC.

Ces références constituent des points de repère dans l'historique Git. Elles ne signifient pas que chaque ligne de code de ces commits a été générée par une IA.
