+++
title = "Le code fonctionne. Mais est-il de qualité ?"
type = "post"
date = '2026-05-30T02:00:07+01:00'
categories = ["Article"]
tags = ["AI", "Programming"]
+++

> **À chaque problème complexe correspond une solution claire, simple… et fausse.**  
> — H. L. Mencken

J’ai passé des années à chercher des solutions élégantes à des problèmes complexes.

Aujourd’hui, l’un d’eux me résiste particulièrement :

**Comment évaluer la qualité réelle d’un dépôt de code source ?**

Avec l’IA, le défi a changé. Ce n’est plus seulement “est-ce que ça fonctionne ?”, mais :  
**Ce code sera-t-il encore maintenable, sûr et fiable dans six mois ?**

## Pourquoi la qualité du code reste difficile à mesurer.

Derrière cette question apparemment simple, tout devient vite subjectif.

Faut-il s’appuyer sur une norme ? Ou faut-il assumer une évaluation plus empirique, fondée sur ce qui rend réellement un dépôt agréable ou pénible à maintenir : lisibilité, complexité cognitive, couplage, pertinence des structures et des algorithmes ?

Je ne parle même pas des multiples manières de définir la qualité selon l’objectif poursuivi.[^1]

La qualité dépend toujours du contexte : criticité, contraintes métier, durée de vie attendue, performance attendue, niveau de risque acceptable.

Comme je m’intéresse surtout aux dépôts produits en grande partie, voire entièrement, avec l’aide de l’IA, je définis ici un code de qualité comme un code qui fait ce qu’on attend de lui, de manière performante, frugale, sécurisée, et suffisamment simple pour rester maintenable.

Dit comme cela, cela ne semble pas très objectif, c’est pourquoi j’ai cru nécessaire de choisir l’approche de l’évaluation basée sur un modèle pour donner un peu d’objectivité à ma démarche.

Mais avant de parler du modèle, revenons à l’objectif.

## Le besoin de mesurer face à l'IA-slop.

Chaque modèle ou norme définissant la qualité logicielle vise un objectif qui peut être (parfois subtilement) différent :
DORA vise la performance devops/delivery
CMMI vise la maturité du processus de développement
CVSS vise la sécurité des systèmes informatiques

C’est pourquoi il me faut vous parler de mon objectif avant de vous parler du modèle que j’ai choisi.

Je fais partie de ceux qui croient qu’il est plus difficile d’améliorer quelque chose qu’on ne peut pas mesurer.
C’est pourquoi j’ai toujours cherché à mesurer la qualité du code produit pour l’améliorer.
Et l’arrivée de l’IA et le spectre de l’IA slop, ont rendu ce besoin encore plus impérieux.

Je ne pense pas que l’IA produise intrinsèquement du code de qualité inférieure. Je pense plutôt qu’elle agit comme un amplificateur : elle améliore le travail d’un bon développeur, mais peut produire une ignominie entre les mains d’un vibe codeur dépourvu de bases théoriques.

Mais cette hypothèse doit être validée : c’est pourquoi il me faut un moyen objectif de mesurer la qualité des différents dépôts.

## KISS : un modèle simple pour une réalité complexe.

J’ai choisi de ne pas réutiliser un des modèles existants, il y a plusieurs raisons à cela :

* La plupart des modèles que je connais ne sont pas assez pratiques à mon goût
* Je voulais commencer avec quelque chose de simple (KISS)
* Je voulais pouvoir utiliser les outils actuels avec les problématiques actuelles
* Je pense qu’il reste de la place pour l’innovation

## Passer de l'intuition à la métrique.

Je ne cherche donc pas à produire une vérité absolue, mais une grille assez stable pour comparer des dépôts, repérer les risques, et guider les améliorations.

Pour mes premiers essais j’ai choisi un modèle simple avec une note sur 10[^2] sur chacun des 6 axes :

