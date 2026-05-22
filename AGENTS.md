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
- Pas de trigger en V1

Si une décision semble incohérente : **propose un workaround MLD/DDL, ne rouvre pas le MCD**.

## Fichiers à lire selon la question

| Question | Fichier |
|---|---|
| Modèle conceptuel, entités, associations | `wms-mcd.md` |
| Modèle logique, tables, FK, contraintes | `wms-mld.md` |
| Pourquoi telle décision | `FAQ.md` puis `convergence/arbitrages-v4-ianis.md` |
| État projet, livrables restants, qui fait quoi | `EQUIPE.md` + `README.md` |
| Historique convergence multi-IA | `convergence/` |
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
