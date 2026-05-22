---
livrable: "01 — Architecture technique"
scope: "01-architecture"
section: "DDL MariaDB 11.4"
version: "1.0"
status: "à tester"
owner: "Ianis"
created: "2026-05-22"
updated: "2026-05-22"
related:
  - "./wms-schema.sql"
  - "../mld/wms-mld.md"
  - "../mcd/wms-mcd.md"
---

# DDL WMS — MariaDB 11.4

> Implémentation SQL du MLD simplifié. Script unique : [`wms-schema.sql`](wms-schema.sql).

## 1. Cible technique

| Élément | Valeur |
|---|---|
| SGBD | MariaDB 11.4 LTS |
| Moteur de stockage | InnoDB (FK + transactions ACID) |
| Charset | `utf8mb4` |
| Collation | `utf8mb4_unicode_ci` |
| Contraintes CHECK | Supportées nativement depuis MariaDB 10.2 |

## 2. Ordre de création

L'ordre est imposé par les dépendances FK :

1. `site` (racine, aucune FK)
2. `localisation` → FK `site`
3. `utilisateur` (racine)
4. `client` → FK `utilisateur`
5. `article` (racine)
6. `stock` → FK `localisation`
7. `mouvement` → FK `stock`, `utilisateur`
8. `commande` (associative) → FK `client`, `article`
9. `article_stock` (associative) → FK `article`, `stock`

Le script utilise `SET FOREIGN_KEY_CHECKS = 0` pour le DROP préliminaire afin de pouvoir purger dans n'importe quel ordre.

## 3. Contraintes appliquées

### 3.1 Clés primaires
Toutes auto-incrémentées `INT UNSIGNED` sauf `article_stock` (PK composite `(id_article, id_stock)`).

### 3.2 Clés étrangères

| Table | Colonne | Référence | ON DELETE | Raison |
|---|---|---|---|---|
| `localisation` | `id_site` | `site(id_site)` | RESTRICT | Refus suppression d'un site avec localisations |
| `client` | `id_utilisateur` | `utilisateur(id_utilisateur)` | RESTRICT | Un gestionnaire ne peut être supprimé s'il a des clients |
| `stock` | `id_localisation` | `localisation(id_localisation)` | RESTRICT | Pas de stock orphelin |
| `mouvement` | `id_stock` | `stock(id_stock)` | SET NULL | Si stock supprimé, l'historique des mouvements reste (traçabilité) |
| `mouvement` | `id_utilisateur` | `utilisateur(id_utilisateur)` | RESTRICT | Traçabilité humaine obligatoire |
| `commande` | `id_client`, `id_article` | client / article | RESTRICT | Protection métier |
| `article_stock` | `id_article`, `id_stock` | article / stock | CASCADE | Lien d'association : se purge avec les entités liées |

### 3.3 Contraintes UNIQUE

| Table | Colonne(s) | Justification |
|---|---|---|
| `localisation` | `code` | Code physique unique d'emplacement |
| `client` | `siret` | Identifiant légal unique |
| `mouvement` | `reference` | Numéro de traçabilité métier |

### 3.4 Contraintes CHECK

| Table | Nom | Règle |
|---|---|---|
| `article` | `ck_article_poids` | `poids > 0` |
| `commande` | `ck_commande_quantite` | `quantite_commandee > 0` |
| `mouvement` | `ck_mouvement_type` | `type IN ('entree','sortie','ajustement','transfert')` |

## 4. Index secondaires

Tous les index FK sont créés explicitement (MariaDB les crée automatiquement avec une FK mais on les nomme pour cohérence et maintenance) :

- `idx_localisation_site`
- `idx_client_utilisateur`
- `idx_stock_localisation`
- `idx_mouvement_date` ← reporting journalier
- `idx_mouvement_stock`
- `idx_mouvement_utilisateur`
- `idx_commande_client`
- `idx_commande_article`
- `idx_article_stock_stock`

## 5. Exécution

```bash
# Connexion MariaDB
mysql -h <host> -u <user> -p

# Création de la base
CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE wms;

# Exécution du script
SOURCE 01-architecture-technique/ddl/wms-schema.sql;

# Vérification
SHOW TABLES;
-- Attendu : 9 tables
--   article, article_stock, client, commande, localisation,
--   mouvement, site, stock, utilisateur
```

## 6. Vérifications post-exécution

```sql
-- Compter les tables (attendu : 9)
SELECT COUNT(*) AS nb_tables
FROM information_schema.tables
WHERE table_schema = 'wms';

-- Vérifier les FK (attendu : 9 contraintes FK)
SELECT COUNT(*) AS nb_fk
FROM information_schema.referential_constraints
WHERE constraint_schema = 'wms';

-- Vérifier les CHECK (attendu : 3)
SELECT COUNT(*) AS nb_check
FROM information_schema.check_constraints
WHERE constraint_schema = 'wms';
```

## 7. Écarts vs MCD strict

| Élément | MCD | DDL | Raison |
|---|---|---|---|
| `mouvement.id_stock` | UNIQUE (cardinalité 0,1 côté STOCK) | NON-UNIQUE | Permet l'historique de mouvements sur un même stock |
| `article_stock` | Association pure N-N | Table avec attribut `date_ajout` | Traçabilité des affectations |
| Accents attributs | `quantité`, `allée`, `étage` | `quantite`, `allee`, `etage` | Compat ASCII / scripts portables |

## 8. Statut tests

À ce stade le script n'a **pas encore** été exécuté sur MariaDB 11.4. À faire :

- [ ] Exécution sur instance MariaDB 11.4 locale
- [ ] Vérification des 3 CHECK (insérer poids=0, qté=0, type='foo' → doit échouer)
- [ ] Vérification des FK (insérer FK invalide → doit échouer)
- [ ] Test ON DELETE RESTRICT (tenter delete d'un site avec localisation → doit échouer)
- [ ] Test ON DELETE SET NULL sur `mouvement.id_stock` (supprimer stock → mouvement.id_stock devient NULL)