| Axe                         | Ce que je cherche                                                                                               | Signal faible typique                                                                                        |
| --------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Architecture**            | Responsabilités claires, dépendances maîtrisées, modularité, séparation des couches, configuration propre       | God object, dépendances circulaires, configuration hardcodée...                       |
| **Performance**             | Algorithmes adaptés, complexité raisonnable, usage efficace des ressources, absence de traitements inutiles     | Boucles coûteuses, requêtes répétées, absence de cache évident, chargements complets inutiles...                |
| **Uniformité**              | Conventions cohérentes, style homogène, uniformité du code                    | Incohérence dans les styles, le nommage des fichiers, variables, la gestion des erreurs et des logs...             |
| **Sécurité**                | Secrets, authentification, autorisation, validation des entrées, exposition minimale, dépendances sûres         | `.env` versionné, droits trop larges, inputs non validés, absence de contrôle d’accès, dépendances obsolètes |
| **Documentation**           | Intention du projet, installation, architecture, décisions importantes, limites connues, cohérence avec le code | README incomplet, docs obsolètes, absence de specs, commentaires qui contredisent le code      |
| **Correction / Exactitude** | Tests, comportement attendu, edge cases, gestion des erreurs, robustesse des workflows critiques                | Richesse fonctionnelle anormale, bugs connus non couverts, absence de tests, cas limites ignorés      |


Chacune de ces notes s’accompagne de points concrets d’amélioration.  

Avant d’entrer dans les exemples, intéressons-nous à la méthodologie de validation de ce modèle.

J’ai évalué le score de plusieurs dépôts :

* Populaires et réputés pour leur qualité
* Professionnels dont j’ai une bonne connaissance de l’historique de développement et de la maintenance
* Vibe codé et devenu inmaintenable selon leur auteur (1 seul)

Voici, par exemple, un extrait de l'évaluation d'un dépôt Go réputé pour sa qualité :

| Axe              | Note   | Commentaire |
|------------------|--------|-------------|
| **Architecture** | **9/10** | Limite de package garantie par `internal/`, environ 57 plugins d’analyse suivant une interface uniforme |
| **Performance**  | **8/10** | Package `benchmark/` dédié + profiling disponible |
| **Uniformité**   | **9/10** | `go vet` clean, layout de package uniforme, configuration `.gitattributes` + `.prettierrc` |
| **Sécurité**     | **6/10** | **Faux positif** : La vulnérabilité détectée par le modèle dans les dépendances est bien corrigée |
| **Documentation**| **9/10** | GoDoc par package, site `gopls/doc/` dédié, release notes détaillées et guides de contribution |
| **Correction**   | **8/10** | Excellente couverture de tests |


Pour l’instant, les notes et audits produits corroborent l’évaluation subjective et permettent d’affiner le modèle.
Un dépôt en particulier s’est révélé instructif.

## Derrière chaque note des critères concrets

Le modèle recense pour chaque axe des points de contrôle qui permettent de faire un retour détaillé pour comprendre les problématiques et améliorer le code.

Voici un extrait de la section architecture :

```
## Issues

- **High** `internal/api/server.go:105-114` — Cyclic dependency resolved via post-construction setters. Indicates a circular import at the domain level that should be resolved by extracting an event bus, a shared interface package, or merging closely-coupled domains.
- **High** `internal/authorization/gorm_pg_repository.go` (8,235 lines) — Repository file absorbs HTTP client calls to SAP (line 6991) and the absences API (via `utils.go`), email sending (via `misc.go`), and cache management. Repository layer should only mediate data access; side-effects belong in the service layer.
- **Medium** `internal/config` vs `internal/configuration` — confusingly similar package names for distinct domains (runtime config table vs. entity catalog). Rename to reduce cognitive load.
- **Medium** `internal/utils/misc/misc.go` — Lacks a single responsibility. Split into `internal/utils/httpclient`, `internal/utils/mail`, and keep only pure helpers in `misc`.
- **Low** `internal/api/server.go:46-48` — OTel endpoint, service name, and insecure flag hardcoded. Move to `internal/utils/config`.

## Strengths

- Clean `cmd/api/main.go` entry point: wires the router, DB, logger, and exits on error.
- Repository interfaces defined separately from implementations, enabling testability via mockery-generated mocks.
- `internal/models/` is dependency-free (imports only stdlib), consistent with the dependency-inversion principle.
- Pagination concern isolated behind `webstradev/gin-pagination` and applied uniformly at route level.
- OpenTelemetry setup present and wired, even if config is hardcoded.
```

