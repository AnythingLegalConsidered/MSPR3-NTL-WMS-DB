# Livrable 2 — Plan de Reprise d'Activité (PRA)

**Statut** : ⏳ à faire
**Exigence sujet** : §III.1 « Plan de reprise d'activité » + §II.3 « décrire le PRA en cas de perte de la base de données et les éléments permettant sa mise en place (sauvegardes, tests de restauration) »
**Contraintes** : RTO 1h, RPO 15 min
**Owner** : à définir

## Contenu attendu

- [ ] Identification des scénarios de sinistre (perte VM, perte site, perte cluster, corruption logique)
- [ ] Architecture HA cible (Galera 3 nœuds recommandé)
- [ ] Politique de sauvegarde
  - [ ] Sauvegarde complète (fréquence, outil — `mariabackup` recommandé)
  - [ ] Sauvegarde incrémentale / transactionnelle (binlog)
  - [ ] Rotation et rétention (J+7, S+4, M+12 typique)
  - [ ] Vérification automatique (checksum, restauration test mensuelle)
  - [ ] Notification (succès/échec)
- [ ] Scripts ou playbooks d'automatisation (bash / Ansible)
- [ ] Procédure de restauration documentée (RPO 15 min vérifiable)
- [ ] Procédure de failover Galera (RTO < 1h vérifiable)
- [ ] Plan de tests de restauration périodique
- [ ] Stockage des sauvegardes (NAS local + externalisation hors site recommandée)

## Décisions structurantes

À documenter au fur et à mesure dans `../decisions/` avec ID séquentiel.

## Point d'entrée pour démarrer

Lire le sujet `../ressources/sujet-mspr3.pdf` §II.2 et §II.3 + section infra existante (Annexes B et C). Cluster Galera typique : 3 nœuds, un par site (Lille + WH1 + WH2 ou siège + 2 sites).
