---
livrable: "01 — Architecture technique"
scope: "01-architecture"
section: "MCD WMS-DB v2 — Merise pur (ternaire stockage)"
version: "2.0-claude"
status: "draft"
owner: "Ianis"
reviewers: ["Blaise", "Zaid", "Ojvind"]
contributors: ["Ianis"]
ia_used: ["Claude Code"]
created: "2026-05-21"
updated: "2026-05-21"
parent: "./wms-mcd.md"
related:
  - "./wms-mcd.md"
  - "./mcd-operationnel.md"
  - "./wms-mld.md"
  - "./wms-ddl.sql"
  - "../DECISIONS.md"
---

# 01 — MCD WMS-DB v2 (proposition Claude — Merise pur)

> **Objectif** : variante du MCD v0.8 ([`../wms-mcd.md`](../wms-mcd.md)) corrigeant les ambiguïtés de nommage d'associations en passant à une **association ternaire** `stockage(ARTICLE, EMPLACEMENT, STOCK)` au lieu de deux associations binaires `stocke_dans` + `porte`.

## 1. Différences avec v0.8

| Aspect | v0.8 (`wms-mcd.md`) | v2 (ce fichier) |
|--------|----------------------|------------------|
| Nb associations | 8 binaires | 6 (5 binaires + 1 ternaire) |
| Stock ↔ Article + Emplacement | 2 binaires `stocke_dans` + `porte` | 1 ternaire `stockage` (STOCK = entité associative renforcée) |
| Mouvement ↔ Article | `deplace_par` (passif bizarre) | `concerne` (lecture naturelle) |
| Lisibilité Merise | Correcte mais 2 noms ambigus | Conforme convention académique |

## 2. Justification du choix ternaire

**Pourquoi une ternaire `stockage` ?**

`STOCK` n'existe pas indépendamment : une ligne de stock n'a de sens **que** rattachée à un couple (ARTICLE, EMPLACEMENT). C'est la définition exacte d'une **entité associative renforcée** en Merise — une entité dont l'identifiant propre (`ID_STOCK`) coexiste avec une dépendance fonctionnelle au couple identifiant de ses entités-mères.

Le passage en ternaire :
- supprime l'ambiguïté `stocke_dans` (article stocke dans stock ?) et `porte` (emplacement porte stock ?)
- exprime explicitement que STOCK dépend du couple ARTICLE × EMPLACEMENT
- reste compatible avec le MLD : une ternaire avec entité renforcée descend en **une seule table `stocks`** avec FK vers `articles` et `emplacements` — exactement ce que produirait le couple `stocke_dans` + `porte`.

**Pourquoi `concerne` au lieu de `deplace_par` ?**

`deplace_par` se lit « article est déplacé par mouvement » — passif, contre-intuitif. La convention Merise lit l'association du côté **actif** : c'est le mouvement qui agit. `MOUVEMENT (1,1) concerne ARTICLE (0,N)` — « un mouvement concerne un article, un article est concerné par 0..N mouvements ».

## 3. Contenu

### 3.1 Entités (7) — inchangées

Voir [`../wms-mcd.md`](../wms-mcd.md) §3.1. Mêmes entités, mêmes attributs.

### 3.2 Associations et cardinalités

| Association | Type | Entités liées | Cardinalités | Sens |
|-------------|------|---------------|--------------|------|
| **contient** | binaire | SITE — EMPLACEMENT | (1,N) — (1,1) | un site contient ≥1 emplacement, chaque emplacement appartient à 1 site |
| **possede** | binaire | CLIENT — ARTICLE | (0,N) — (1,1) | un client possède 0..N articles, chaque article appartient à 1 client |
| **stockage** | **ternaire** | ARTICLE — STOCK — EMPLACEMENT | (0,N) — (1,1) — (0,N) | chaque ligne de stock concerne exactement 1 couple (article, emplacement) ; un article peut être stocké en 0..N emplacements, un emplacement peut porter 0..N articles |
| **effectue** | binaire | UTILISATEUR — MOUVEMENT | (0,N) — (1,1) | un utilisateur effectue 0..N mouvements, chaque mouvement est fait par 1 utilisateur |
| **concerne** | binaire | ARTICLE — MOUVEMENT | (0,N) — (1,1) | un article est concerné par 0..N mouvements, chaque mouvement concerne 1 article |
| **depart** | binaire | EMPLACEMENT — MOUVEMENT | (0,N) — (0,1) | un mouvement peut partir d'un emplacement (NULL pour ENTREE) |
| **arrivee** | binaire | EMPLACEMENT — MOUVEMENT | (0,N) — (0,1) | un mouvement peut arriver à un emplacement (NULL pour SORTIE) |

