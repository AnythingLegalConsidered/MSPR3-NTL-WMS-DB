---
livrable: "01 — Architecture technique"
scope: "01-architecture"
section: "MLD WMS simplifié"
version: "1.0"
status: "valide"
owner: "Ianis"
created: "2026-05-22"
updated: "2026-05-22"
related:
  - "../mcd/wms-mcd.md"
  - "../ddl/wms-schema.sql"
---

# MLD WMS — version simplifiée

> Dérivé direct de [`mcd/wms-mcd.md`](../mcd/wms-mcd.md). Conventions : `snake_case`, PK auto-incrémentée `id_*`, FK `id_*` typées `INT UNSIGNED`, attributs accentués du MCD normalisés en ASCII (`allée → allee`, `étage → etage`, `quantité → quantite`).

## 1. Règles de passage MCD → MLD

| Cas MCD | Règle appliquée |
|---|---|
| Entité | → Table avec PK `id_<entite>` auto-incrémentée |
| Association 1-N (cardinalité max 1 d'un côté) | → FK dans la table côté (1,1) ou (0,1) |
| Association N-N | → Table associative avec PK composite + FK individuelles |
| Attributs accentués / unicode | → Normalisation ASCII pour compat MariaDB / portabilité scripts |

## 2. Tables (9)

### 2.1 Tables issues d'entités (7)

#### `site`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_site` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `libelle` | VARCHAR(100) | NOT NULL |
| `adresse` | VARCHAR(255) | NOT NULL |

#### `localisation`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_localisation` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `code` | VARCHAR(30) | NOT NULL, UNIQUE |
| `zone` | VARCHAR(30) | NOT NULL |
| `allee` | VARCHAR(10) | NOT NULL |
| `etage` | VARCHAR(10) | NOT NULL |
| `place` | VARCHAR(10) | NOT NULL |
| `id_site` | INT UNSIGNED | NOT NULL, FK → `site(id_site)` |

> FK `id_site` issue de l'association `CONTENIR` (LOCALISATION 1,1 — SITE 1,N).

#### `utilisateur`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_utilisateur` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `nom` | VARCHAR(100) | NOT NULL |
| `role` | VARCHAR(30) | NOT NULL |

#### `client`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_client` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `nom` | VARCHAR(100) | NOT NULL |
| `siret` | CHAR(14) | NOT NULL, UNIQUE |
| `telephone` | VARCHAR(20) | NULL |
| `status` | VARCHAR(20) | NOT NULL, DEFAULT 'actif' |
| `id_utilisateur` | INT UNSIGNED | NOT NULL, FK → `utilisateur(id_utilisateur)` |

> FK `id_utilisateur` issue de l'association `ECHANGER` (CLIENT 1,1 — UTILISATEUR 1,N).

#### `article`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_article` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `nom` | VARCHAR(150) | NOT NULL |
| `poids` | DECIMAL(10,3) | NOT NULL, CHECK (poids > 0) |
| `fournisseur` | VARCHAR(100) | NULL |
| `type` | VARCHAR(50) | NOT NULL |

#### `stock`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_stock` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `quantite` | INT UNSIGNED | NOT NULL, DEFAULT 0 |
| `id_localisation` | INT UNSIGNED | NOT NULL, FK → `localisation(id_localisation)` |

> FK `id_localisation` issue de l'association `CONTENIR` (STOCK 1,1 — LOCALISATION 1,N).

#### `mouvement`
| Colonne | Type | Contrainte |
|---|---|---|
| `id_mouvement` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `type` | VARCHAR(20) | NOT NULL (ex: entree, sortie, ajustement) |
| `reference` | VARCHAR(50) | NOT NULL, UNIQUE |
| `date` | DATE | NOT NULL |
| `heure` | TIME | NOT NULL |
| `id_stock` | INT UNSIGNED | NULL, FK → `stock(id_stock)` |
| `id_utilisateur` | INT UNSIGNED | NOT NULL, FK → `utilisateur(id_utilisateur)` |

> FK `id_stock` issue de `EFFECTUER` (STOCK 0,1 — MOUVEMENT 1,1) — NULL autorisé car cardinalité (0,1) côté STOCK.
> FK `id_utilisateur` issue de `REALISER` (UTILISATEUR 0,N — MOUVEMENT 1,1).
> **Écart MCD :** la FK `id_stock` n'est PAS UNIQUE pour permettre l'historisation des mouvements sur un même stock (voir `mcd/wms-mcd.md` §3).

### 2.2 Tables associatives (2)

#### `commande` (CLIENT ↔ ARTICLE)
| Colonne | Type | Contrainte |
|---|---|---|
| `id_commande` | INT UNSIGNED | PK, AUTO_INCREMENT |
| `id_client` | INT UNSIGNED | NOT NULL, FK → `client(id_client)` |
| `id_article` | INT UNSIGNED | NOT NULL, FK → `article(id_article)` |
| `quantite_commandee` | INT UNSIGNED | NOT NULL, CHECK (quantite_commandee > 0) |
| `date_commande` | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

> Index combiné `(id_client, id_article)` pour requêtes fréquentes type "qu'a commandé ce client".

#### `article_stock` (ARTICLE ↔ STOCK)
| Colonne | Type | Contrainte |
|---|---|---|
| `id_article` | INT UNSIGNED | PK composite, FK → `article(id_article)` |
| `id_stock` | INT UNSIGNED | PK composite, FK → `stock(id_stock)` |
| `date_ajout` | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

> PK composite `(id_article, id_stock)` : un même couple (article, stock) ne peut exister qu'une fois.

## 3. Schéma relationnel textuel

```
site(id_site, libelle, adresse)
localisation(id_localisation, code, zone, allee, etage, place, #id_site)
utilisateur(id_utilisateur, nom, role)
client(id_client, nom, siret, telephone, status, #id_utilisateur)
article(id_article, nom, poids, fournisseur, type)
stock(id_stock, quantite, #id_localisation)
mouvement(id_mouvement, type, reference, date, heure, #id_stock, #id_utilisateur)
commande(id_commande, #id_client, #id_article, quantite_commandee, date_commande)
article_stock(#id_article, #id_stock, date_ajout)
```

Convention : `#` préfixe une clé étrangère ; soulignement implicite pour la PK (premier champ).

## 4. Diagramme des dépendances FK

```
site ◄── localisation ◄── stock ◄── article_stock ──► article
                                        ▲                ▲
                                        │                │
                                     mouvement        commande
                                        │                │
                                        ▼                ▼
                                  utilisateur ◄── client
```

## 5. Index recommandés (au-delà des PK/UK)

| Table | Index | Justification |
|---|---|---|
| `localisation` | `idx_localisation_site (id_site)` | Filtre fréquent localisations d'un site |
| `stock` | `idx_stock_localisation (id_localisation)` | Inventaire par emplacement |
| `mouvement` | `idx_mouvement_date (date)` | Reporting journalier |
| `mouvement` | `idx_mouvement_stock (id_stock)` | Historique d'un stock |
| `commande` | `idx_commande_client (id_client)` | Commandes d'un client |
| `client` | `idx_client_utilisateur (id_utilisateur)` | Portefeuille d'un gestionnaire |

## 6. Contraintes d'intégrité

- **CHECK** sur `article.poids > 0` (poids strictement positif).
- **CHECK** sur `commande.quantite_commandee > 0`.
- **UNIQUE** sur `client.siret` (un SIRET = un client).
- **UNIQUE** sur `mouvement.reference` (référence métier traçabilité).
- **UNIQUE** sur `localisation.code` (code physique d'emplacement).
- **ON DELETE RESTRICT** par défaut sur toutes les FK (refus suppression cascade — protection métier).
