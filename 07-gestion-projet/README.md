# Livrable 7 — Présentation de la gestion du projet

**Statut** : 🟡 amorcé (journal de décisions vivant)
**Exigence sujet** : §III.1 « organisation de l'équipe (rôles et responsabilités) et planification (jalons, séquencement, charges), suivi d'avancement (liste de tâches avec statut et responsables), registre de risques (au moins 5 risques avec impacts et mesures de mitigation), journal des décisions (au moins 3 arbitrages majeurs) »
**Owner** : Ianis

## Contenu attendu

| Sous-livrable | Statut | Fichier |
|---|---|---|
| Organisation équipe + RACI | ⏳ | à créer ici |
| Planning + jalons + charges (Gantt) | ⏳ | à créer ici |
| Suivi d'avancement (tâches + statut + responsable) | 🟡 [`../EQUIPE.md`](../EQUIPE.md) « Livrables restants » + READMEs par livrable | à consolider |
| **Registre des risques (≥5)** | ✅ amorcé | [`registre-risques.md`](registre-risques.md) |
| **Journal des décisions (≥3 arbitrages majeurs)** | ✅ amorcé | [`journal-decisions.md`](journal-decisions.md) |

## Source de vérité

- **Journal des décisions** : [`journal-decisions.md`](journal-decisions.md) — synthèse courte des arbitrages majeurs, pour soutenance. Pointe vers les ADR détaillés dans [`../decisions/`](../decisions/).
- **Registre des risques** : [`registre-risques.md`](registre-risques.md) — risques projet et techniques, impacts, mitigations.
- **Changelog projet** : [`../CHANGELOG.md`](../CHANGELOG.md) — historique des changements importants (livrables atteints, décisions actées).

## Workflow tenu à jour

À chaque arbitrage majeur :
1. Créer un ADR dans [`../decisions/000N-titre.md`](../decisions/)
2. Ajouter une ligne dans [`journal-decisions.md`](journal-decisions.md) qui pointe vers l'ADR

À chaque livrable validé :
1. Update le `README.md` du livrable
2. Ajouter une entrée dans [`../CHANGELOG.md`](../CHANGELOG.md)
