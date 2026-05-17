+++
title = "Compresser le temps pour compresser les logs"
type = "post"
date = '2026-05-16T01:38:37+01:00'
categories = ["Article"]
tags = ["metarc", "metacompression"]
translationKey = "compressing_time"
+++

Ce matin, je me suis amusé à compresser le temps.

Mais avant que vous m'imaginiez en génie de la physique théorique ou en hurluberlu ayant besoin d'une camisole de force, laissez-moi vous expliquer.

Je travaille actuellement sur [Metarc](https://github.com/arhuman/metarc-go), un outil de *metacompression* (comprendre : appliquer des transformations intelligentes à certaines structures avant de passer le relais à un compresseur classique comme `zstd`). Si vous n'avez jamais entendu ce terme, vous allez comprendre en 5 minutes. Si vous êtes expert en compression ; accrochez-vous, vous trouverez peut-être matière à débat.

Les dates sont un excellent terrain de jeu pour comprendre cette idée : elles ressemblent à du texte, mais elles contiennent en réalité une structure très dense qu'on peut exploiter.

Spoiler : En exploitant cette structure, `Metarc` peut afficher des gains de compression atteignant 26,5% par rapport à `tar+zstd`.

## Ce que les compresseurs généralistes ne voient pas dans les dates

L'objet de mon exploration ce matin était donc la compression des dates et du temps.

Plus précisément j'essayais de réduire la place prise dans un fichier de texte par une date telle que : 

`2026-05-11 10:36:19` (19 octets de texte) sous une forme plus compacte.

Les compresseurs généralistes travaillent au niveau du flux d’octets. Pour eux, `2026-05-11 10:36:19` n’est pas fondamentalement une date : c’est une suite de caractères.

Ils peuvent exploiter les répétitions de motifs, mais pas le fait que cette chaîne représente un instant précis, avec une structure connue : année, mois, jour, heure, minute, seconde.

Cette différence de regard change tout. Là où un compresseur généraliste voit une chaîne de caractères, `Metarc` peut reconnaître une structure : un instant, un format, parfois un fuseau horaire, parfois une précision en millisecondes ou nanosecondes.

Mais pour le prouver, il me fallait donc un jeu de test réaliste…

## Les fichiers de log comme terrain d'expérimentation

Pour tester cette idée, les fichiers de log étaient le terrain évident. Ils contiennent beaucoup de dates, dans des formats variés, avec une contrainte très concrète : il faut pouvoir restituer exactement le texte d’origine.

> Que les puristes me pardonnent l'anglicisme *log*, mais fichier de journalisation est bien trop long pour un article parlant de compression ;-)

Dès lors, compresser efficacement une date tout en conservant assez d’informations pour la restituer dans son format textuel original, impose trois contraintes :
1) Limiter la complexité de la détection/compression.
2) Minimiser la taille des métadonnées de format.
3) Comprimer en priorité les formats les plus fréquents.

Le dernier point est crucial : plus je supporte de formats, plus je dois stocker d’informations pour les distinguer. Jusqu'à 256 formats, un octet suffit. Au-delà, il en faut deux. L'arbitrage taille/variété est permanent.

En cherchant les formats les plus courants sur mon laptop (RFC 3339, ISO 8601, MacOS), j'ai vite compris que les normes cachaient une forêt de variantes. Ma liste s'est rapidement transformée en un inventaire à la Prévert :

* ISO 8601 avec nanosecondes UTC
* ISO 8601 UTC
* ISO 8601 avec offset
* RFC 3339 avec nanosecondes et offset
* ...

Pour valider le principe, nul besoin d'être exhaustif, un sous-ensemble réduit suffisamment répandu devait permettre une compression sur la plupart des cas rencontrés.

À partir de là, la transformation appliquée par `Metarc` peut se comprendre en trois étapes.

## Étape 1 — Réduire l’instant : du texte au timestamp

Un moment daté est un point sur une ligne du temps. Si l’on choisit une origine, en informatique, souvent le 1er janvier 1970, il peut être représenté par une simple distance à cette origine.