## Cas concret : autopsie d’une app "vibe codée".

Le cas le plus instructif m’a été transmis par son propre auteur : une application riche en fonctionnalités, fonctionnelle, mais devenue très difficile à modifier.

C’est exactement le type de dépôt que je cherchais à évaluer : non pas un code cassé, mais un code qui fonctionne tout en accumulant une dette difficile à voir au premier regard.

Le modèle retourne actuellement pour cette application l'évaluation suivante :

| Axe              | Note   | Commentaire |
|------------------|--------|-------------|
| **Architecture** | **6/10** | Bonne modularité, mais god fonction de 1500 lignes |
| **Performance**  | **5/10** | Algorithmique basique, sous-exploitation du contexte |
| **Uniformité**   | **5/10** | Développement par couche sans specs |
| **Sécurité**     | **2/10** | `.env` avec secret Stripe versionné (critique) |
| **Documentation**| **7/10** | Bonne mais absence de specs + détection incomplète des erreurs |
| **Correction**   | **3/10** | Race condition, path traversal et plusieurs bugs |

Ce qui est intéressant ici, plus que les notes qui ne sont que des indicateurs relatifs permettant de comparer, c’est bien sûr l’ensemble des points remontés pour améliorer l’application et le fait que l’audit reflète assez fidèlement les appréciations subjectives de l’auteur (sur la correction notamment) et les miennes (sur l’architecture, la sécurité et la performance).

## Un modèle vivant, loin d'être figé.

Sans surprise, les rapports produits sont généralement très proches de mon évaluation subjective, tout en étant plus exhaustifs et uniformes que ce que je peux produire. Mais il arrive encore assez souvent que des points, comme un couplage fort, qui me sautent aux yeux, manquent dans l’évaluation : l’importance de ce point, la manière de le caractériser et sa valeur pondérale doivent alors être caractérisés.

Mais les axes eux-mêmes sont encore en cours de réflexion : la maintenance est par exemple actuellement fonction de l’Architecture, de la documentation et de l’uniformité. Mais peut-être qu’elle mériterait un axe propre.

Même chose pour la testabilité : un code peut avoir une excellente architecture et une bonne documentation, tout en restant difficilement testable.
Doit-on lui dédier un axe ? L’inclure dans la maintenabilité ?

Outre l’analyse statique du code, l’analyse de la dynamique du code (analyse des commits) reste aussi à finaliser.

Ce modèle n’est pas encore finalisé. Il a vocation à être confronté à des dépôts réels, corrigé par les cas limites, et rendu progressivement plus robuste.

## Conclusion

 Après trois décennies à écrire et maintenir du code, il est fascinant (et un brin frustrant) de constater que notre standard industriel reste : "Un développeur senior regarde le dépôt et sent que quelque chose cloche."

Certes, la complexité exponentielle de notre écosystème rend toute tentative de mesure universelle quasi sisyphéenne. Mais ne rien mesurer, c'est accepter que le code devienne une boîte noire. Je refuse cette fatalité.

Votre projet fonctionne, mais personne n'ose plus y toucher ? C'est le moment de lever le doute. Envoyez-moi votre dépôt : je réaliserai un audit gratuit selon ces 6 axes. Votre code m’aidera à tester le modèle sur du réel et vous repartirez avec une liste concrète de risques et d’améliorations.


[^1]: Les modèles et référentiels existants ne mesurent pas tous la même chose : DORA vise la performance de delivery, CMMI la maturité du processus, CVSS la sévérité des vulnérabilités, tandis que SQuaRE, CISQ, McCall ou FURPS+ proposent des grilles plus directement liées à la qualité logicielle.

[^2]: La notation est assistée par un LLM piloté par un ensemble de règles métier, d'agents spécialisés et de templates d'audit. Le barème évolutif et l'usage d'un modèle pose un problème de reproductibilité très similaire à la situation de deux auditeurs ISO qui peuvent ne pas donner la même note. L'important n'est pas la note absolue, mais l'ensemble des points d'amélioration remontés. La grille détaillée sera fournie avec les notes une fois le modèle stabilisé.
