---
livrable: "01 — Architecture technique"
scope: "01-architecture"
section: "Convergence review MCD V2 — Claude × GPT"
version: "1.3"
status: "open"
owner: "Ianis"
participants: ["Claude Code", "GPT-5 Codex"]
arbitre: "Ianis"
target_files:
  - "./wms-mcd-v2-claude.md"
  - "./wms-mcd-v2-gpt.md"
created: "2026-05-21"
updated: "2026-05-21"
---

# Convergence MCD V2 — Claude × GPT-5 Codex

> **Objectif** : confronter `wms-mcd-v2-claude.md` et `wms-mcd-v2-gpt.md`, lister les points d'accord et de désaccord, converger vers un MCD V3 unique. Ianis arbitre les choix de design contestés en s'appuyant sur les décisions déjà prises (notamment l'abandon explicite du double chemin client en v0.8).

## Format

Pour chaque point, 3 sections :
- **Position Claude** — ce que défend la v2-claude
- **Position GPT** — ce que défend la v2-gpt (et sa review)
- **Convergence proposée** — terrain d'entente ou décision Ianis attendue

Les blocs de réponse GPT ont été remplis en version 1.1. Claude a répondu en 1.2. GPT a corrigé en 1.3 deux biais techniques sur le comparatif trigger/FK composite, puis lancé une V3-GPT.

---

## Point 1 — Identifiant composite ARTICLE dans Mocodo

### Position Claude (v2-claude)

```mocodo
ARTICLE: CODE_CLIENT, REFERENCE, libelle, ...
```

L'identifiant composite est expliqué dans une note texte sous le tableau §3.1. Le SVG ne souligne pas REFERENCE.

### Position GPT (review)

```mocodo
ARTICLE: CODE_CLIENT, _REFERENCE, libelle, ...
```

Le `_REFERENCE` force le soulignement visuel dans le SVG, rendant l'identifiant composite **visible sur le diagramme** sans avoir à lire la doc.

### Convergence proposée

**Claude reconnaît** : critique valide, c'est un vrai défaut de rendu. La syntaxe `_REFERENCE` est meilleure. À appliquer dans la V3.

**Action V3** : utiliser `ARTICLE: CODE_CLIENT, _REFERENCE, libelle, poids, longueur, largeur, hauteur, fournisseur`.

**Question ouverte** : aller plus loin et passer ARTICLE en **entité faible** via identification relative Mocodo `possede, 0N CLIENT, _11 ARTICLE` ? C'est la forme Merise académique pure de « REFERENCE unique par client ».

### Réponse GPT 1.1

Position GPT : **identifiant composite classique**, pas entité faible `_11` pour la V3 officielle.

Argument substantiel :

1. Le besoin métier à défendre devant le jury est simple : une référence article est unique **dans le périmètre d'un client**. Le diagramme doit donc montrer explicitement `(CODE_CLIENT, REFERENCE)` comme identifiant. `ARTICLE: CODE_CLIENT, _REFERENCE` rend cette règle visible sans dépendre d'une lecture Merise avancée.
2. L'identification relative pure Mocodo (`possede, 0N CLIENT, _11 ARTICLE`) est académiquement défendable, mais elle masque `CODE_CLIENT` dans l'association. Pour un jury MSPR, c'est moins lisible que l'identifiant composite affiché dans l'entité.
3. Il ne faut pas mélanger les deux formes. Si Ianis choisit l'entité faible, alors `ARTICLE` ne doit plus porter `CODE_CLIENT` comme attribut métier ; il faut plutôt un discriminateur `REFERENCE` renforcé par `CLIENT`. Si on garde `CODE_CLIENT` dans `ARTICLE`, la forme claire est le composite classique.

Décision GPT proposée : **V3 = `ARTICLE: CODE_CLIENT, _REFERENCE, libelle, poids, longueur, largeur, hauteur, fournisseur`**. Ajouter une note : "forme Merise relative possible, écartée pour lisibilité soutenance".

### Réponse Claude 1.2

**Accord avec GPT.** L'argument lisibilité soutenance est décisif : un jury MSPR (mix techniques + jurés non-Merise) lit mieux un identifiant composite affiché qu'une notation académique `_11` qui demande de connaître l'identification relative Mocodo. La forme `_11` reste pédagogiquement intéressante à mentionner mais pas à imposer.

**Position Claude 1.2** : ralliée à GPT. V3 = composite classique `ARTICLE: CODE_CLIENT, _REFERENCE` + note bas de §3.1 « la forme entité faible `possede, 0N CLIENT, _11 ARTICLE` aurait été équivalente conceptuellement, écartée pour lisibilité ».

✅ **Convergence acquise** sur ce point.

---

## Point 2 — Rattachement MOUVEMENT ↔ SITE

### Position Claude (v2-claude)

Pas d'association directe `MOUVEMENT-SITE`. Le site est **déductible** via :
- `MOUVEMENT.depart.emplacement.site` (pour SORTIE, TRANSFERT)
- `MOUVEMENT.arrivee.emplacement.site` (pour ENTREE, TRANSFERT)
- `MOUVEMENT.depart OU arrivee` (pour AJUSTEMENT — règle « exactement un des deux NOT NULL »)

→ tout mouvement a au moins un emplacement, donc un site dérivable.

Ajouter `rattache SITE-MOUVEMENT` = **3e chemin redondant** à maintenir cohérent avec `depart` et `arrivee`. Même pattern de double chemin qu'on a explicitement abandonné pour CLIENT en v0.8 (cf. décision implicite Ianis).

### Position GPT (v2-gpt + review)

Ajoute explicitement `rattache, 0N SITE, 11 MOUVEMENT` avec rationale : « exigence explicite du sujet » et facilite l'audit par site indépendamment du contexte emplacement (utile pour BI, reporting, AJUSTEMENT global).

### Convergence proposée

**Désaccord substantiel.** Deux questions à trancher :

1. **Le sujet exige-t-il vraiment le rattachement explicite ?** À vérifier dans `ressources/sujet-mspr3.pdf` §1. Si oui → ajouter. Si « rattachement » signifie juste « traçable » → la dérivation via emplacement suffit.
2. **Y a-t-il un cas d'AJUSTEMENT sans emplacement** (inventaire global d'un site complet) ? Si oui → `rattache` devient nécessaire. Si non → redondant.

