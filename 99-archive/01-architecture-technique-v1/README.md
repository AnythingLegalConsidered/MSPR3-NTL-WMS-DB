# Livrable 1 — Document d'architecture technique

**Statut** : 🟡 en cours
**Exigence sujet** : §III.1 « MCD et MLD, justification du SGBD, schémas d'architectures, hébergement et hardware, index et optimisations, politiques d'accès, politiques de sauvegardes »
**Owner** : Ianis

## Contenu

| Sous-livrable | Statut | Fichier(s) |
|---|---|---|
| MCD V4 officiel | ✅ | [`mcd/wms-mcd.md`](mcd/wms-mcd.md) + sources Mocodo |
| MCD soutenance (version courte) | ✅ | [`mcd/mcd-operationnel.md`](mcd/mcd-operationnel.md) |
| MLD V1 | ✅ draft | [`mld/wms-mld.md`](mld/wms-mld.md) |
| DDL MariaDB 11.4 | ✅ exécuté + testé | [`ddl/wms-ddl.md`](ddl/wms-ddl.md) + [`ddl/wms-schema.sql`](ddl/wms-schema.sql) |
| Justification SGBD | ⏳ à créer | `justification-sgbd.md` |
| Schémas architecture | ⏳ à créer | `schemas-architecture.md` |
| Hébergement et hardware | ⏳ à créer | `hebergement-hardware.md` |
| Index et optimisations | 🟡 amorcé dans `mld/wms-mld.md` §7 | à formaliser |
| Politiques d'accès | ⏳ à créer | renvoyer vers livrable 1 ou livrable sécurité dédié |
| Politiques de sauvegardes | ⏳ à créer | à coordonner avec [`02-pra/`](../02-pra/) |

## Décisions structurantes

- [`decisions/0001-bug-mariadb-check.md`](../decisions/0001-bug-mariadb-check.md) — bug parser MariaDB 11.4, contournement par triggers
- Historique des arbitrages V4 : [`mcd/arbitrages-v4-ianis.md`](mcd/arbitrages-v4-ianis.md)
- Journal de synthèse pour soutenance : [`../07-gestion-projet/journal-decisions.md`](../07-gestion-projet/journal-decisions.md)

## Point d'entrée pour démarrer

1. Lire [`mcd/wms-mcd.md`](mcd/wms-mcd.md) (cœur conceptuel)
2. Lire [`mld/wms-mld.md`](mld/wms-mld.md) (modèle logique)
3. Exécuter [`ddl/wms-schema.sql`](ddl/wms-schema.sql) sur MariaDB 11.4
4. Pour les sous-livrables restants : créer le fichier `.md` ici, ajouter le frontmatter, mettre à jour le tableau ci-dessus.
