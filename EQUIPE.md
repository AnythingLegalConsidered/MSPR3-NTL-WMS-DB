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
- **Triggers minimisés** : règles d'intégrité portées par FK composites + CHECK partout où possible. Exception : 2 triggers sur `mouvements` (`tg_mvt_src_dst_ins`, `tg_mvt_src_dst_upd`) forcés par un bug parser MariaDB 11.4 — cf. `wms-ddl.md` §5.bis.

Détail et justifications → [`FAQ.md`](FAQ.md).

## Où trouver quoi

| Tu cherches… | Va dans |
|---|---|
| Le modèle conceptuel officiel | [`wms-mcd.md`](wms-mcd.md) |
| Le diagramme MCD visuel | [`wms-mcd.svg`](wms-mcd.svg) / [`wms-mcd.png`](wms-mcd.png) |
| Le modèle logique (tables, FK, contraintes) | [`wms-mld.md`](wms-mld.md) |
| Le pourquoi d'une décision | [`FAQ.md`](FAQ.md) puis [`convergence/`](convergence/) pour l'historique long |
| Le sujet EPSI | [`ressources/sujet-mspr3.pdf`](ressources/sujet-mspr3.pdf) |
| La grille d'évaluation jury | [`ressources/grille-evaluation.pdf`](ressources/grille-evaluation.pdf) |
| L'état des livrables | [`README.md`](README.md) tableau « État » |

## Livrables restants

| Livrable | Point d'entrée pour démarrer | Contraintes à respecter |
|---|---|---|
| DDL MariaDB 11.4 | ✅ draft v1 — [`ddl/wms-schema.sql`](ddl/wms-schema.sql) + [`wms-ddl.md`](wms-ddl.md). Reste : exécuter sur MariaDB 11.4, écrire tests, écrire seed |
| Justification SGBD | à créer | comparatif MariaDB / PostgreSQL / MySQL sur critères : LTS, Galera (HA), licence, écosystème |
| HA/PRA Galera | à créer | RTO 1h / RPO 15min. Cluster Galera 3 nœuds minimum. Sauvegardes mariabackup. |
| Sécurité accès | à créer | matrice rôles → privilèges (cariste, opérateur, admin). TLS. Comptes nominatifs. |
| Supervision | à créer | 5 KPIs à définir. Outils libres (Zabbix / Prometheus / PMM). |
| Logs | à créer | binlog + slow query log + audit plugin. Politique rétention. |
| RunBook exploitation | à créer | procédures : sauvegarde, restauration, failover Galera, rotation logs, ajout nœud |
| Pilotage projet | à créer | Gantt, planning 19h × 4. Risques. RACI. |
| Note CODIR | à créer | 1 page, vulgarisation pour direction NTL fictive |
| Soutenance | à créer | slides + démo. S'appuyer sur [`FAQ.md`](FAQ.md) pour la défense. |

## Workflow Git

- Branche : `main`
- Format commit : `<scope>(<version>): <description courte>` + corps explicatif si nécessaire
  - Exemples : `mcd(v4):`, `mld(v1):`, `ddl(v1):`, `ha(v1):`, `docs:`
- Pas de push sans validation Ianis (lead)
- Pas de force-push, pas de réécriture d'historique

## Outils

- **MCD** : Mocodo (`python -m mocodo --input wms-mcd.mcd --output_dir . --svg_to png --detect_overlaps`)
- **DDL** : à écrire à la main puis tester sur conteneur MariaDB 11.4 local
- **HA** : Galera (à provisionner sur VMs ou conteneurs)