**Position Claude maintenue** : pas d'association `rattache` sauf preuve d'exigence sujet ou cas AJUSTEMENT sans emplacement. Cohérence avec la décision V1 d'éliminer les double-chemins.

### Réponse GPT 1.1

Citation exacte du sujet, `ressources/sujet-mspr3.pdf`, page 5, §1 "Modèle de données et intégrité" :

> "Sites / entrepôts : chaque stock / transaction est rattachée à un site."

Point important : cette ligne impose l'**invariant métier** "chaque transaction a un site", mais elle ne prouve pas à elle seule que l'association doit être **directe** dans le MCD.

Je retire donc la classification "bloquant" de `SITE rattache MOUVEMENT` comme association directe obligatoire. Le lien direct est une option de durcissement, pas une obligation, si la V3 garantit formellement :

1. tout `MOUVEMENT` a au moins un emplacement non NULL selon `type_mouvement` ;
2. pour `TRANSFERT`, `depart.site = arrivee.site` puisque le consensus adopte le transfert intra-site ;
3. pour `AJUSTEMENT`, exactement un emplacement est renseigné, donc le site est dérivable ;
4. les requêtes/reportings par site utilisent cette dérivation ou une vue SQL documentée.

Cas où je maintiens `rattache SITE-MOUVEMENT` : si Ianis veut autoriser un **AJUSTEMENT global de site sans emplacement**. Exemple : correction d'inventaire au niveau "WH1" après écart global, sans localisation précise. Dans ce cas, la dérivation par emplacement casse et `MOUVEMENT` doit porter un site direct.

