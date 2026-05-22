# Changelog projet MSPR3 NTL WMS-DB

> Historique des changements significatifs. Pour le détail des décisions techniques, voir [`07-gestion-projet/journal-decisions.md`](07-gestion-projet/journal-decisions.md) et [`decisions/`](decisions/).

## 2026-05-22

- 🏗️ **Restructuration du repo en 9 dossiers de livrables** alignés sur le cahier des charges EPSI (§III). Chaque livrable a son `README.md` avec état, contenu attendu et point d'entrée.
- 📋 Ajout du registre des risques [`07-gestion-projet/registre-risques.md`](07-gestion-projet/registre-risques.md) (9 risques) et du journal des décisions [`07-gestion-projet/journal-decisions.md`](07-gestion-projet/journal-decisions.md) (4 arbitrages majeurs documentés).
- 🪲 **Bug parser MariaDB 11.4 découvert et contourné** pendant tests DDL. Règle XOR `ck_mvt_src_dst` portée par 2 triggers BEFORE INSERT/UPDATE. 8 tests fonctionnels valident l'équivalence sémantique. ADR ouvert : [`decisions/0001-bug-mariadb-check.md`](decisions/0001-bug-mariadb-check.md).
- ✅ **DDL V1 exécuté avec succès** sur MariaDB 11.4.10. 8 tables + 2 triggers + 7 index reporting. 8 tests positifs/négatifs validés.
- 📦 Création du dossier [`brief-ia/`](brief-ia/) pour permettre aux membres de l'équipe d'interroger une IA externe (Claude Desktop, ChatGPT) sur les choix techniques. Drag-drop des 8 fichiers + prompt prêt à coller.

## 2026-05-21

- ✅ **MCD V4 officiel** matérialisé (8 entités, 10 associations) après revue critique « 5 attaques soutenance » + arbitrages Ianis. Validé par convergence Claude × GPT.
- ✅ **MLD V1** rédigé (squelette 8 tables, FK simples + composites option D, contraintes, index).

## 2026-05-20

- 🌱 Initialisation du projet. MCD v0.7 + contexte projet (sujet EPSI, équipe, contraintes).

## Convention

- Une entrée par date significative
- Préfixe emoji pour identifier le type :
  - 🌱 init / setup
  - ✅ livrable validé
  - 🏗️ refactor / restructuration
  - 🪲 bug découvert / corrigé
  - 📋 documentation
  - 📦 outillage / tooling
  - 🔒 sécurité
  - ⚡ performance
