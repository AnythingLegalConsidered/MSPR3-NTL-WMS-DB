# Livrable 3 — Guide de supervision

**Statut** : ⏳ à faire
**Exigence sujet** : §III.1 « Guide de supervision avec indicateurs, seuils et procédures de remédiation » + §II.5 « tableau de bord contenant 5 indicateurs critiques »
**Owner** : à définir

## Contenu attendu

- [ ] Sélection de 5 indicateurs critiques (hardware + software mix)
  - Suggestions de départ :
    1. Disponibilité du cluster Galera (nœuds UP, latence réplication `wsrep_local_recv_queue`)
    2. Espace disque data + binlog (seuil 80% warning / 90% critique)
    3. Connexions concurrentes (`Threads_connected` vs `max_connections`)
    4. Latence requêtes p95 + slow query count
    5. Succès dernière sauvegarde (timestamp, code retour, taille cohérente)
- [ ] Pour chaque indicateur :
  - Source (collecteur, requête, log)
  - Seuils warning / critique
  - Procédure d'analyse (« quoi faire si l'alerte se déclenche »)
  - Procédure de remédiation
- [ ] Outil retenu (Zabbix existant chez NTL d'après annexe C, ou Prometheus + Grafana, ou PMM)
- [ ] Dashboard mockup (capture ou description)

## Décisions structurantes

À documenter dans `../decisions/`.

## Point d'entrée pour démarrer

Annexe C du sujet : `SUPER-01` existe déjà avec Zabbix → privilégier extension Zabbix plutôt que nouvelle stack. Sujet §I mentionne « la supervision demeure surtout technique [...] et couvre insuffisamment l'expérience service » → cibler des indicateurs orientés service, pas juste host/disque.