Ainsi, la date 2026-05-11 10:36:19 à Paris (heure d'été) se situe exactement à 1778488579 secondes du 1er janvier 1970. En informatique, cet instant peut être représenté par un timestamp Unix.

`Metarc` encode l’instant sous forme numérique fixe sur 8 octets, avec une granularité suffisante pour les formats de logs modernes visés. Avec 8 octets le gain est spectaculaire : nous transformons une chaîne textuelle de 19 octets en un bloc numérique fixe de 8 octets, et ce, même si la date n'apparaît qu'une seule fois dans le fichier.

Cela a deux conséquences importantes pour la *metacompression* :
1) Une partie du gain vient de la compréhension de la structure, pas seulement de la répétition.
2) Contrairement à une compression statistique classique, une date unique peut déjà être réduite efficacement.

## Étape 2 — Restituer exactement : le problème du format

À ce stade, on n'a résolu que la moitié du problème. Car l'instant peut être représenté sous une multitude de formats.

Selon le contexte, la même date peut s’écrire de dizaines de manières :

* 2026-05-11 10:36:19
* Mon May 11 10:36:19 2026
* 11/May/2026:10:36:19
* 2026/05/11T10:36:19Z
* ...

Sans compter les fuseaux horaires, les millisecondes ou les nanosecondes.

En réalité le nombre de formats possibles est quasiment infini. Pour restituer la date à l’identique, je dois donc stocker à la fois le timestamp **et** suffisamment d’informations sur le format.

Le compromis est donc permanent : détecter/encoder vite, stocker peu et rester plus compact que la date originale.

Les premières versions marchaient bien… mais pas toujours mieux que zstd seul. Ce constat m’a forcé à creuser.

## Étape 3 — Aider zstd : ordonner les octets selon leur entropie

Une fois le timestamp et le format encodés, un problème demeurait dans la structure du format compressé : l’ordre des octets.

```
[0x00][fmt_byte][uint64 timestamp][int16 tz_min][uint8 subsec_digits]
\__ Faible __/   \___ FORTE ___/   \__________ Faible _____________/
```

En réorganisant le format pour regrouper la faible entropie[^1] au début, on crée une chaîne répétitive beaucoup plus longue que `zstd` peut mieux compresser :

```
[0x00][fmt_byte][int16 tz_min][uint8 subsec_digits][uint64 timestamp]
\___________________ Faible _____________________/  \___ FORTE ___/
```

**La metacompression agit ici doublement : En compressant la date et en optimisant l'ordonnancement des octets pour une compression ultérieure par `zstd`. C'est la connaissance de la structure (ce qui change beaucoup et ce qui change peu) qui permet ce double gain.**

Les premiers tests ont confirmé que cette simple modification améliorait la compression finale par `zstd`.

Le principe étant validé, il ne me restait plus qu'à optimiser la *metacompression*, en augmentant le nombre de formats reconnus et en essayant de réduire la taille des informations de format.

La réduction de la taille des informations de formats relève plus de l'optimisation : 
Pour certaines variantes stocker une timezone ne sert à rien et plutôt que d'utiliser le format générique `[0x00][fmt_byte][int16 tz_min][uint8 subsec_digits][uint64 timestamp]`, `[0x00][fmt_byte][uint64 timestamp]` suffit, faisant gagner 3 octets par date.

