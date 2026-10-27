# ARES - Journal d'avancement

## 2026-10-25 - Mise en place du VLAN 10

### Objectif de la session

Mettre en place le premier segment VLAN de l'infrastructure ARES, tester l'accès d'administration depuis Debian et préserver l'accès existant à Proxmox et à Internet.

### Environnement

- Hyperviseur : Proxmox VE 9.2.2.
- Routeur/pare-feu : OPNsense 26.7, installé dans une VM.
- Poste d'administration : Debian.
- Dépôt : `K1ngfh1sh3r/ARES-secure-platform`.

### Configuration réseau

| Élément | Configuration actuelle |
|---|---|
| `vmbr0` | Bridge Proxmox existant, conservé pour la gestion et le réseau domestique |
| `vmbr1` | Bridge ARES associé à `nic1`, VLAN-aware, sans adresse IP de gestion |
| WAN OPNsense | `vtnet0`, DHCP, `192.168.1.92/24` |
| LAN de secours OPNsense | `vtnet1`, `10.20.99.1/24` |
| VLAN 10 - IT-ADMIN | Interface VLAN sur `vtnet1`, `10.20.10.1/24` |
| Debian - Ethernet non tagué | `10.20.99.110/24` |
| Debian - VLAN 10 | `enp0s31f6.10`, `10.20.10.110/24` |
| Debian - Wi-Fi | Réseau domestique, utilisé pour conserver l'accès Internet |

L'adresse de gestion Proxmox reste `192.168.1.70/24`. La configuration de `vmbr0` et l'adresse de gestion de Proxmox n'ont pas été modifiées.

Le LAN de secours `10.20.99.0/24` est distinct du VLAN 10 `10.20.10.0/24`, ce qui évite d'utiliser le même sous-réseau sur les deux interfaces.

### Règles de filtrage mises en place

Sur l'interface VLAN 10, les règles suivantes ont été ajoutées :

- Autoriser temporairement le ping de diagnostic depuis `10.20.10.110` vers l'adresse de l'interface VLAN 10.
- Autoriser HTTPS depuis `10.20.10.110` vers l'adresse de gestion OPNsense `10.20.10.1`.
- Autoriser HTTPS depuis `10.20.10.110` vers Proxmox `192.168.1.70:8006`.

La règle de diagnostic ICMP est temporaire : elle devra être supprimée ou remplacée lorsque les tests seront terminés.

**Point de vigilance :** l'accès à Proxmox doit encore être vérifié en forçant le trafic à passer par le VLAN 10. Un test réalisé depuis le poste Debian peut utiliser le Wi-Fi si le routage le privilégie.

Les règles actuelles ne constituent pas encore une politique de filtrage complète. Le filtrage inter-VLAN reste à définir.

### Vérifications réalisées

| Test | Résultat |
|---|---|
| Ping de `10.20.10.1` depuis le VLAN 10 | Réussi : 4 réponses sur 4 |
| Ping de `10.20.99.1` depuis le réseau de secours | Réussi : 4 réponses sur 4 |
| Accès HTTPS à OPNsense via `https://10.20.10.1` | Réussi : HTTP 200 |
| Accès HTTPS à Proxmox via `https://192.168.1.70:8006` | Interface accessible ; chemin réseau à confirmer |
| Connectivité Internet depuis le shell OPNsense | Tests vers `1.1.1.1` et `deb.debian.org` réussis |

### État du projet

- [x] OPNsense installé et démarré.
- [x] WAN et LAN de secours configurés.
- [x] `vmbr1` dédié à ARES, avec VLAN-aware activé.
- [x] VLAN 10 créé et affecté à une interface OPNsense.
- [x] Connectivité entre Debian et la passerelle VLAN 10 vérifiée.
- [x] Interface Web OPNsense accessible depuis le VLAN 10.
- [x] Sauvegarde de la configuration OPNsense exportée hors du dépôt Git.
- [ ] Vérifier le chemin réseau effectif vers Proxmox depuis le VLAN 10.
- [ ] Rendre la configuration VLAN de Debian persistante.
- [ ] Créer et tester les VLAN 20, 30 et 40.
- [ ] Définir et vérifier le filtrage inter-VLAN.
- [ ] Déployer DevSecApp dans le segment serveurs.
- [ ] Configurer et tester le VPN d'accès distant.
- [ ] Automatiser le déploiement avec Terraform et Ansible.

### Points de vigilance

- Ne pas exposer l'interface d'administration Proxmox directement sur Internet.
- Ne pas modifier `vmbr0` ni l'adresse de gestion Proxmox sans procédure de retour arrière.
- Conserver un accès local fonctionnel pendant la mise en place progressive des VLAN.
- Vérifier les chemins réseau réels, et pas uniquement le résultat des tests HTTP.
- Ne jamais versionner de mot de passe, de clé privée ou de secret.

### Prochaine session

1. Confirmer le chemin réseau utilisé pour joindre Proxmox.
2. Vérifier les règles d'administration du VLAN 10 et retirer la règle ICMP temporaire lorsqu'elle ne sera plus nécessaire.
3. Rendre la configuration VLAN du poste Debian persistante.
4. Créer progressivement les VLAN 20, 30 et 40.
5. Tester les règles de filtrage avant de déployer DevSecApp.
6. Préparer l'accès distant par VPN une fois le réseau local stable.

