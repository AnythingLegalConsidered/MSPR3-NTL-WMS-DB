---
livrable: "01 — Architecture technique"
scope: "01-architecture"
section: "MCD WMS-DB v1 simplifié"
version: "0.7"
status: "draft"
owner: "Ianis"
reviewers: ["Blaise", "Zaid", "Ojvind"]
contributors: ["Ianis"]
ia_used: ["Claude Code"]
created: "2026-05-20"
updated: "2026-05-20"
related:
  - "./mcd-operationnel.md"
  - "./wms-mld.md"
  - "./wms-ddl.sql"
  - "../DECISIONS.md"
---

# 01 — MCD WMS-DB (v1 simplifié — 7 entités)

> **Objectif (1 phrase)** : modèle conceptuel Merise du WMS de NTL, V1 simplifiée à 7 entités, défendable en soutenance et dérivable en MLD/DDL MariaDB 11.4 LTS.

## 1. Contexte

Après revue collective et arbitrage avec un intervenant pédagogique, l'équipe a décidé de simplifier radicalement le modèle V1. Les versions antérieures à 14 entités (lots/FEFO, DLC, commandes, réceptions, expéditions, transporteurs) ont été repoussées en V2. La V1 livrée est un **cœur cohérent** — modélisation propre des cardinalités Merise — plutôt qu'un modèle complet bancal hors temps imparti (4 personnes × 19 h).

La séparation des données par client demandée dans le sujet est conservée sans réintroduire le modèle complexe : `CLIENT` représente le donneur d'ordre B2B propriétaire des articles, et chaque `ARTICLE` appartient à exactement un `CLIENT`. Au MLD/DDL, `STOCK` et `MOUVEMENT` portent aussi `id_client` avec FK composite vers `ARTICLE` pour empêcher une incohérence client/article.

