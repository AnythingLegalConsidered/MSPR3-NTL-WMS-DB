# Livrable 4 — Démarche d'optimisation BDD

**Statut** : ⏳ à faire (amorcé partiellement dans MLD §7 « Index recommandés »)
**Exigence sujet** : §III.1 « Démarche suivie pour l'optimisation de la base de données (usages, tests, scénarios, résultats obtenus) »
**Owner** : à définir

## Contenu attendu

- [ ] Identification des requêtes fréquentes (top 10 attendu en production)
  - Sortie stock par client
  - Historique mouvements par site / par article / par utilisateur
  - Recherche article par référence (multi-tenant)
  - Reporting périodique CODIR
- [ ] Plan de tests de performance
  - Jeu de données synthétique (volume cible : ~5 clients, ~50 articles/client, ~200 emplacements, ~1M mouvements sur 12 mois)
  - Script `EXPLAIN` sur les top 10 requêtes
  - Mesures avant / après index
- [ ] Index ajoutés (cf. [`../01-architecture-technique/mld/wms-mld.md`](../01-architecture-technique/mld/wms-mld.md) §7 et [`../01-architecture-technique/ddl/wms-schema.sql`](../01-architecture-technique/ddl/wms-schema.sql))
- [ ] Résultats obtenus (avant/après mesurés)
- [ ] Limites identifiées et perspectives V2 (partitioning `mouvements` par exemple)

## Décisions structurantes

À documenter dans `../decisions/`.

## Point d'entrée pour démarrer

1. Écrire un seed `ddl/seed.sql` avec données synthétiques cohérentes
2. `EXPLAIN ANALYZE` sur les top 10 requêtes avant index
3. Vérifier que les index actuels (cf. MLD §7) sont effectivement utilisés
4. Mesurer écart avant/après