Décision GPT proposée : **pas d'association directe par défaut en V3**, sauf si Ianis confirme le cas "ajustement global sans emplacement". À la place, documenter la règle : "le site d'une transaction est dérivé de l'emplacement de départ ou d'arrivée ; si deux emplacements sont renseignés, ils appartiennent au même site".

### Réponse Claude 1.2

**Accord avec GPT 1.1.** La citation sujet (« chaque stock/transaction est rattachée à un site ») exprime un **invariant métier**, pas une exigence de modélisation directe. Si la dérivation par emplacement garantit l'invariant pour 100% des cas, l'association directe est redondante.

**Le seul cas qui justifierait `rattache`** : l'AJUSTEMENT global de site sans emplacement précis (correction d'inventaire au niveau « WH1 » après écart global). Question à Ianis : ce cas existe-t-il dans le périmètre métier NTL ?

**Position Claude 1.2** : ralliée à GPT 1.1. V3 = pas d'association `rattache` par défaut, règle de dérivation documentée explicitement dans §3.4. Si Ianis confirme l'AJUSTEMENT global → on l'ajoute.

✅ **Convergence acquise** sous réserve d'arbitrage Ianis sur le cas AJUSTEMENT global.

`[À TRANCHER PAR IANIS — l'AJUSTEMENT global de site sans emplacement est-il un cas métier NTL réel ?]`

---

## Point 3 — FK composite client/article au MLD/DDL

### Position Claude (v2-claude)

- MCD : association unique `CLIENT possede ARTICLE`
- MLD : `id_client` colonne dénormalisée FK simple vers `clients` sur `stocks` et `mouvements`
- Cohérence `stock.id_client = article.id_client` garantie **applicativement** à l'insertion

C'est la décision **explicite** prise par Ianis en v0.8 (« on garde simple, id_client dans stock et article »). Le double chemin client de la v0.7 (FK composite `(id_article, id_client) → articles(id_article, id_client)`) a été **abandonné par décision**, pas par oubli.

### Position GPT (v2-gpt + review)

Reclassifie cette décision comme « bloquant » et exige une **FK composite** `(id_article, id_client)` sur STOCK et MOUVEMENT vers `articles(id_article, id_client)` pour verrouiller la séparation client **au niveau base**.

### Convergence proposée

**Désaccord fondamental.** GPT tente de réintroduire un pattern explicitement rejeté par Ianis. Trois arguments en faveur du maintien de la décision V1 :

1. **Décision tranchée** : Ianis a explicitement dit « on garde simple, id_client dans stock et article ». GPT ne peut pas reclassifier en bloquant une décision design qu'il considère sous-optimale.
2. **Cohérence v0.8** : la suppression du double chemin client est tracée dans le journal de version. Le réintroduire = revenir à v0.7.
3. **Pragmatique** : la cohérence applicative à l'insertion est suffisante pour un WMS V1 MVP (4 personnes × 19h, posture jury assumée).

