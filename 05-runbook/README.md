# Livrable 5 — RunBook d'exploitation

**Statut** : ⏳ à faire
**Exigence sujet** : §III.1 « RunBook d'exploitation »
**Owner** : à définir

## Contenu attendu (liste explicite du sujet)

- [ ] Procédures **start / stop** du cluster (ordre, vérifications, rollback)
- [ ] Procédures de **contrôle de santé** (commandes à lancer, sorties attendues)
- [ ] **Checklist quotidienne**
  - Vérification cluster Galera (état nœuds, latence)
  - Vérification dernière sauvegarde
  - Vérification espace disque
  - Vérification slow queries
- [ ] **Checklist hebdomadaire**
  - Restauration test partielle
  - Revue alertes Zabbix
  - Revue logs anormaux
- [ ] **Procédure incident** : détection → diagnostic → correction → retour à la normale
  - Template d'investigation
  - Exemples de scénarios (perte nœud, slow query, plein disque, corruption)
- [ ] **Matrice d'escalade** N1 / N2 / N3 + délais cibles
  - N1 : technicien support NTL (alternant + support)
  - N2 : administrateur systèmes/réseau itinérant NTL
  - N3 : responsable informatique NTL + éventuel prestataire
- [ ] **KPIs** (le sujet liste : latence, connexions, erreurs, espace disque, réplication, succès sauvegarde) → cohérence avec [`../03-supervision/`](../03-supervision/)

## Décisions structurantes

À documenter dans `../decisions/`.

## Point d'entrée pour démarrer

Contraintes : fenêtre maintenance 18h30 → 5h30 ouvré uniquement. Toute procédure planifiée doit tenir dans cette plage. Procédures d'urgence doivent être réalisables en journée sans interrompre l'activité (quais, étiquettes, RF, EDI transporteurs).