J'ai aussi étendu l'idée aux délimiteurs (', "), avec deux caractères supplémentaires encodés sans coût, même sur une date unique, et sans pénalité pour `zstd`.

## Résultats : jusqu’à 26,5% de gain sur Loghub

Pour mes tests, j'ai utilisé un corpus qui contient des fichiers de log réels produits par des logiciels standards : [loghub](https://github.com/logpai/loghub/tree/dd61d0952749ee7963bde24220d1be5ede023033).

Sur ce corpus Loghub, avec les formats actuellement reconnus par `log-date-subst/v2`, `Metarc` gagne jusqu’à 26,5% par rapport à `tar+zstd`. Sur les formats non reconnus, le gain est logiquement de 0%.

Voici les résultats après compression par `tar+zstd` (`tar --zstd -cvf xxx.tar.zstd xxx`) et Metarc (`marc archive xxx.marc xxx`).

> [!NOTE]
> Metarc archive les fichiers en appliquant des transformations de metacompression puis compresse avec zstd par défaut, c'est pourquoi les comparaisons se font avec tar + zstd.


| Dataset | Taille répertoire | Taille tar+zstd | Taille Metarc | Bénéfice Metacompression |
|---|---:|---:|---:|---:|
| Mac | 844K | 136K | 100K | 26.5% |
| OpenStack | 1.3M | 136K | 104K | 23.5% |  
| BGL | 776K | 136K | 116K | 14.7% |
| HDFS | 708K | 136K | 112K | 17.6% |
| Spark | 500K | 36K | 32K | 11.1% |
| OpenSSH | 580K | 40K | 36K | 10.0% |
| HealthApp | 472K | 44K | 40K | 9.1% |
| Android | 736K | 52K | 48K | 7.7% |
| Zookeeper | 648K | 52K | 48K | 7.7% |
| Apache | 432K | 28K | 28K | 0.0% |
| Hadoop | 920K | 44K | 44K | 0.0% |
| HPC | 372K | 56K | 56K | 0.0% |
| Linux | 548K | 36K | 36K | 0.0% |
| Proxifier | 592K | 52K | 52K | 0.0% |
| Thunderbird | 768K | 64K | 64K | 0.0% |
| Windows | 684K | 32K | 32K | 0.0% |

**Pour les formats reconnus** le gain en taille apporté par la metacompression est de **14% en moyenne.**

On peut vérifier le détail du gain par archive avec le flag `--explain`.

```
time marc archive --explain mac.marc Mac

--- Plan Summary ---
Total entries:      4
Transforms applied: 1
Estimated gain:     104.0 KB

Breakdown by transform:
  log-date-subst/v2        1 applied      0 skipped  ~104.0 KB saved
  raw                      0 applied      3 skipped  ~0 B saved

marc archive --explain mac.marc Mac  0.10s user 0.01s system 99% cpu 0.111 total
```

## (Tout) Ce qui reste à améliorer

Implémenter plus de formats sans dégrader les performances reste un axe évident d'amélioration.

Ajouter un format peut parfois se résumer à encoder une variante simple, comme le séparateur de date (/ ou -). Mais le plus souvent, cela nécessite de détecter un nouveau motif dans un nouveau jeu de fichiers de log. Le vrai travail consiste donc à élargir la couverture sans faire exploser le coût de détection.

Mais il reste encore aussi de nombreuses optimisations à implémenter et de nouveaux gains à trouver.

Je vais par exemple probablement fragmenter les formats de stockage compressés pour optimiser chaque format : inutile par exemple de conserver des timestamps au format uint64 pour des formats ne nécessitant pas de nanosecondes.

## La quintessence de la metacompression

Le véritable résultat de cette exploration n'est pas, pour moi, le gain de compression obtenu de 14% en moyenne.

L'intérêt de la compression des dates est qu'elle illustre la *metacompression* dans sa forme la plus complète : **Une compression en amont qui va s'ajouter et optimiser la compression du flux d'octets en aval**.

C’était le pari de `Metarc` : compresser la structure avant de compresser les octets. 

La prochaine étape ne se jouera pas sur un exemple choisi, mais sur vos données réelles : dépôts de code, logs, archives techniques, corpus hétérogènes.
C’est comme cela qu’une intuition devient un outil.

Essayez `Metarc`, comparez-le à `tar+zstd`, et [partagez vos résultats](https://github.com/arhuman/metarc-go/issues/new?template=feedback.md).

Et si vous aimez le concept de la métacompression et voulez donner de la visibilité au projet, ajoutez une ⭐️ à [Metarc](https://github.com/arhuman/metarc-go) sur GitHub. 


[^1]: La théorie de l'information de Shannon établit que les données à faible entropie (répétitives, structurées) peuvent être fortement compressées à la différence des données à haute entropie (changeantes, aléatoires...)
