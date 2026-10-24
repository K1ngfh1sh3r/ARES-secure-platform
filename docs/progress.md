# ARES - Journal d'avancement

## 2026-10-24 - Premier démarrage d'OPNsense

### Objectif de la session

Mettre en place la première brique réseau du projet ARES, tout en préservant l'accès à Proxmox et à Internet depuis le poste Debian.

### Environnement

- Hyperviseur : Proxmox VE 9.2.2.
- Routeur/pare-feu : OPNsense 26.7, installé dans une VM.
- Poste d'administration : Debian.
- Dépôt : `K1ngfh1sh3r/ARES-secure-platform`.

### Configuration réseau

| Élément | Configuration actuelle |
|---|---|
| `vmbr0` | Bridge Proxmox existant, conservé pour la gestion et le réseau domestique |
| `vmbr1` | Bridge dédié au LAN ARES, associé à `nic1`, VLAN-aware |
| WAN OPNsense | `vtnet0`, adresse DHCP `192.168.1.92/24` |
| LAN OPNsense | `vtnet1`, adresse `10.20.10.1/24` |
| Poste Debian - Ethernet | `10.20.10.110/24` |
| Poste Debian - Wi-Fi | Réseau domestique, conservé pour l'accès Internet |

Le WAN utilise le réseau domestique `192.168.1.0/24`. Le LAN ARES utilise un sous-réseau distinct afin d'éviter le chevauchement avec le WAN.

L'adresse de gestion de Proxmox reste `192.168.1.70/24`. Sa configuration n'a pas été modifiée pendant cette session.

### Vérifications réalisées

Depuis le poste Debian :

| Test | Résultat |
|---|---|
| Ping de `10.20.10.1` | 3 paquets reçus sur 3 |
| Ping de `192.168.1.70` | 3 paquets reçus sur 3 |
| Ping de `deb.debian.org` | 3 paquets reçus sur 3 |

Depuis le shell OPNsense, les tests précédents vers `1.1.1.1` et `deb.debian.org` ont également réussi.

L'accès à l'interface Web d'administration OPNsense est fonctionnel depuis le LAN.

### État fonctionnel à la fin de la session

- [x] OPNsense installé et démarré.
- [x] WAN et LAN identifiés et configurés.
- [x] Sous-réseaux WAN et LAN distincts.
- [x] Accès au tableau de bord OPNsense.
- [x] Accès à l'interface de gestion Proxmox préservé.
- [x] Connectivité Internet du poste Debian vérifiée.
- [ ] VLAN 10, 20, 30 et 40 configurés et testés.
- [ ] Règles de filtrage inter-VLAN implémentées et vérifiées.
- [ ] Déploiement de DevSecApp sur l'infrastructure.
- [ ] Accès distant par VPN configuré et testé.
- [ ] Infrastructure as Code et automatisation du déploiement.

### Points de vigilance

- Ne pas exposer l'interface d'administration Proxmox directement sur Internet.
- Ne pas modifier `vmbr0` ni l'adresse de gestion Proxmox sans procédure de retour arrière.
- Conserver un accès local fonctionnel pendant la mise en place progressive des VLAN.
- Vérifier les règles du pare-feu avant d'autoriser les communications entre segments.
- Ne jamais versionner de mot de passe, de clé privée ou de secret.

### Prochaine session

1. Sauvegarder la configuration OPNsense.
2. Vérifier et documenter les paramètres réseau de la VM dans Proxmox.
3. Préparer la configuration VLAN progressive.
4. Définir et tester les règles de filtrage avant le déploiement de DevSecApp.
5. Préparer ensuite l'accès distant par VPN.
