---
livrable: "01 — Architecture technique"
scope: "01-architecture"
section: "MCD WMS simplifié"
version: "1.0"
status: "valide"
owner: "Ianis"
created: "2026-05-22"
updated: "2026-05-22"
related:
  - "./wms-mcd.png"
  - "../mld/wms-mld.md"
  - "../ddl/wms-ddl.md"
---

# MCD WMS — version simplifiée

> Remplace la V4 du 2026-05-21 (archivée dans [`99-archive/01-architecture-technique-v1/`](../../99-archive/01-architecture-technique-v1/)). Choix d'un modèle compact (7 entités, 7 associations) pour la défense soutenance.

Le schéma graphique de référence est `wms-mcd.png` (à déposer manuellement dans ce dossier).

## 1. Entités (7)

| # | Entité | Identifiant | Attributs |
|---|---|---|---|
| 1 | `ARTICLE` | `id_article` | `nom`, `poids`, `fournisseur`, `type` |
| 2 | `CLIENT` | `id_client` | `nom`, `siret`, `telephone`, `status` |
| 3 | `STOCK` | `id_stock` | `quantité` |
| 4 | `LOCALISATION` | `id_localisation` | `code`, `zone`, `allée`, `étage`, `place` |
| 5 | `SITE` | `id_site` | `libelle`, `adresse` |
| 6 | `UTILISATEUR` | `id_utilisateur` | `nom`, `role` |
| 7 | `MOUVEMENT` | `id_mouvement` | `type`, `reference`, `date`, `heure` |

## 2. Associations (7)

| Association | Entité A | Card. A | Entité B | Card. B | Nature |
|---|---|---|---|---|---|
| `COMMANDE` | CLIENT | 0,N | ARTICLE | 1,N | N-N (table associative) |
| `CONTENIR` (article–stock) | ARTICLE | 1,N | STOCK | 0,N | N-N (table associative) |
| `CONTENIR` (stock–localisation) | STOCK | 1,1 | LOCALISATION | 1,N | 1-N (FK côté STOCK) |
| `CONTENIR` (localisation–site) | LOCALISATION | 1,1 | SITE | 1,N | 1-N (FK côté LOCALISATION) |
| `ECHANGER` | CLIENT | 1,1 | UTILISATEUR | 1,N | 1-N (FK côté CLIENT) |
| `EFFECTUER` | STOCK | 0,1 | MOUVEMENT | 1,1 | 1-N pragmatique (FK côté MOUVEMENT) — voir §3 |
| `REALISER` | UTILISATEUR | 0,N | MOUVEMENT | 1,1 | 1-N (FK côté MOUVEMENT) |

## 3. Écarts d'interprétation pour le passage au MLD

Deux cardinalités du MCD posent des contraintes peu réalistes en production. Choix retenus pour le DDL :

| Association MCD | Lecture stricte | Choix MLD/DDL | Justification |
|---|---|---|---|
| `EFFECTUER` STOCK (0,1) — MOUVEMENT (1,1) | Un stock ne peut être impacté que par 1 mouvement (toute sa vie) | FK `id_stock` non-UNIQUE dans `mouvement` | Un stock subit N mouvements (entrée, sortie, ajustement…). Strict UNIQUE bloquerait toute traçabilité. |
| `CONTENIR` ARTICLE (1,N) — STOCK (0,N) | N-N classique | Table associative `article_stock` avec `date_ajout` | Permet historiser quand un article a été rattaché à un emplacement de stock. |

Ces écarts sont signalés au jury à l'oral : MCD = vision conceptuelle métier, MLD = vision implémentable.

## 4. Règles de gestion appliquées

- **RG1** : un article appartient à au moins un client (commande). Un nouvel article sans commande n'est pas modélisable côté MCD (cardinalité 1,N obligatoire côté ARTICLE).
- **RG2** : un stock est toujours localisé sur exactement une localisation (cardinalité 1,1 côté STOCK).
- **RG3** : une localisation appartient à exactement un site (cardinalité 1,1 côté LOCALISATION).
- **RG4** : chaque client est géré par un utilisateur unique (gestionnaire de compte).
- **RG5** : chaque mouvement est tracé par un utilisateur unique (responsabilité opérationnelle).

## 5. Diagramme

Le diagramme graphique (PNG) doit être déposé en `wms-mcd.png`. Source originale : capture de l'outil de modélisation utilisé en réunion équipe le 2026-05-22.
