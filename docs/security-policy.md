# ARES — Politique de sécurité

## 1. Principes

- Refus par défaut des flux non explicitement autorisés.
- Moindre privilège pour les utilisateurs et les services.
- Séparation des réseaux selon les fonctions.
- Administration distante exclusivement par un accès sécurisé.
- Traçabilité des changements et des tests.
- Configuration reproductible et documentation à jour.

## 2. Administration

- L'interface Proxmox ne doit pas être exposée directement
  sur Internet.
- L'accès distant doit passer par le VPN après authentification.
- Les interfaces d'administration sont accessibles uniquement
  depuis les sources autorisées.
- L'accès de secours doit être défini avant tout changement réseau.
- Les identifiants et clés privés ne doivent jamais être versionnés.

## 3. Politique inter-réseaux

- DEVELOPMENT peut accéder à DevSecApp en HTTPS.
- BUSINESS ne peut pas accéder à DevSecApp.
- Les réseaux utilisateurs ne peuvent pas accéder directement
  au port PostgreSQL.
- Les accès à Proxmox, OPNsense et aux services d'administration
  sont réservés aux sources autorisées.
- Les exceptions nécessaires sont documentées et limitées
  aux ports et destinations requis.

## 4. Sécurité applicative

- Les autorisations sont vérifiées côté serveur.
- Les erreurs ne doivent pas exposer de secrets ou de données
  techniques sensibles.
- Les données persistantes doivent survivre à un redémarrage
  contrôlé des conteneurs.
- Les tests existants sont exécutés après les changements.
- L'accès applicatif est testé depuis les segments autorisés
  et interdits.

## 5. Secrets et infrastructure as code

- Les fichiers .env réels, clés privées et secrets sont exclus
  du dépôt.
- Les fichiers d'état Terraform ne sont pas versionnés.
- Les exemples de configuration utilisent uniquement des
  valeurs fictives.
- Les permissions d'accès aux sauvegardes et fichiers sensibles
  sont limitées.
- Toute publication Git est précédée d'une vérification des fichiers.

## 6. Validation

Les tests doivent vérifier :
- l'accès VPN depuis un réseau extérieur ;
- l'impossibilité d'accéder aux interfaces d'administration
  depuis les segments non autorisés ;
- l'accès HTTPS à DevSecApp depuis DEVELOPMENT ;
- le refus d'accès depuis BUSINESS ;
- le blocage de l'accès direct à PostgreSQL ;
- la persistance des données ;
- la restauration d'une sauvegarde.

Les résultats doivent être documentés. Une règle configurée
n'est pas considérée comme validée avant son test.

## 7. Gestion des changements

Les changements réseau sont réalisés progressivement, avec
un moyen de récupération connu. Aucun changement risqué n'est
effectué avant l'audit initial et la vérification des accès.