Le fournisseur n'est **pas modélisé comme entité** en V1 : c'est un simple attribut texte `fournisseur` porté par `ARTICLE`. Conséquence : pas d'association N:N à éclater au MLD, pas d'association `livre` côté `MOUVEMENT` (l'origine d'une entrée se lit via l'article). C'est un choix MVP assumé, à promouvoir en entité en V2 si NTL a besoin de tracer le fournisseur d'une entrée indépendamment du fournisseur principal de l'article.

Ce MCD est **purement conceptuel** : pas de clé étrangère, pas de type SQL, pas de contrainte d'implémentation. Les identifiants Merise (en `MAJUSCULES` dans le tableau) sont soulignés sur le diagramme. Tout descend au MLD ([`wms-mld.md`](wms-mld.md)) puis au DDL ([`wms-ddl.sql`](wms-ddl.sql)).

## 2. Périmètre

**Inclus** :

- Liste des 7 entités V1 avec identifiant Merise et attributs métier.
- Associations binaires avec cardinalités Merise (min,max) côté chaque entité.
- Diagramme Mermaid `erDiagram` source.
- Limites V1 et améliorations envisagées en V2 (cf. §4).

**Exclus** :

- Clés étrangères, identifiants techniques `id_xxx` → portés au MLD.
- Types SQL, contraintes CHECK, index → portés au DDL.
- Entité `FOURNISSEUR`, lots/FEFO/DLC, commandes/réceptions/expéditions, transporteurs, destinataire final d'une sortie → reportés V2 (cf. §4).
- Justification SGBD (déjà tranchée — MariaDB 11.4 LTS) → voir [DECISIONS.md](../DECISIONS.md) A1.

## 3. Contenu

### 3.1 Entités (7)

> **Notation** : l'identifiant Merise est noté en `MAJUSCULES` (souligné sur le diagramme). Les autres attributs sont en minuscules.

| # | Entité | Rôle opérationnel | Identifiant + attributs métier |
|---|--------|-------------------|--------------------------------|
| 1 | `SITE` | Site physique NTL (Lille, WH1 Lens, WH2 Valenciennes, WH3 Arras) | **CODE_SITE**, nom, adresse |
| 2 | `EMPLACEMENT` | Emplacement physique de stockage à l'intérieur d'un site | **CODE**, zone, allee, etagere, niveau, type_emplacement |
| 3 | `ARTICLE` | Référence produit gérée en stock pour un client NTL | **REFERENCE** (dans le périmètre du client), libelle, poids, longueur, largeur, hauteur, fournisseur |
| 4 | `STOCK` | État courant du stock d'un article à un emplacement | **ID_STOCK**, quantite |
| 5 | `UTILISATEUR` | Opérateur ou administrateur WMS | **LOGIN**, nom, prenom, role |
| 6 | `MOUVEMENT` | Journal des mouvements de stock | **NUMERO_MVT**, type_mouvement, quantite, date_mouvement |
| 7 | `CLIENT` | Donneur d'ordre B2B propriétaire des articles et stocks | **CODE_CLIENT**, raison_sociale, siret, contact_nom, contact_email, adresse |

> L'attribut `fournisseur` de `ARTICLE` est un texte libre (raison sociale ou code interne). Si NTL exige plus tard d'avoir un référentiel fournisseurs propre, d'opérer du multi-sourcing, ou de tracer le fournisseur d'une entrée précise, il devient une entité en V2 (cf. §4).

### 3.2 Associations et cardinalités (notation Merise)

| Association | Entité A | (min,max) A | Entité B | (min,max) B | Sens / rôle |
|-------------|----------|-------------|----------|-------------|-------------|
| **contient** | SITE | (1,N) | EMPLACEMENT | (1,1) | un site contient ≥ 1 emplacement, un emplacement appartient à exactement 1 site |
| **possede** | CLIENT | (0,N) | ARTICLE | (1,1) | un client peut posséder 0..N articles, chaque article appartient à exactement 1 client |
| **porte_pour** | CLIENT | (0,N) | STOCK | (1,1) | une ligne de stock est rattachée à exactement 1 client (verrou d'isolation tenant, cf. §3.4) |
| **tracable_pour** | CLIENT | (0,N) | MOUVEMENT | (1,1) | chaque mouvement est rattaché à exactement 1 client (verrou d'isolation tenant, cf. §3.4) |
| **porte** | EMPLACEMENT | (0,N) | STOCK | (1,1) | un emplacement porte 0..N lignes de stock, chaque ligne est sur exactement 1 emplacement |
| **stocke_dans** | ARTICLE | (0,N) | STOCK | (1,1) | un article peut être stocké en plusieurs lignes, chaque ligne concerne exactement 1 article |
| **effectue** | UTILISATEUR | (0,N) | MOUVEMENT | (1,1) | un utilisateur peut effectuer 0..N mouvements, chaque mouvement est effectué par exactement 1 utilisateur |
| **deplace_par** | ARTICLE | (0,N) | MOUVEMENT | (1,1) | chaque mouvement porte exactement 1 article |
| **depart** | EMPLACEMENT | (0,N) | MOUVEMENT | (0,1) | un mouvement peut partir d'un emplacement (NULL pour une entrée — voir §3.4 contraintes conditionnelles) |
| **arrivee** | EMPLACEMENT | (0,N) | MOUVEMENT | (0,1) | un mouvement peut arriver à un emplacement (NULL pour une sortie — voir §3.4 contraintes conditionnelles) |

### 3.3 Diagramme Mermaid

```mermaid
erDiagram
    SITE ||--|{ EMPLACEMENT : contient
    CLIENT ||--o{ ARTICLE : possede
    CLIENT ||--o{ STOCK : porte_pour
    CLIENT ||--o{ MOUVEMENT : tracable_pour
    EMPLACEMENT ||--o{ STOCK : porte
    ARTICLE ||--o{ STOCK : stocke_dans
    UTILISATEUR ||--o{ MOUVEMENT : effectue
    ARTICLE ||--o{ MOUVEMENT : deplace_par
    EMPLACEMENT |o--o{ MOUVEMENT : depart
    EMPLACEMENT |o--o{ MOUVEMENT : arrivee
```

> *Figure 1 — MCD WMS-DB V1 simplifié, notation Merise/Mermaid `erDiagram`. À exporter en PNG pour le rendu final. Les identifiants Merise sont à souligner manuellement sur l'export (voir §3.1).*

### 3.4 Justifications de modélisation

- **ARTICLE porte dimensions + poids**. Le sujet exige explicitement « dimensions/poids indispensables aux calculs d'expédition ». Trois attributs séparés `longueur`, `largeur`, `hauteur` (en cm) plutôt qu'un `volume` calculé : on conserve l'information brute, le volume reste dérivable si besoin (colonne générée au MLD ou calcul applicatif).
- **EMPLACEMENT porte un `type_emplacement`**. Le sujet demande « où **et comment** est stocké l'article ». Les attributs `code/zone/allee/etagere/niveau` répondent au *où*, l'attribut `type_emplacement` répond au *comment* (rack, picking, masse, quai). Liste figée au MLD via CHECK.
- **STOCK est une entité associative renforcée**. Le couple (ARTICLE, EMPLACEMENT) détermine une ligne unique, mais cette ligne porte un attribut propre (`quantite`) et un identifiant `ID_STOCK` pour la référencer simplement. C'est plus propre qu'une simple association sans attribut.
- **MOUVEMENT a deux rôles vers EMPLACEMENT** (`depart`, `arrivee`). Modéliser deux associations distinctes avec nullabilité différenciée est plus propre qu'une association unique avec un attribut `sens`, et permet en MLD d'avoir un index par rôle.
- **Fournisseur en attribut, pas en entité**. Une variable texte `fournisseur` portée par `ARTICLE` suffit pour répondre à « d'où vient cet article ? ». On évite une table à 1 attribut utile + une association N:N à éclater, pour une valeur métier marginale en V1. Promotion en entité en V2 si besoin de multi-sourcing ou de traçage par entrée.
- **CLIENT modélisé en donneur d'ordre B2B**, pas en particulier : `raison_sociale`, `siret`, `contact_nom`, `contact_email`, `adresse`. Cohérent avec le métier 3PL de NTL et avec l'exigence sujet « séparation des données par client ».
- **Séparation client durcie en V1 — double chemin assumé**. Trois associations rattachent un mouvement (ou une ligne de stock) à son client :
  1. **Chaîne métier canonique** : `CLIENT possede ARTICLE`, puis `ARTICLE deplace_par MOUVEMENT` (ou `ARTICLE stocke_dans STOCK`). C'est le chemin de lecture naturel.
  2. **Verrou d'intégrité direct** : `CLIENT porte_pour STOCK` et `CLIENT tracable_pour MOUVEMENT`. Au MLD, ces associations descendent en `id_client NOT NULL` sur `stocks` et `mouvements`, complétées par une **FK composite** `(id_article, id_client) → articles(id_article, id_client)`. Cette FK composite empêche d'insérer un stock/mouvement client A avec un article client B — garantie portée par la base, pas par l'application.
  Les deux chemins coexistent par construction et restent cohérents : la FK composite force `mouvements.id_client = articles.id_client` pour l'article référencé. Le double chemin est un choix de défense (chaque colonne est autonome à la review) et non une redondance accidentelle. Il est tracé en [`../DECISIONS.md`](../DECISIONS.md) B8.
- **Contraintes conditionnelles par type de mouvement → portées au DDL, pas au MCD**. Les associations `depart` et `arrivee` ont une cardinalité Merise (0,1), mais leur nullabilité réelle dépend de `type_mouvement` :
  - `ENTREE` : `depart` NULL, `arrivee` NOT NULL ;
  - `SORTIE` : `depart` NOT NULL, `arrivee` NULL ;
  - `TRANSFERT` : `depart` NOT NULL ET `arrivee` NOT NULL ET `depart <> arrivee` ;
  - `AJUSTEMENT` : exactement l'un des deux NOT NULL.
  Ce conditionnel n'est pas exprimable en notation Merise classique (qui ne porte pas de discriminant par valeur d'attribut). Il est porté au DDL via le `CHECK ck_mvt_src_dst` (voir [`wms-ddl.sql`](wms-ddl.sql) et [`wms-mld.md`](wms-mld.md) §3.4). Alternative écartée pour la V1 : spécialisation de `MOUVEMENT` en sous-types `ENTREE`/`SORTIE`/`TRANSFERT`/`AJUSTEMENT` — propre conceptuellement mais multiplie les tables sans valeur métier en V1.
- **Fournisseur en attribut texte libre — choix MVP V1**. `articles.fournisseur VARCHAR(255) NULL` n'est pas normalisé : rien n'empêche `"Acme SARL"` et `"ACME"` pour la même entité. Tolérable au volume V1 (3 sites NTL, catalogue restreint), ingérable à l'échelle. Promotion en entité `FOURNISSEUR` planifiée en V2 dans [`../ROADMAP.md`](../ROADMAP.md) dès qu'un des trois besoins suivants apparaît : multi-sourcing par article, traçabilité du fournisseur d'une entrée précise (≠ fournisseur principal), référentiel fournisseurs propre. Voir décision **B6** dans [`../DECISIONS.md`](../DECISIONS.md).
- **Destinataire final d'une sortie non modélisé en V1**. Le `CLIENT` du MCD est le donneur d'ordre NTL, pas forcément l'adresse finale de livraison. Si NTL doit tracer les destinataires de livraison, c'est une entité `DESTINATAIRE` ou `EXPEDITION` à ajouter en V2.

## 4. Limites V1 et évolutions

> **Posture jury assumée** : V1 = MVP étudiant. Contraintes de temps (4 personnes × 19 h). On préfère livrer un cœur cohérent à un modèle complet bancal. Les limites sont des **choix de scope explicites**.

Liste consolidée des évolutions (slide soutenance « Améliorations ») : voir [`../ROADMAP.md`](../ROADMAP.md).

En résumé V1 ne couvre pas : lots/DLC/FEFO · cycle commande/réception/expédition · code-barres scopé client · réservation de stock · référentiel fournisseurs entité · partitionnement `mouvements` · destinataire final de sortie.

Le détail technique de chaque évolution V2 est conservé dans [`archive/2026-05-18-modele-complexe/`](archive/2026-05-18-modele-complexe/) (modèle initial 14 entités).

## 5. Décisions liées

- **A1** — Choix MariaDB 11.4 LTS (cf. [`../DECISIONS.md`](../DECISIONS.md))
- **B6** — MCD V1 simplifié à 7 entités, fournisseur en attribut, séparation client via `CLIENT -> ARTICLE` (révisée — session 2026-05-20)
- **B7** — Complétion conformité sujet §1 : ajout des dimensions sur `ARTICLE` + ajout du `type_emplacement` sur `EMPLACEMENT` (session 2026-05-20).
- **B8** — Durcissement après review indépendante : FK composites client sur `STOCK`/`MOUVEMENT`, dimensions strictement positives, GRANT append-only (session 2026-05-20).
- **A2, A4, A5, A7, A9, B1, B2, B3, B4, B5** — caduques en V1 stricte (visaient la version 14 entités) ; restent valides comme axes de travail V2.

## 6. Risques liés

- **R03** — Mauvaise compréhension du sujet : mitigé par la séparation client explicite (`CLIENT -> ARTICLE`) et par la posture MVP assumée.

## 7. Références

- Sujet : [`../ressources/sujet-mspr3.pdf`](../ressources/sujet-mspr3.pdf) §1 « Modèle de données et intégrité ».
- Décisions internes : [`../DECISIONS.md`](../DECISIONS.md).
- Notation Merise — cours BAC+3 ASRBD EPSI Nantes 2025-2026.
- [`mcd-operationnel.md`](mcd-operationnel.md) — version courte pédagogique pour la soutenance.

## 8. Annexes

### 8.1 Schémas

| Source | Export | Légende |
|--------|--------|---------|
| Mermaid inline §3.3 | À produire en PNG avant rendu final | Figure 1 — MCD WMS-DB V1 simplifié (7 entités) |

### 8.2 Suite

| Fichier | Rôle |
|---------|------|
| [`wms-mld.md`](wms-mld.md) | MLD relationnel dérivé |
| [`wms-ddl.sql`](wms-ddl.sql) | DDL MariaDB 11.4 LTS exécutable |

---

## Journal de version

| Version | Date | Auteur | Modification |
|---------|------|--------|--------------|
| 0.1 | 2026-05-20 | Ianis | Création — second regard indépendant (modèle 14 entités) |
| 0.2 | 2026-05-20 | Ianis | Refonte V1 simplifiée à 8 entités (FOURNISSEUR entité + assoc. `livre`) |
| 0.3 | 2026-05-20 | Ianis | V1 simplifiée à 7 entités — FOURNISSEUR rétrogradé en attribut texte de `ARTICLE` |
| 0.4 | 2026-05-20 | Ianis | Réintégration de la séparation client via association `CLIENT possede ARTICLE` |
| 0.5 | 2026-05-20 | Ianis | Conformité sujet §1 : ajout `longueur`/`largeur`/`hauteur` sur `ARTICLE`, ajout `type_emplacement` sur `EMPLACEMENT` |
| 0.6 | 2026-05-20 | Ianis | Durcissement jury : séparation client verrouillée au MLD/DDL par FK composites sur `STOCK` et `MOUVEMENT` |
| 0.7 | 2026-05-20 | Ianis | Complétion MCD : ajout associations `CLIENT porte_pour STOCK` et `CLIENT tracable_pour MOUVEMENT` pour refléter le verrou MLD ; §3.4 enrichi (double chemin client, contraintes conditionnelles `ck_mvt_src_dst` non Merisables, fournisseur attribut MVP V1) |

## Contributions

| Section | Auteur principal | Reviewer | IA utilisée |
|---------|------------------|----------|-------------|
| §1-§8 | Ianis | Blaise + Zaid + Ojvind | Claude Code (refonte V1 simplifiée) |
