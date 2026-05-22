# Onboarding équipe — MSPR3 NTL WMS-DB

> Lecture rapide pour comprendre où on en est et où trouver quoi. Pour les questions de soutenance → [`FAQ.md`](FAQ.md).

## Le projet en 5 lignes

Concevoir la base de données du WMS (Warehouse Management System) de **NordTransit Logistics**, PME logistique fictive Hauts-de-France. Cible **MariaDB 11.4 LTS**. Périmètre : modèle de données + HA/PRA + sécurité + supervision + exploitation. Contraintes critiques : **RTO 1h, RPO 15 min**, équipe 4 × 19h.

## Qui fait quoi

| Membre | Rôle | Livrables principaux |
|---|---|---|
| Ianis | Lead, architecture | MCD, MLD, DDL, coordination |
| Blaise | — | à répartir |
| Zaid | — | à répartir |
| Ojvind | — | à répartir |

## Décisions verrouillées (ne pas rouvrir)

Ces décisions sont **tranchées**. Si tu penses qu'une est fausse, ouvre la discussion avant de modifier quoi que ce soit.

- **SGBD** : MariaDB 11.4 LTS
- **MCD à 8 entités** (V4) : CLIENT, ARTICLE, FOURNISSEUR, SITE, EMPLACEMENT, STOCK, MOUVEMENT, UTILISATEUR. Modèle 14 entités (lots/FEFO, commandes, expéditions, transporteurs) reporté en V2.
- **Multi-tenant** : FK composite `(id_article, id_client)` (« option D ») + association `realise_pour` visible au MCD.
- **TRANSFERT intra-site** : garanti déclarativement par dénormalisation `mouvements.id_site` + FK composites vers `emplacements`.
- **Surrogate keys** `id_*` partout au MLD, code métier conservé en `UNIQUE`.
- **Triggers minimisés** : règles d'intégrité portées par FK composites + CHECK partout où possible. Exception : 2 triggers sur `mouvements` (`tg_mvt_src_dst_ins`, `tg_mvt_src_dst_upd`) forcés par un bug parser MariaDB 11.4 — cf. [`01-architecture-technique/ddl/wms-ddl.md`](01-architecture-technique/ddl/wms-ddl.md) §5.bis et [`decisions/0001-bug-mariadb-check.md`](decisions/0001-bug-mariadb-check.md).

Détail et justifications → [`FAQ.md`](FAQ.md).

## Où trouver quoi

| Tu cherches… | Va dans |
|---|---|
| Le modèle conceptuel officiel | [`01-architecture-technique/mcd/wms-mcd.md`](01-architecture-technique/mcd/wms-mcd.md) |
| Le diagramme MCD visuel | [`01-architecture-technique/mcd/wms-mcd.svg`](01-architecture-technique/mcd/wms-mcd.svg) |
| Le modèle logique (tables, FK, contraintes) | [`01-architecture-technique/mld/wms-mld.md`](01-architecture-technique/mld/wms-mld.md) |
| Le DDL exécutable + sa doc | [`01-architecture-technique/ddl/`](01-architecture-technique/ddl/) |
| Le pourquoi d'une décision (synthèse) | [`07-gestion-projet/journal-decisions.md`](07-gestion-projet/journal-decisions.md) |
| Les ADR détaillés (problème, options, arbitrage) | [`decisions/`](decisions/) |
| Les risques projet | [`07-gestion-projet/registre-risques.md`](07-gestion-projet/registre-risques.md) |
| L'historique des changements | [`CHANGELOG.md`](CHANGELOG.md) |
| Les attaques jury anticipées + réponses | [`FAQ.md`](FAQ.md) |
| Interroger une IA sur le projet | [`brief-ia/`](brief-ia/) |
| Le sujet EPSI | [`ressources/sujet-mspr3.pdf`](ressources/sujet-mspr3.pdf) |
| La grille d'évaluation jury | [`ressources/grille-evaluation.pdf`](ressources/grille-evaluation.pdf) |
| L'état d'un livrable | `README.md` du dossier `0N-…/` correspondant |

## Livrables restants

Voir le `README.md` de chaque dossier `0N-…/` pour : statut détaillé, contenu attendu, point d'entrée pour démarrer, contraintes à respecter. Synthèse :

| # | Dossier | Statut |
|---|---|---|
| 1 | [`01-architecture-technique/`](01-architecture-technique/) | 🟡 MCD ✅ MLD ✅ DDL ✅ — reste justif SGBD + schémas + politiques |
| 2 | [`02-pra/`](02-pra/) | ⏳ |
| 3 | [`03-supervision/`](03-supervision/) | ⏳ |
| 4 | [`04-optimisation/`](04-optimisation/) | ⏳ |
| 5 | [`05-runbook/`](05-runbook/) | ⏳ |
| 6 | [`06-analyse-logs/`](06-analyse-logs/) | ⏳ |
| 7 | [`07-gestion-projet/`](07-gestion-projet/) | 🟡 journal-decisions + registre-risques amorcés |
| 8 | [`08-note-direction/`](08-note-direction/) | ⏳ |
| 9 | [`09-soutenance/`](09-soutenance/) | ⏳ |

## Workflow Git

- Branche : `main`
- Format commit : `<scope>(<version>): <description courte>` + corps explicatif si nécessaire
  - Exemples : `mcd(v4):`, `mld(v1):`, `ddl(v1):`, `ha(v1):`, `docs:`
- Pas de push sans validation Ianis (lead)
- Pas de force-push, pas de réécriture d'historique

## Outils

- **MCD** : Mocodo (`cd 01-architecture-technique/mcd && python -m mocodo --input wms-mcd.mcd --output_dir . --svg_to png --detect_overlaps`)
- **DDL** : à écrire à la main puis tester sur conteneur MariaDB 11.4 local
- **HA** : Galera (à provisionner sur VMs ou conteneurs)
