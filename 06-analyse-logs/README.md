# Livrable 6 — Analyse de journaux (logs)

**Statut** : ⏳ à faire
**Exigence sujet** : §III.1 « Analyse de logs » + §II.6 « identifier les journaux pertinents (SGBD/OS/backup/reverse proxy/réplication) et proposer une méthode d'analyse : quelles traces, quels patterns, quels seuils, quelle corrélation »
**Owner** : à définir

## Contenu attendu

- [ ] **Cartographie des journaux**
  - SGBD MariaDB : `error log`, `general log` (optionnel), `slow query log`, `binary log`, `audit log` (plugin)
  - Galera : `gcs.log`, `galera.cache`, latence réplication
  - OS Linux : `/var/log/syslog`, `/var/log/auth.log`, `journalctl`
  - Backup : sortie `mariabackup`, code retour, checksum
  - Reverse proxy / load balancer (si présent : HAProxy / ProxySQL)
- [ ] **Patterns à détecter**
  - Tentatives de connexion échouées répétées (bruteforce)
  - Slow queries > seuil
  - Erreurs de réplication (gtid mismatch, certif failure)
  - Saturation disque imminente
  - Échecs sauvegarde consécutifs
- [ ] **Seuils** (X événements en Y minutes = alerte)
- [ ] **Corrélation** : exemple « slow queries en hausse + load CPU + connexions max » = symptôme A
- [ ] **Outil** retenu (Loki / Graylog / ELK / Fluent Bit + Zabbix)
- [ ] **Rétention** logs (RGPD-friendly, ex. 90j ligne / 1an agrégé)

## Décisions structurantes

À documenter dans `../decisions/`.

## Point d'entrée pour démarrer

NTL n'a pas de stack de log centralisé d'après le sujet (§I « la documentation existe mais reste dispersée »). Privilégier une stack légère cohérente avec Zabbix existant : Fluent Bit → Loki → Grafana est un combo courant et compact.
