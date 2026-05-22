---
livrable: "01 - Architecture technique"
scope: "01-architecture"
section: "MCD WMS-DB V3-GPT"
version: "3.0-gpt"
status: "draft"
owner: "Ianis"
reviewers: ["Blaise", "Zaid", "Ojvind"]
contributors: ["Ianis"]
ia_used: ["GPT-5 Codex"]
created: "2026-05-21"
updated: "2026-05-21"
related:
  - "./review-convergence-mcd-v2.md"
  - "./mcd-operationnel.md"
  - "./wms-mcd-v3-gpt.mcd"
  - "./wms-mcd-v3-gpt.png"
  - "./ressources/sujet-mspr3.pdf"
---

# MCD WMS-DB - V3-GPT

> Version de convergence GPT après review croisée V2 Claude/GPT. Objectif : garder un MCD lisible en soutenance, corriger les défauts de rendu et porter explicitement les règles d'intégrité attendues par le sujet.

## 1. Décisions V3-GPT

| Sujet | Décision V3-GPT |
|---|---|
| `ARTICLE` | Identifiant composite classique `CODE_CLIENT + REFERENCE`, rendu Mocodo par `ARTICLE: CODE_CLIENT, _REFERENCE`. |
| `STOCK` | Identifiant technique `ID_STOCK` conservé, avec unicité métier obligatoire `UNIQUE (id_article, id_emplacement)` au MLD/DDL. |
| Stockage | Ternaire `stockage(ARTICLE, EMPLACEMENT, STOCK)` retenue : `STOCK` est une entité associative renforcée. |
| Site des transactions | Pas d'association directe `SITE-MOUVEMENT` par défaut ; le site est dérivé via l'emplacement de départ ou d'arrivée. |
| Transfert | `TRANSFERT` intra-site uniquement ; un transfert inter-site se modélise par une sortie site A + une entrée site B. |
| Séparation client | Recommandation GPT : FK composite `(id_article, id_client) -> articles(id_article, id_client)` au MLD/DDL, avec `UNIQUE(id_article, id_client)` sur `articles`. |

## 2. Entités

| # | Entité | Rôle opérationnel | Identifiant + attributs métier |
|---|---|---|---|
| 1 | `CLIENT` | Donneur d'ordre B2B propriétaire du catalogue | **CODE_CLIENT**, raison_sociale, siret, contact_nom, contact_email, adresse, status |
| 2 | `ARTICLE` | SKU client avec informations d'expédition | **(CODE_CLIENT, REFERENCE)**, libelle, poids, longueur, largeur, hauteur, fournisseur |
| 3 | `SITE` | Site physique NTL | **CODE_SITE**, nom, adresse |
| 4 | `EMPLACEMENT` | Localisation physique dans un site | **CODE**, zone, allee, etagere, niveau, type_emplacement |
| 5 | `STOCK` | Etat courant d'un article dans un emplacement | **ID_STOCK**, quantite, date_maj |
| 6 | `MOUVEMENT` | Journal horodaté des entrées, sorties, transferts et ajustements | **NUMERO_MVT**, type_mouvement, quantite, date_mouvement |
| 7 | `UTILISATEUR` | Opérateur ou administrateur WMS | **LOGIN**, nom, prenom, role |

> `ARTICLE` pourrait être modélisé comme entité faible relative à `CLIENT` en Merise pur. V3-GPT garde l'identifiant composite classique car il rend directement visible la règle `(CODE_CLIENT, REFERENCE)` sur le diagramme.

> `STOCK` garde un identifiant technique `ID_STOCK` pour le référencement applicatif. L'unicité métier reste obligatoire : un même article ne peut avoir qu'une seule ligne de stock par emplacement.

## 3. Associations