> **STOCK est une entité associative renforcée**. Son identifiant `ID_STOCK` lui donne une existence référençable propre, mais elle reste sémantiquement dépendante du couple (ARTICLE, EMPLACEMENT). Au MLD, cela descend en table `stocks(id_stock PK, id_article FK, id_emplacement FK, quantite, date_maj)` avec contrainte d'unicité `UNIQUE (id_article, id_emplacement)`.

### 3.3 Diagramme Merise (Mocodo)

Source [`wms-mcd-v2-claude.mcd`](wms-mcd-v2-claude.mcd) — rendu PNG dans [`wms-mcd-v2-claude.png`](wms-mcd-v2-claude.png).

```mocodo
CLIENT: CODE_CLIENT, raison_sociale, siret, contact_nom, contact_email, adresse, status
possede, 0N CLIENT, 11 ARTICLE
ARTICLE: CODE_CLIENT, REFERENCE, libelle, poids, longueur, largeur, hauteur, fournisseur
concerne, 0N ARTICLE, 11 MOUVEMENT

stockage, 0N ARTICLE, 11 STOCK, 0N EMPLACEMENT
:
:
MOUVEMENT: NUMERO_MVT, type_mouvement, quantite, date_mouvement

:
STOCK: ID_STOCK, quantite, date_maj
depart, 0N EMPLACEMENT, 01 MOUVEMENT
effectue, 0N UTILISATEUR, 11 MOUVEMENT

:
EMPLACEMENT: CODE, zone, allee, etagere, niveau, type_emplacement
arrivee, 0N EMPLACEMENT, 01 MOUVEMENT
UTILISATEUR: LOGIN, nom, prenom, role

:
contient, 1N SITE, 11 EMPLACEMENT
:
:

:
SITE: CODE_SITE, nom, adresse
```

Régénération :

```bash
python -m mocodo --input wms-mcd-v2-claude.mcd --output_dir . --svg_to png
```

> *Figure 1 — MCD WMS-DB v2, notation Merise classique avec association ternaire `stockage` et entité associative renforcée `STOCK`.*

## 4. Impact MLD/DDL

**Aucun changement par rapport à v0.8.** La ternaire `stockage(ARTICLE, EMPLACEMENT, STOCK)` descend exactement comme le couple binaire `stocke_dans` + `porte` :

```sql
CREATE TABLE stocks (
  id_stock        BIGINT      PRIMARY KEY AUTO_INCREMENT,
  id_article      BIGINT      NOT NULL,
  id_emplacement  BIGINT      NOT NULL,
  id_client       BIGINT      NOT NULL,    -- dénormalisé
  quantite        INT         NOT NULL CHECK (quantite >= 0),
  date_maj        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE (id_article, id_emplacement),
  FOREIGN KEY (id_article)     REFERENCES articles(id_article),
  FOREIGN KEY (id_emplacement) REFERENCES emplacements(id_emplacement),
  FOREIGN KEY (id_client)      REFERENCES clients(id_client)
);
```

Idem pour `concerne` → colonne `id_article` sur `mouvements` (inchangée).

## 5. Recommandation

**Adopter v2 comme MCD officiel** si l'équipe valide le passage en ternaire. Sinon conserver v0.8 et appliquer uniquement le renommage `deplace_par` → `concerne` (option A intermédiaire).

Décision à formaliser dans [`../DECISIONS.md`](../DECISIONS.md) (nouvelle décision B9 si v2 adoptée).

## Journal de version

| Version | Date | Auteur | Modification |
|---------|------|--------|--------------|
| 2.0-claude | 2026-05-21 | Ianis (proposition Claude Code) | Variante du MCD v0.8 : ternaire `stockage(ARTICLE, EMPLACEMENT, STOCK)` avec STOCK en entité associative renforcée, renommage `deplace_par` → `concerne` |
