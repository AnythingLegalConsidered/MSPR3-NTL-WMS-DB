# AGENTS.md — instructions pour CLI IA (Claude Code, opencode, codex)

> Fichier de contexte pour assistants IA travaillant sur ce repo. Lisez-le avant toute action.

## Projet

MSPR3 EPSI Nantes — conception base de données WMS pour NordTransit Logistics (PME logistique fictive). Cible **MariaDB 11.4 LTS**. Contraintes : RTO 1h, RPO 15 min.

## Décisions verrouillées — NE PAS rouvrir

- MCD V4 à 8 entités (CLIENT, ARTICLE, FOURNISSEUR, SITE, EMPLACEMENT, STOCK, MOUVEMENT, UTILISATEUR)
- Multi-tenant : FK composite option D `(id_article, id_client)`
- TRANSFERT intra-site : dénormalisation `mouvements.id_site` + FK composites
- Surrogate keys `id_*` au MLD, code métier en UNIQUE
- ENUM pour domaines de valeurs, CHECK pour contraintes conditionnelles
- Triggers minimisés (exception : `ck_mvt_src_dst` porté par triggers à cause d'un bug parser MariaDB 11.4 — cf. `01-architecture-technique/ddl/wms-ddl.md` §5.bis et `decisions/0001-bug-mariadb-check.md`)

Si une décision semble incohérente : **propose un workaround MLD/DDL, ne rouvre pas le MCD**.

## Structure repo (1 dossier par livrable EPSI)

| Dossier | Livrable |
|---|---|
| `01-architecture-technique/` | MCD + MLD + DDL + justif SGBD + politiques |
| `02-pra/` | Plan de Reprise d'Activité |
| `03-supervision/` | Guide supervision + 5 KPIs |
| `04-optimisation/` | Démarche optimisation BDD |
| `05-runbook/` | RunBook exploitation |
| `06-analyse-logs/` | Analyse de journaux |
| `07-gestion-projet/` | Équipe + planning + risques + journal décisions |
| `08-note-direction/` | Note CODIR |
| `09-soutenance/` | Support soutenance |
| `decisions/` | ADR détaillés |
| `brief-ia/` | Kit d'amorçage IA pour camarades |
| `ressources/` | Sujet EPSI + grille évaluation |

## Fichiers à lire selon la question

| Question | Fichier |
|---|---|
| Modèle conceptuel, entités, associations | `01-architecture-technique/mcd/wms-mcd.md` |
| Modèle logique, tables, FK, contraintes | `01-architecture-technique/mld/wms-mld.md` |
| DDL exécutable + choix techniques | `01-architecture-technique/ddl/` |
| Pourquoi telle décision (synthèse) | `07-gestion-projet/journal-decisions.md` |
| ADR détaillé d'une décision | `decisions/000N-...md` |
| FAQ soutenance prête à défendre | `FAQ.md` |
| État projet, livrables restants | `README.md` + `EQUIPE.md` |
| Historique changements | `CHANGELOG.md` |
| Sujet officiel EPSI | `ressources/sujet-mspr3.pdf` |

## Style attendu

- **Langue** : français. Code et identifiants SQL en anglais (snake_case).
- **Concision** : pas de blabla, droit au but. Tableaux quand pertinent.
- **Surgical** : chaque modification trace à la demande, pas de refactor adjacent.
- **Anti-sycophancy** : si une demande est incohérente avec une décision verrouillée, le dire.

## Commits

Format : `<scope>(<version>): <description>` — exemples : `mcd(v4):`, `mld(v1):`, `ddl(v1):`, `docs:`.

**Pas de mention d'IA / co-auteur IA dans les messages de commit.**

Pas de push sans validation explicite du lead (Ianis).