| Association | Type | Entités liées | Cardinalités | Règle métier |
|---|---|---|---|---|
| `possede` | binaire | `CLIENT` - `ARTICLE` | `(0,N)` - `(1,1)` | un article appartient à un seul client |
| `contient` | binaire | `SITE` - `EMPLACEMENT` | `(1,N)` - `(1,1)` | chaque emplacement appartient à un seul site |
| `stockage` | ternaire | `ARTICLE` - `STOCK` - `EMPLACEMENT` | `(0,N)` - `(1,1)` - `(0,N)` | une ligne de stock concerne exactement un couple article/emplacement |
| `concerne` | binaire | `ARTICLE` - `MOUVEMENT` | `(0,N)` - `(1,1)` | chaque mouvement concerne un seul article |
| `depart` | binaire | `EMPLACEMENT` - `MOUVEMENT` | `(0,N)` - `(0,1)` | source optionnelle selon le type de mouvement |
| `arrivee` | binaire | `EMPLACEMENT` - `MOUVEMENT` | `(0,N)` - `(0,1)` | destination optionnelle selon le type de mouvement |
| `effectue` | binaire | `UTILISATEUR` - `MOUVEMENT` | `(0,N)` - `(1,1)` | chaque mouvement est saisi par un utilisateur |

## 4. Règles d'intégrité à descendre au MLD/DDL

- `articles` : PK technique possible `id_article`, plus `id_client`, `reference`, `UNIQUE(id_client, reference)` et `UNIQUE(id_article, id_client)`.
- `stocks` : `id_stock` PK, `id_article`, `id_client`, `id_emplacement`, `quantite`, `date_maj`.
- `stocks` : `UNIQUE(id_article, id_emplacement)` pour garantir l'unicité métier du stock courant.
- `stocks` : FK composite `(id_article, id_client) -> articles(id_article, id_client)` pour empêcher un stock client A avec article client B.
- `mouvements` : `id_article`, `id_client`, `id_utilisateur`, `id_emplacement_depart`, `id_emplacement_arrivee`, `type_mouvement`, `quantite`, `date_mouvement`.
- `mouvements` : FK composite `(id_article, id_client) -> articles(id_article, id_client)` pour empêcher une fuite logique multi-tenant.
- `type_mouvement` :
  - `ENTREE` : `depart` NULL, `arrivee` NOT NULL ;
  - `SORTIE` : `depart` NOT NULL, `arrivee` NULL ;
  - `TRANSFERT` : `depart` NOT NULL, `arrivee` NOT NULL, `depart <> arrivee`, et `depart.site = arrivee.site` ;
  - `AJUSTEMENT` : exactement un des deux emplacements est renseigné.
- Site d'une transaction : dérivé de l'emplacement de départ ou d'arrivée. Si Ianis valide plus tard un cas d'ajustement global sans emplacement, ajouter alors une association directe `SITE rattache MOUVEMENT`.

## 5. Justification de `STOCK`

`STOCK` est une entité associative renforcée : `ID_STOCK` sert d'identifiant technique référençable, mais l'unicité métier reste le couple `(ARTICLE, EMPLACEMENT)`, matérialisée par `UNIQUE(id_article, id_emplacement)` au MLD.

La ternaire `stockage(ARTICLE, STOCK, EMPLACEMENT)` exprime cette dépendance conceptuelle sans conserver les deux noms ambigus `stocke_dans` et `porte`.

## 6. Source Mocodo

Source : [`wms-mcd-v3-gpt.mcd`](wms-mcd-v3-gpt.mcd)

```mocodo
CLIENT: CODE_CLIENT, raison_sociale, siret, contact_nom, contact_email, adresse, status
possede, 0N CLIENT, 11 ARTICLE
ARTICLE: CODE_CLIENT, _REFERENCE, libelle, poids, longueur, largeur, hauteur, fournisseur
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

## 7. Limites assumées

Cette V3 reste un coeur WMS compact : pas de lots/DLC/FEFO, pas de commandes, pas de réceptions/expéditions détaillées, pas de transporteurs, pas de destinataires finaux. Ces objets restent des évolutions fonctionnelles hors périmètre MVP.