## 2026-10-26 - Validation initiale des VLAN 10 et 20

### Objectif de la session

Poursuivre la configuration du réseau ARES, valider la connectivité des VLAN 10 et 20 depuis le poste Debian et commencer à vérifier les règles de filtrage.

### Configuration et règles mises en place

- VLAN 10 - IT-ADMIN : `10.20.10.0/24`, passerelle `10.20.10.1`.
- VLAN 20 - DEVELOPMENT : `10.20.20.0/24`, passerelle `10.20.20.1`.
- Poste Debian sur le VLAN 10 : `10.20.10.110/24`.
- Poste Debian sur le VLAN 20 : `10.20.20.110/24`, via l'interface temporaire `enp0s31f6.20`.
- Une règle ICMP de diagnostic a été ajoutée temporairement sur le VLAN 20.
- La règle DNS du VLAN 20 a été ajustée pour autoriser TCP et UDP sur le port 53.

Les interfaces VLAN 10 et 20 du poste Debian ont été créées manuellement. Leur configuration n'est pas encore persistante après redémarrage.

### Vérifications réalisées

| Test | Résultat |
|---|---|
| Ping de `10.20.10.1` depuis le VLAN 10 | Réussi : 4 réponses sur 4 |
| Accès à l'interface Web OPNsense via `https://10.20.10.1` | Réussi depuis le navigateur |
| Ping de `10.20.20.1` depuis le VLAN 20 | Réussi : 4 réponses sur 4 après ajout de la règle ICMP temporaire |
| Résolution DNS via `10.20.20.1` | Réussie pour `deb.debian.org`, réponse DNS reçue |
| Accès HTTPS à `deb.debian.org` en forçant l'interface VLAN 20 | Échec : connexion au port 443 impossible |
| Accès HTTPS à `deb.debian.org` sans forcer l'interface | Réussi, mais le routage utilise le Wi-Fi ; ce test ne valide donc pas l'accès Internet du VLAN 20 |

### Analyse et points en attente

La connectivité de base entre le poste Debian et les passerelles des VLAN 10 et 20 est vérifiée. Le service DNS répond depuis le VLAN 20.

L'accès Internet depuis le VLAN 20 n'est pas encore validé. L'échec de la connexion HTTPS ne permet pas, à lui seul, d'identifier la cause. Il faudra vérifier notamment les règles de pare-feu, le NAT sortant et le chemin des paquets, sans modifier la configuration au hasard.

Les VLAN 30 et 40 sont configurés dans OPNsense, mais leur connectivité depuis un poste client reste à tester.

La règle VLAN 20 actuellement nommée `Accès HTTPS à DevSecApp` doit être resserrée lorsque l'adresse du serveur DevSecApp sera définie : elle devra cibler le serveur réel et uniquement les ports nécessaires.

### État du projet

- [x] VLAN 10 : passerelle accessible et interface Web OPNsense utilisable.
- [x] VLAN 20 : passerelle accessible depuis Debian.
- [x] VLAN 20 : résolution DNS validée.
- [ ] VLAN 20 : accès Internet à diagnostiquer.
- [ ] VLAN 30 et VLAN 40 : tests depuis un poste client.
- [ ] Vérifier le filtrage inter-VLAN avec des tests positifs et négatifs.
- [ ] Retirer les règles ICMP temporaires après les tests nécessaires.
- [ ] Rendre la configuration VLAN du poste Debian persistante.
- [ ] Déployer DevSecApp dans le segment serveurs.
- [ ] Configurer et tester le VPN d'accès distant.
- [ ] Automatiser le déploiement avec Terraform et Ansible.

### Prochaine session

1. Vérifier le NAT sortant et diagnostiquer l'accès Internet depuis le VLAN 20.
2. Tester les VLAN 30 et 40 depuis Debian.
3. Vérifier les restrictions entre les VLAN.
4. Nettoyer les règles temporaires et documenter la politique de filtrage.
5. Préparer le déploiement automatisé du serveur et de DevSecApp.

## 2026-10-27 — Network validation and test VM preparation

### Completed
- Reviewed the existing ARES VLAN architecture and firewall rules.
- Confirmed connectivity to the gateways of VLAN 10, VLAN 20, VLAN 30 and VLAN 40.
- Reviewed the `ARES_INTERNAL_NETS` alias and the inter-VLAN blocking rules.
- Confirmed that the Proxmox host has sufficient resources for a lightweight test VM.
- Created the Debian test VM `ares-test-vlan20` to prepare inter-VLAN firewall validation.

### Findings
- VLAN 10 administration access has been partially validated.
- VLAN 20 gateway connectivity and DNS resolution have been validated.
- HTTPS connectivity through VLAN 20 still requires investigation.
- Inter-VLAN isolation has not yet been conclusively validated with separate endpoints.
- Temporary ICMP diagnostic rules are still present and must be reviewed after testing.

### Next steps
1. Complete the Debian installation and configure the test VM network in VLAN 20.
2. Test allowed and denied traffic between VLANs using the test VM.
3. Investigate HTTPS connectivity from VLAN 20.
4. Review and remove temporary diagnostic firewall rules when no longer needed.
5. Update the documentation with the test results.