**Position Claude maintenue** : pas de FK composite client. Si GPT a un argument **nouveau** (≠ « c'est plus propre »), à l'expliciter.

### Réponse GPT 1.1

Je retire le terme **bloquant** contre la décision v0.8 d'Ianis. La FK composite client/article n'est pas obligatoire si Ianis assume explicitement une cohérence applicative ou procédurale.

Argument nouveau, non Merise : le sujet demande des "règles d'intégrité explicites et contraintes implémentées" puis "Clients : séparation des données par client" (`ressources/sujet-mspr3.pdf`, page 5, §1). Une simple phrase "garantie applicativement à l'insertion" est fragile si la base est alimentée par :

1. import CSV/batch d'exploitation ;
2. script de reprise de données ;
3. compte SQL technique trop permissif ;
4. correction manuelle en incident ;
5. futur ETL/reporting qui écrit directement dans `mouvements` ou `stocks`.

Incident concret : un import crée `mouvements.id_client = CLIENT_A` avec `id_article` appartenant à `CLIENT_B`. Les deux FK simples passent (`CLIENT_A` existe, l'article existe), mais le reporting client A affiche une référence client B. C'est exactement une fuite logique multi-tenant.

Cela dit, il existe un compromis acceptable sans FK composite :

- garder `id_client` simple uniquement si les écritures passent par procédure stockée, trigger, contrainte applicative testée, ou si `id_client` est supprimé des tables enfants et toujours dérivé via `ARTICLE` ;
- documenter cette mitigation dans le MLD/DDL, pas seulement dans le texte MCD.

Décision GPT proposée : **reclasser en risque majeur, pas bloquant**. Si V3 garde la décision v0.8, elle doit ajouter une mitigation DDL/procédurale explicite. Si Ianis veut une garantie base pure, alors FK composite.

### Réponse Claude 1.2

**Concession Claude.** L'argument GPT 1.1 sur les vecteurs d'écriture hors application (import CSV, ETL, correction manuelle, compte SQL technique) est **légitime et concret**. Mon argument initial « cohérence applicative à l'insertion suffit » a sous-estimé ce risque. L'incident décrit (mouvement avec `id_client=A` mais article appartenant à `B` → fuite multi-tenant) est **réaliste** dans un WMS opérationnel.

**Cependant** : la solution FK composite n'est pas la seule réponse. 4 mitigations possibles, par ordre de complexité croissante :

| Option | Garantie | Coût applicatif | Coût SQL |
|--------|----------|-----------------|----------|
| **A** : `id_client` simple + cohérence app uniquement | Faible (vecteurs hors app) | Nul | Nul |
| **B** : `id_client` simple + **triggers DDL** `BEFORE INSERT/UPDATE` validant `NEW.id_client = (SELECT id_client FROM articles WHERE id_article = NEW.id_article)` | Forte si tous les chemins d'écriture et d'update sont couverts | Nul (transparent) | Moyen (triggers à maintenir et tester) |
| **C** : Supprimer `id_client` des tables enfants, **dériver via JOIN** ARTICLE | Maximale (impossible d'incohérence) | Léger (JOIN systématique sur reporting) | Pas de FK composite |
| **D** : **FK composite** `(id_article, id_client) → articles(id_article, id_client)` | Maximale et déclarative | Faible | Moyen (`id_article` surrogate reste possible, mais `UNIQUE(id_article, id_client)` est obligatoire sur `articles`) |

**Recommandation Claude 1.2** : **option B (trigger)**. Bénéfices :
- Garantie base si les triggers couvrent `INSERT` et `UPDATE` sur `stocks`/`mouvements`, et si les updates de `articles.id_client` sont interdites ou contrôlées.
- Sans le coût `articles(id_article, id_client)` en UNIQUE composite obligatoire.
- Transparent pour l'application.
- Mitigation **base**, pas applicative — répond à l'argument GPT.

**Position Claude 1.2** : ralliée à la critique GPT (risque réel), mais propose **option B (trigger)** comme compromis entre la décision Ianis « id_client simple » et la garantie base demandée par GPT. Ianis tranche entre B et D.

`[À TRANCHER PAR IANIS — option B (trigger), D (FK composite), ou autre ?]`

### Correction GPT 1.3

Deux corrections techniques :

1. La phrase "pas de surrogate possible sur articles" était fausse. On peut garder `articles.id_article` comme PK surrogate et ajouter `UNIQUE(id_article, id_client)` pour supporter la FK composite `(id_article, id_client)`.
2. Les triggers ne donnent pas automatiquement les mêmes garanties qu'une FK composite. Ils doivent couvrir `BEFORE INSERT` et `BEFORE UPDATE` sur `stocks` et `mouvements`, et il faut interdire ou contrôler toute modification de `articles.id_client`. Sinon une incohérence peut apparaître après insertion.

Position GPT 1.3 : **recommandation D (FK composite)** pour la V3-GPT. C'est plus simple à défendre devant jury : contrainte déclarative, lisible dans le DDL, vérifiable sans expliquer une logique trigger. Coût acceptable : une contrainte `UNIQUE(id_article, id_client)` sur `articles`.

---

## Point 4 — Identifiant STOCK : surrogate vs métier

### Position Claude (v2-claude)

```
STOCK: ID_STOCK, quantite, date_maj
```

Identifiant surrogate `ID_STOCK` auto-incrément. Unicité métier portée par **contrainte `UNIQUE (id_article, id_emplacement)`** au MLD.

**Avantages** :
- FK simples depuis tout code applicatif (`/stocks/{id}`)
- Verrou optimiste possible sur 1 colonne
- Cohérent avec convention WMS industrielle

### Position GPT (v2-gpt + review)

```
STOCK: CODE_CLIENT, _REFERENCE, _CODE_EMPLACEMENT, quantite, date_maj
```

Identifiant composite naturel **3-uplet métier**. Pas de surrogate. L'unicité est portée par l'identifiant lui-même.

**Avantages revendiqués** :
- Conformité Merise puriste (identifiant naturel = identifiant)
- Unicité métier portée conceptuellement, pas reléguée au MLD

### Convergence proposée

**Désaccord pragmatique.** Argumentaire Claude :
- Une clé composite 3-uplet sur STOCK = **3 colonnes en FK partout** (mouvements, audit, API REST)
- Inconvénient applicatif lourd pour gain conceptuel marginal
- L'unicité métier `UNIQUE (id_article, id_emplacement)` est aussi forte qu'un identifiant composite, juste exprimée différemment

**Compromis possible** : garder `ID_STOCK` surrogate **mais** mentionner explicitement la contrainte `UNIQUE` métier dans le MCD (pas juste reléguée au MLD), pour répondre à la critique « unicité métier masquée ».

### Réponse GPT 1.1

J'accepte le compromis Claude : **`ID_STOCK` surrogate + contrainte métier `UNIQUE` explicite**.

Raison : la clé composite 3-uplet rend bien l'unicité conceptuelle, mais elle coûte trop cher applicativement pour peu de gain :

1. API et écrans plus simples avec `/stocks/{id_stock}` ;
2. FK plus courtes si une future table référence une ligne de stock ;
3. index plus compacts ;
4. cohérent avec une implémentation WMS industrielle.

La critique GPT initiale visait surtout le fait que l'unicité métier était **masquée**. Le compromis corrige ça si la V3 écrit noir sur blanc :

- identifiant technique : `ID_STOCK` ;
- clé candidate métier obligatoire : `UNIQUE (id_article, id_emplacement)` ou, si identifiants métier conservés, `UNIQUE (code_client, reference, code_emplacement)`.

Décision GPT proposée : **V3 = `STOCK: ID_STOCK, quantite, date_maj` + note MCD "unicité métier obligatoire ARTICLE × EMPLACEMENT"**.

### Réponse Claude 1.2

✅ **Accord total.** Compromis accepté par les deux côtés.

**Action V3** :
- Tableau §3.1 entité STOCK : `ID_STOCK, quantite, date_maj`
- Note explicite sous le tableau : « Unicité métier obligatoire `UNIQUE (id_article, id_emplacement)` portée par contrainte au MLD. `ID_STOCK` est un identifiant technique surrogate pour référencement applicatif (API REST, verrou optimiste). »

✅ **Convergence acquise.**

---

## Point 5 — Stock-Article-Emplacement : ternaire vs 2 binaires

### Position Claude (v2-claude)

**Ternaire** `stockage(ARTICLE, EMPLACEMENT, STOCK)` avec STOCK = entité associative renforcée.

**Rationale** : STOCK n'existe pas indépendamment, sa sémantique est définie par le couple (ARTICLE, EMPLACEMENT). Convention Merise académique = ternaire avec entité renforcée.

### Position GPT (v2-gpt)

**2 binaires** `stocke_dans(ARTICLE, STOCK)` + `porte(EMPLACEMENT, STOCK)`. Conserve la structure v0.8 sans renommage.

### Convergence proposée

**Désaccord stylistique.** Les deux représentations sont **équivalentes au MLD** (même table `stocks` avec FK vers articles et emplacements). La ternaire est plus académique, les 2 binaires plus simples visuellement.

Claude reconnaît la critique GPT « ternaire fragile oralement si STOCK garde un identifiant autonome ». Réponse possible en soutenance :
> « STOCK est une entité associative renforcée : son identifiant ID_STOCK lui donne une existence référençable, mais sa sémantique reste dépendante du couple (ARTICLE, EMPLACEMENT) — d'où la ternaire. »

**Compromis possible** : garder la ternaire **mais** ajouter un paragraphe explicite « STOCK = entité associative renforcée » dans la doc.

### Réponse GPT 1.1

J'accepte la **ternaire `stockage(ARTICLE, EMPLACEMENT, STOCK)`** si la V3 ajoute une justification explicite et évite l'ambiguïté avec `ID_STOCK`.

Argument substantiel :

1. Ianis a contesté les noms `stocke_dans` et `porte` comme ambigus. Garder deux binaires oblige à renommer proprement les associations, sinon on conserve une dette de lisibilité.
2. La ternaire exprime mieux la dépendance sémantique : une ligne `STOCK` n'existe que pour un couple `(ARTICLE, EMPLACEMENT)`.
3. Le MLD reste identique : table `stocks` avec FK vers `articles` et `emplacements`, plus `quantite/date_maj`.

Condition GPT : ne pas vendre la ternaire comme "Merise pur" de manière vague. Écrire explicitement :

> `STOCK` est une entité associative renforcée : `ID_STOCK` sert d'identifiant technique référençable, mais l'unicité métier reste le couple `(ARTICLE, EMPLACEMENT)`, matérialisé par une contrainte `UNIQUE`.

Décision GPT proposée : **V3 = ternaire acceptée + paragraphe "STOCK = entité associative renforcée" + contrainte `UNIQUE` explicite**.

### Réponse Claude 1.2

✅ **Accord total.** Compromis accepté.

**Action V3** :
- Diagramme Mocodo : association ternaire `stockage, 0N ARTICLE, 11 STOCK, 0N EMPLACEMENT`
- Paragraphe explicite §3.4 : « **STOCK est une entité associative renforcée** : `ID_STOCK` sert d'identifiant technique référençable, mais l'unicité métier reste le couple `(ARTICLE, EMPLACEMENT)`, matérialisée par contrainte `UNIQUE (id_article, id_emplacement)` au MLD. La ternaire `stockage` exprime cette dépendance fonctionnelle conceptuellement. »
- Élimine les noms ambigus `stocke_dans` / `porte` que Ianis a contestés.

✅ **Convergence acquise.**

---

## Point 6 — Renommage `deplace_par` → `concerne`

### Position Claude

`MOUVEMENT (1,1) concerne ARTICLE (0,N)` — lecture active naturelle.

### Position GPT

Idem — `concerne`.

### Convergence

✅ **Accord total.** À appliquer.

---

## Point 7 — TRANSFERT inter-site

### Position Claude (v2-claude)

Pas de règle explicite. La règle `TRANSFERT : depart NOT NULL ET arrivee NOT NULL ET depart <> arrivee` autorise techniquement un transfert inter-site.

### Position GPT (v2-gpt)

Règle explicite : **TRANSFERT intra-site uniquement**. Un mouvement inter-site = 2 mouvements distincts (SORTIE site A + ENTREE site B).

### Convergence proposée

**Claude reconnaît** : la règle GPT est plus claire et défendable opérationnellement. Un transfert inter-site implique souvent un transport physique (camion, transporteur) qui mérite d'être tracé comme 2 événements distincts.

**Action V3** : adopter la règle GPT « TRANSFERT intra-site uniquement », à porter au DDL via `CHECK ck_transfert_intra_site` (depart.site = arrivee.site).

---

## Point 8 — Autonomie de la doc V2

### Position Claude (v2-claude)

Tableau §3.1 entités absent du fichier V2 — renvoie à `wms-mcd.md` v0.8.

### Position GPT (review)

Doc V2 doit être **autonome** : recopier le tableau complet des 7 entités.

### Convergence

✅ **Accord.** À appliquer en V3.

---

## Point 9 — Liens cassés

### Position Claude (v2-claude)

Liens vers `wms-mld.md`, `wms-ddl.sql`, `../DECISIONS.md` qui n'existent pas dans le repo actuel.

### Position GPT (review)

Retirer ou marquer « à créer ».

### Convergence

✅ **Accord.** En V3, soit créer les fichiers (scope ultérieur), soit ajouter `*[fichier prévu]*` à côté des liens.

---

## Synthèse — Vers une V3 unifiée

### Points acquis (consensus Claude × GPT après round 1.2)

1. ✅ `ARTICLE: CODE_CLIENT, _REFERENCE` (souligné Mocodo) — composite classique, pas entité faible `_11`
2. ✅ Renommage `deplace_par` → `concerne`
3. ✅ TRANSFERT intra-site uniquement (inter-site = 2 mouvements SORTIE+ENTREE)
4. ✅ Doc V3 autonome (recopier les entités)
5. ✅ Liens cassés à corriger (`*[fichier prévu]*` ou créer)
6. ✅ `STOCK: ID_STOCK, quantite, date_maj` + contrainte `UNIQUE (id_article, id_emplacement)` explicite au MCD
7. ✅ Ternaire `stockage(ARTICLE, EMPLACEMENT, STOCK)` + paragraphe « entité associative renforcée »
8. ✅ Pas d'association `SITE rattache MOUVEMENT` par défaut — site dérivé via depart/arrivee.emplacement

### Points à trancher par Ianis (2 restants)

9. ❓ **Cas AJUSTEMENT global sans emplacement** : existe-t-il dans le métier NTL ? Si oui → ajouter `rattache SITE-MOUVEMENT`. Si non → règle de dérivation suffit.

10. ❓ **Garantie séparation client** au MLD/DDL : quelle option ?
    - **A** : `id_client` simple + cohérence applicative seule (décision v0.8 originale — risque accepté)
    - **B** : `id_client` simple + **triggers DDL** validant `NEW.id_client = ARTICLE.id_client` sur INSERT/UPDATE *(proposition Claude 1.2 corrigée)*
    - **C** : Supprimer `id_client` des tables enfants, dériver via JOIN
    - **D** : **FK composite** `(id_article, id_client)` avec `UNIQUE(id_article, id_client)` sur `articles` *(recommandation GPT 1.3 / V3-GPT)*

### Action attendue

1. ~~GPT a complété les blocs en version 1.1.~~ ✅
2. ~~Claude répond ligne à ligne en version 1.2.~~ ✅ — 7/10 points consensuels, 2 décisions d'arbitrage restantes (points 9 et 10)
3. **Ianis arbitre** les 2 points restants
4. Une fois tranchés, **création de `wms-mcd-v3.md`** consolidé

---

## Journal de la convergence

| Itération | Date | Auteur | Action |
|-----------|------|--------|--------|
| 1.0 | 2026-05-21 | Claude Code | Initialisation document, 10 points listés, position Claude + position GPT (extraite de review), 5 points en consensus, 5 en désaccord |
| 1.1 | 2026-05-21 | GPT-5 Codex | Complétion des blocs de réponse GPT, concessions sur `rattache`, FK composite, `ID_STOCK` surrogate et ternaire `stockage` |
| 1.2 | 2026-05-21 | Claude Code | Ralliement sur points 1/2/4/5 (consensus 7/10) ; concession partielle point 3 (risque GPT légitime, propose option B trigger DDL comme compromis vs option D FK composite) ; 2 décisions Ianis restantes (points 9 et 10) |
| 1.3 | 2026-05-21 | GPT-5 Codex | Correction du comparatif trigger/FK composite : surrogate article compatible avec FK composite via `UNIQUE(id_article, id_client)`, triggers seulement équivalents si INSERT/UPDATE et updates article contrôlés ; lancement V3-GPT avec option D |
| 1.x | TBD | Ianis | Arbitrage points 9 (AJUSTEMENT global) et 10 (option A/B/C/D séparation client) |
| 2.0 | TBD | Claude/GPT | Génération `wms-mcd-v3.md` consolidé |
