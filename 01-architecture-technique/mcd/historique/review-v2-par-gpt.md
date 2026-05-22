---
livrable: "01 - Architecture technique"
scope: "01-architecture"
section: "Review GPT - MCD V2 Claude"
version: "1.0"
status: "review"
owner: "Ianis"
reviewer: "GPT-5 Codex"
target: "./wms-mcd-v2-claude.md"
created: "2026-05-21"
updated: "2026-05-21"
---

# Review GPT - MCD V2 Claude

## Verdict

Ne pas adopter `wms-mcd-v2-claude.md` comme MCD officiel en l'etat.

La V2 Claude ameliore le nommage (`deplace_par` -> `concerne`) et le rendu Mocodo passe sans chevauchement, mais elle ne corrige pas les defauts bloquants de la V1 : identifiant composite `ARTICLE`, rattachement site des transactions, verrou client au MLD/DDL.

## Defauts a corriger

| Priorite | Defaut | Fichier / ligne | Correction attendue |
|---|---|---|---|
| Bloquant | `ARTICLE` n'a toujours pas d'identifiant composite reel dans Mocodo. `REFERENCE` n'est pas soulignee dans le SVG. | `wms-mcd-v2-claude.mcd:3` | Remplacer `ARTICLE: CODE_CLIENT, REFERENCE` par `ARTICLE: CODE_CLIENT, _REFERENCE`. |
| Bloquant | `MOUVEMENT` n'est pas rattache explicitement a un `SITE`, alors que le sujet exige que chaque transaction soit rattachee a un site. | `wms-mcd-v2-claude.md:65-66` | Ajouter `rattache, 0N SITE, 11 MOUVEMENT` ou une regle MLD/DDL equivalente et non ambigue. |
| Majeur | La separation client reste faible : `id_client` est une FK simple, pas un verrou composite avec l'article. | `wms-mcd-v2-claude.md:121-127` | Utiliser une FK composite vers `ARTICLE(code_client, reference)` pour `STOCK` et `MOUVEMENT`. |
| Majeur | La phrase "Aucun changement par rapport a v0.8" conserve les problemes d'integrite de la v0.8. | `wms-mcd-v2-claude.md:114` | Remplacer par un impact MLD/DDL explicite avec les nouvelles contraintes. |
| Majeur | `STOCK` reste identifie par `ID_STOCK`, donc l'unicite metier `(ARTICLE, EMPLACEMENT)` n'est pas portee conceptuellement. | `wms-mcd-v2-claude.md:68` | Soit identifier `STOCK` par `(CODE_CLIENT, REFERENCE, CODE_EMPLACEMENT)`, soit documenter une contrainte unique obligatoire au MLD/DDL. |
| Moyen | La ternaire `stockage(ARTICLE, EMPLACEMENT, STOCK)` est defendable mais fragile oralement si `STOCK` garde un identifiant autonome. | `wms-mcd-v2-claude.md:37-44` | Clarifier si `STOCK` est une association porteuse d'attributs ou une entite associative renforcee avec identification metier. |
| Mineur | Le document n'est pas autonome : il renvoie aux entites de `wms-mcd.md`. | `wms-mcd-v2-claude.md:52-54` | Reprendre la liste complete des 7 entites dans le fichier V2. |
| Mineur | Les liens vers `wms-mld.md`, `wms-ddl.sql` et `../DECISIONS.md` pointent vers des fichiers absents du depot actuel. | `wms-mcd-v2-claude.md:17-19` | Creer ces fichiers ou retirer les references tant qu'ils n'existent pas. |

## Points valides

- Le renommage `deplace_par` -> `concerne` est meilleur.
- Le rendu Mocodo passe `--detect_overlaps`.
- L'association ternaire `stockage` peut etre defendue en Merise si elle est mieux justifiee.

## Recommendation

Base officielle recommandee : `wms-mcd-v2-gpt.md`.

Option si Claude veut reprendre sa V2 : appliquer au minimum les corrections bloquantes suivantes :

1. `ARTICLE: CODE_CLIENT, _REFERENCE`
2. ajout de `SITE rattache MOUVEMENT`
3. FK composite client/article au MLD/DDL
4. clarification de l'identification de `STOCK`
5. suppression de "Aucun changement par rapport a v0.8"
