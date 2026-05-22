# Livrable 1 — Document d'architecture technique

**Statut** : 🟡 en cours
**Exigence sujet** : §III.1 « MCD et MLD, justification du SGBD, schémas d'architectures, hébergement et hardware, index et optimisations, politiques d'accès, politiques de sauvegardes »
**Owner** : Ianis
**Version** : 2.0 (MCD simplifié) — la V1 (8 entités) est archivée dans [`../99-archive/01-architecture-technique-v1/`](../99-archive/01-architecture-technique-v1/)

## Contenu

| Sous-livrable | Statut | Fichier(s) |
|---|---|---|
| MCD (7 entités) | ✅ | [`mcd/wms-mcd.md`](mcd/wms-mcd.md) |
| Diagramme MCD (PNG) | ⏳ à déposer | `mcd/wms-mcd.png` |
| MLD | ✅ | [`mld/wms-mld.md`](mld/wms-mld.md) |
| DDL MariaDB 11.4 | ✅ (à tester sur instance) | [`ddl/wms-schema.sql`](ddl/wms-schema.sql) + [`ddl/wms-ddl.md`](ddl/wms-ddl.md) |
| Justification SGBD | ⏳ à créer | `justification-sgbd.md` |
| Schémas architecture | ⏳ à créer | `schemas-architecture.md` |
| Hébergement et hardware | ⏳ à créer | `hebergement-hardware.md` |
| Index et optimisations | 🟡 amorcé dans `mld/wms-mld.md` §5 | à formaliser |
| Politiques d'accès | ⏳ à créer | `politiques-acces.md` |
| Politiques de sauvegardes | ⏳ à créer | à coordonner avec [`../02-pra/`](../02-pra/) |

## Modèle de données

7 entités + 2 tables associatives = **9 tables** dans le DDL.

```
SITE ──< LOCALISATION ──< STOCK ──< ARTICLE_STOCK >── ARTICLE
                            │                            │
                            └──< MOUVEMENT               │
                                    │                    │
                                    └──> UTILISATEUR ──< CLIENT
                                                          │
                                                          └──< COMMANDE >── ARTICLE
```

## Point d'entrée pour démarrer

1. Lire [`mcd/wms-mcd.md`](mcd/wms-mcd.md) (cœur conceptuel)
2. Lire [`mld/wms-mld.md`](mld/wms-mld.md) (modèle logique)
3. Exécuter [`ddl/wms-schema.sql`](ddl/wms-schema.sql) sur MariaDB 11.4
4. Pour les sous-livrables restants : créer le `.md` ici, ajouter le frontmatter, mettre à jour le tableau ci-dessus.

## Historique

- **2026-05-22** : passage au MCD simplifié 7 entités. V1 (8 entités, arbitrages V4, bug parser MariaDB) archivée.
- **2026-05-21** : V1 finalisée (voir archive).
