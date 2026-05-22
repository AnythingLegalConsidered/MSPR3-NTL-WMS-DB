# Livrable 8 — Note Comité de Direction

**Statut** : 🟡 ébauche V1 livrée — [`note-direction.md`](note-direction.md) (à relire / arbitrer chiffrages)
**Exigence sujet** : §II.3 « rédiger une note 'Comité de direction' (non technique) expliquant les risques cyber majeurs liés à la BDD, l'impact métier, et les mesures proposées (avec priorisation) » + §III.1 « Note de direction »
**Owner** : Ianis (V1) — relecture équipe à planifier

## Contenu attendu

- [ ] **Format court** : 1 à 2 pages maximum, langage non-technique
- [ ] **Public** : direction NTL fictive (CODIR)
- [ ] **Structure suggérée** :
  1. Contexte en 5 lignes
  2. Top 3-5 risques cyber majeurs sur la BDD (vulgarisés)
     - Compromission accès
     - Perte de données
     - Indisponibilité service (impact opérations 4 sites)
     - Fuite données client (multi-tenant)
     - Ransomware
  3. Impact métier de chaque risque (en termes opérationnels : « arrêt quais », « pénalités clients », « perte chiffre d'affaires journalier »)
  4. Mesures proposées avec priorité (P1/P2/P3)
  5. Décision attendue de la direction (validation budget, validation politique, etc.)

## Décisions structurantes

À documenter dans `../decisions/` si arbitrage cyber.

## Point d'entrée pour démarrer

- Sujet §I mentionne plusieurs faiblesses cyber : MFA partiel, droits SharePoint héritage par défaut, pas de tests de restauration, sauvegardes non externalisées, comptes dispersés.
- S'appuyer sur le registre des risques [`../07-gestion-projet/registre-risques.md`](../07-gestion-projet/registre-risques.md) (R04, R06, R07) pour les éléments techniques sous-jacents.
- Style : phrases courtes, pas de jargon, métaphores OK (« vol de clés de coffre » plutôt que « compromission credentials »).
