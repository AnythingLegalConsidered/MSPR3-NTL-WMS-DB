---
livrable: "01 - Architecture technique"
scope: "01-architecture"
section: "MCD WMS-DB V2-GPT"
version: "2.0-gpt"
status: "draft"
owner: "Ianis"
reviewers: ["Blaise", "Zaid", "Ojvind"]
contributors: ["Ianis"]
ia_used: ["GPT-5 Codex"]
created: "2026-05-21"
updated: "2026-05-21"
related:
  - "./mcd-operationnel.md"
  - "./wms-mcd-v2-gpt.mcd"
  - "./wms-mcd-v2-gpt.png"
  - "./ressources/sujet-mspr3.pdf"
---

# MCD WMS-DB - V2-GPT

> Objectif : version corrigée du MCD V1, centrée sur les défauts bloquants pour la soutenance : identifiant article, rattachement site des transactions, séparation client et unicité du stock courant.

## 1. Corrections apportées

| Défaut détecté | Correction V2-GPT |
|---|---|
| `ARTICLE` annoncé composite mais `REFERENCE` non soulignée dans Mocodo | `ARTICLE: CODE_CLIENT, _REFERENCE` pour rendre `(CODE_CLIENT, REFERENCE)` réellement identifiant |
| Transaction non rattachée explicitement à un site | Association `SITE rattache MOUVEMENT` en `(0,N)` / `(1,1)` |
| `STOCK` identifié par un `ID_STOCK` conceptuel qui masque l'unicité métier | Identifiant métier `STOCK = (CODE_CLIENT, REFERENCE, CODE_EMPLACEMENT)` |
| Séparation client laissée partiellement applicative en v0.8 | Le client est porté par l'identifiant de `ARTICLE`, puis propagé vers `STOCK` et `MOUVEMENT` au MLD par FK composite |
| Slide courte encore en v0.7 | `mcd-operationnel.md` doit suivre cette version V2-GPT |

## 2. Entités

| # | Entité | Rôle opérationnel | Identifiant + attributs métier |
|---|---|---|---|
| 1 | `CLIENT` | Donneur d'ordre B2B propriétaire du catalogue | **CODE_CLIENT**, raison_sociale, siret, contact_nom, contact_email, adresse, status |
| 2 | `ARTICLE` | SKU client avec informations d'expédition | **(CODE_CLIENT, REFERENCE)**, libelle, poids, longueur, largeur, hauteur, fournisseur |
| 3 | `SITE` | Site physique NTL | **CODE_SITE**, nom, adresse |
| 4 | `EMPLACEMENT` | Localisation physique dans un site | **CODE**, zone, allee, etagere, niveau, type_emplacement |
| 5 | `STOCK` | Etat courant d'un article dans un emplacement | **(CODE_CLIENT, REFERENCE, CODE_EMPLACEMENT)**, quantite, date_maj |
| 6 | `MOUVEMENT` | Journal horodaté des entrées, sorties, transferts et ajustements | **NUMERO_MVT**, type_mouvement, quantite, date_mouvement |
| 7 | `UTILISATEUR` | Opérateur ou administrateur WMS | **LOGIN**, nom, prenom, role |

## 3. Associations

| Association | Entité A | Cardinalité A | Entité B | Cardinalité B | Règle métier |
|---|---|---:|---|---:|---|
| `possede` | `CLIENT` | `(0,N)` | `ARTICLE` | `(1,1)` | chaque article appartient à un seul client |
| `contient` | `SITE` | `(1,N)` | `EMPLACEMENT` | `(1,1)` | chaque emplacement appartient à un seul site |
| `stocke_dans` | `ARTICLE` | `(0,N)` | `STOCK` | `(1,1)` | une ligne de stock concerne un seul article |
| `porte` | `EMPLACEMENT` | `(0,N)` | `STOCK` | `(1,1)` | une ligne de stock est dans un seul emplacement |
| `concerne` | `ARTICLE` | `(0,N)` | `MOUVEMENT` | `(1,1)` | chaque mouvement concerne un seul article |
| `rattache` | `SITE` | `(0,N)` | `MOUVEMENT` | `(1,1)` | chaque transaction est rattachée à un site, exigence explicite du sujet |
| `depart` | `EMPLACEMENT` | `(0,N)` | `MOUVEMENT` | `(0,1)` | source optionnelle selon le type de mouvement |
| `arrivee` | `EMPLACEMENT` | `(0,N)` | `MOUVEMENT` | `(0,1)` | destination optionnelle selon le type de mouvement |
| `effectue` | `UTILISATEUR` | `(0,N)` | `MOUVEMENT` | `(1,1)` | chaque mouvement est saisi par un utilisateur |

## 4. Règles d'intégrité à descendre au MLD/DDL

- `ARTICLE` : unicité métier `(code_client, reference)`.
- `STOCK` : unicité métier `(code_client, reference, code_emplacement)`.
- `MOUVEMENT` : FK composite vers `ARTICLE(code_client, reference)` pour garantir la séparation client.
- `STOCK` : FK composite vers `ARTICLE(code_client, reference)` et FK vers `EMPLACEMENT(code)`.
- `MOUVEMENT` : `code_site` obligatoire ; l'emplacement non nul (`depart` ou `arrivee`) doit appartenir au même site.
- `TRANSFERT` V2-GPT : transfert intra-site uniquement. Un transfert inter-site se modélise en deux mouvements : sortie site A + entrée site B.
- `type_mouvement` :
  - `ENTREE` : `depart` NULL, `arrivee` NOT NULL ;
  - `SORTIE` : `depart` NOT NULL, `arrivee` NULL ;
  - `TRANSFERT` : `depart` NOT NULL, `arrivee` NOT NULL, `depart <> arrivee` ;
  - `AJUSTEMENT` : exactement un des deux emplacements est renseigné.

## 5. Source Mocodo

Source : [`wms-mcd-v2-gpt.mcd`](wms-mcd-v2-gpt.mcd)

```mocodo
:
porte, 0N EMPLACEMENT, 11 STOCK
STOCK: CODE_CLIENT, _REFERENCE, _CODE_EMPLACEMENT, quantite, date_maj
stocke_dans, 0N ARTICLE, 11 STOCK
:
:

contient, 1N SITE, 11 EMPLACEMENT
EMPLACEMENT: CODE, zone, allee, etagere, niveau, type_emplacement
arrivee, 0N EMPLACEMENT, 01 MOUVEMENT
ARTICLE: CODE_CLIENT, _REFERENCE, libelle, poids, longueur, largeur, hauteur, fournisseur
possede, 0N CLIENT, 11 ARTICLE
CLIENT: CODE_CLIENT, raison_sociale, siret, contact_nom, contact_email, adresse, status

SITE: CODE_SITE, nom, adresse
depart, 0N EMPLACEMENT, 01 MOUVEMENT
MOUVEMENT: NUMERO_MVT, type_mouvement, quantite, date_mouvement
concerne, 0N ARTICLE, 11 MOUVEMENT
:
:

:
rattache, 0N SITE, 11 MOUVEMENT
effectue, 0N UTILISATEUR, 11 MOUVEMENT
UTILISATEUR: LOGIN, nom, prenom, role
:
:
```

## 6. Limites assumées

Cette V2-GPT reste volontairement compacte : pas de lots/DLC/FEFO, pas de commande, pas de réception/expédition, pas de transporteur, pas de destinataire final. Ces objets restent des évolutions V2 fonctionnelles si le jury demande le périmètre complet WMS.
