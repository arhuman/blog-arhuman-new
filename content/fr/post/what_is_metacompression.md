+++
title = "Metacompression : comprimer la structure avant les octets"
type = "post"
date = '2026-04-24T02:38:37+01:00'
categoriee = ["Article"]
tags = ["metacompression", "go", "metarc"]
translationKey="what_is_metacompression"
+++

## Et si le vrai gain n’était pas au niveau des octets ?

J'ai toujours été fasciné par les algorithmes de compression, j'avais 15 ans quand j'ai "inventé" le Run Length Encoding (avant d'apprendre qu'il avait été découvert plus de 20 ans avant ma naissance).  
Je me suis extasié sur la simplicité "visuelle" du codage de Huffman, de l'astuce de Lempel-Ziv qui construit dynamiquement son dictionnaire.

Ces algorithmes sont puissants, et ce n'est pas un hasard s'ils sont sans cesse améliorés et encore combinés pour produire de nouveaux algorithmes encore plus puissants : `Brotli`, `zstd`. 

Mais ils partagent tous la même philosophie : les données sont un flux d'octets.

## La métacompression : comprimer avant les octets

La metacompression exploite les structures au-dessus du flux d'octets pour préparer et amplifier la compression classique.

Elle ne se limite pas au sens des données.  
Elle peut aussi travailler sur les structures, les relations entre fichiers, les motifs des lignes...  
  
C'est pourquoi le terme metacompression me semble plus adapté que "compression sémantique".

## Pourquoi cela change tout 

Travailler à un autre niveau que le flux d'octets, donne accès à un niveau d’information bien plus riche, et donc à des leviers de compression inaccessibles au simple flux d’octets

Sur certains types de répertoires avec beaucoup de redondance on observe déjà de meilleurs taux de compression que les outils standards. Ci-dessous quelques résultats utilisant [Metarc](https://github.com/arhuman/metarc-go) pour la metacompression : 

```
6.5G	mon_homedir (106442 fichiers, essentiellement des repos git)        
1.8G	mon_homedir.tar.zst  72.3% de compression
1.4G	mon_homedir.marc     78.5% de compression   <- Metacompression
```

Bien sûr mon répertoire utilisateur n'est pas forcément représentatif, mais vous pouvez, par vous-même, constater les mêmes ratios de compression sur un backup de répertoire JavaScript.  
Si vous avez 50 projets JavaScript, vous stockez 50 fois les mêmes versions de Lodash. la metacompression le voit, `tar + zstd` voit surtout une archive comme un long flux continu; il peut exploiter des répétitions proches, mais il ne conserve pas explicitement la notion de “ce fichier est le même que cet autre à tel endroit de l’arborescence”. C’est précisément cette information que la métacompression utilise.  
  
Il faut noter que sur les usages courants, les taux, sans être meilleurs, sont prometteurs à cette phase du projet. Voici une comparaison effectuée sur différents dépots github populaires utilisant différents langages[^1] :

| Repo | Original size | Files | tar+zstd | marc | **% of tar** |
|------|---------------|-------|----------|------|----------|
| kubernetes | 374M | 29254 | 81.2M | 81.5M | **100.3%** |
| docker-compose | 4.5M | 706 | 1.1M | 1.1M | **102.1%** |
| vuejs | 9.8M | 732 | 3.2M | 3.3M | **101.2%** |
| numpy | 50M | 2372 | 18.4M | 18.6M | **100.9%** |
| redis | 28M | 1784 | 8.9M | 9.0M | **100.7%** |
| bootstrap | 27M | 820 | 13.9M | 13.8M | **99.5%** |
| express | 1.6M | 242 | 345.8K | 356.1K | **103.0%** |
| react | 65M | 6888 | 18.4M | 18.4M | **100.1%** |
| prometheus | 37M | 1627 | 9.6M | 9.6M | **100.8%** |

En moyenne sur ces dépôts : `Metarc` est globalement équivalent à `tar + zstd` (entre 99 % et 103 % de la taille). 

Important : la métacompression est particulièrement efficace sur les corpus de multiples fichiers avec redondances inter-fichiers. Sur un fichier unique, déjà fortement compressé ou aléatoire, elle n'apporte pas de gain supplémentaire par rapport à `zstd` seul, et son analyse préalable peut même ajouter un léger surcoût temporel.

Pour les corpus importants et fortement redondants les méthodes de metacompression ont leur utilité.  
Voici quelques-une de ces méthodes

### La déduplication de fichiers

Deux fichiers identiques seront compressés deux fois si on ne travaille qu'au niveau du flux.  
La metacompression permet de ne les compresser qu'une seule fois et de stocker l'information qu'une copie existe quelque part dans l'arborescence des fichiers car elle a l'information sur leur caractère identique et leur nature (localisation, droits...) Les algorithmes de hash modernes comme `BLAKE3` sont particulièrement adaptés à cette tache et aux machines actuelles.

Cette méthode seule explique en grande partie le gain obtenu dans mon exemple plus haut par rapport à `tar + zstd`.

### Les fichiers presque identiques

C'est une forme de déduplication de fichier, mais quand les fichiers ne sont pas identiques mais très similaires : fichiers de licences, fichiers boilerplate...  
Dans ce cas, on va stocker un fichier compressé de référence, mais pour les fichiers presque identiques on ne stockera que le delta (l'année et le propriétaire du copyright pour une licence) sous une forme compressée. Dans ce cas l'algorithme Myers diff se révèle toujours aussi efficace pour trouver les petites différences.

### Les logs

Les logs par leur nature à la fois structurée et répétitive fournissent de nombreuses informations permettant une compression plus efficace qu'au niveau du flux d'octets.

L'ordre et la nature des champs permet d'isoler des structures compressibles fortement localement : comme les timestamps dont les formats de date sont souvent connus et limités (format ISO), les niveaux de logs qui ont une cardinalité limitée.

On peut ne stocker qu'un format de date et un timestamp, un niveau (DEBUG, INFO, WARN, ERROR...)  et un motif de texte sous une forme optimisée.

### Formats structurés

JSON, CSV, et même le code source ont des informations structurelles et redondances connues qui permettent de compresser avant le traitement au niveau du flux d'octets.  
A ce niveau on peut compresser des régularités que les octets seuls expriment mal

## Metarc : explorer cette couche oubliée

Ce ne sont là que quelques exemples d’un champ bien plus vaste

La metacompression est un domaine relativement jeune où il reste beaucoup à inventer.

C'est pourquoi j'ai écrit [Metarc](https://github.com/arhuman/metarc-go), un archiveur écrit en Go permettant une exploration pratique de la metacompression : un outil qui cherche à réduire certaines redondances avant d'appliquer et optimiser une compression standard (`zstd`)

Bien qu'il présente des taux de compression au moins équivalents, et des temps de compression/décompression plus réduits[^2], Metarc ne vise pas pour autant à remplacer les archiveurs standards.  
Il n'a pas (encore) leur robustesse, ni leur richesse fonctionnelle.

- Normalisation de formats structurés
- Extractions de motifs
- Pré-transformations pour optimiser la compression

## D’où vient cette idée ?

Le terme metacompression n’a pas toujours voulu dire la même chose.  
À une époque, on l’utilisait plutôt pour parler d’outils capables de choisir dynamiquement le meilleur algorithme de compression selon les données.

Mais l’idée que je décris ici est plus ancienne que le mot lui-même.

Bien avant qu’on parle de metacompression, certains opposaient déjà une compression purement syntaxique, qui travaille sur le flux d’octets, à une compression plus sémantique ou plus structurelle, capable d’exploiter la nature même des données.

Autrement dit, l’idée était déjà là : mieux compresser en travaillant à un niveau plus haut que celui des octets.

Pour ma part, c’est en 2016 que j’ai commencé à utiliser ce terme, à la suite d’une intuition très simple : si l’on veut mieux compresser un ensemble de fichiers, il faut parfois arrêter de les regarder comme un simple flux continu.  
 Cette intuition avait donné naissance à un article, *Improving tar with a simple idea and a few lines of JavaScript*, ainsi qu’à un proof of concept, [jntar](https://github.com/arhuman/jntar).

Je n’avais alors aucune connaissance particulière des travaux préexistants sur le sujet.  
 Le terme m’était venu naturellement, et c’est encore celui que je préfère aujourd’hui.

Pourquoi ?  
Parce que compression sémantique me paraît trop étroit. La metacompression ne travaille pas seulement sur le sens : elle peut aussi exploiter la structure, les relations entre fichiers, les répétitions, les formes, ou même des transformations purement techniques qui améliorent la compression sans relever à proprement parler de la sémantique.  
  
Metarc prolonge aujourd’hui cette intuition dans un cadre plus ambitieux : non plus comme simple proof of concept, mais comme terrain d’expérimentation concret pour explorer la compression au-delà du flux d’octets. 

## La bonne question n’est peut-être plus “comment mieux compresser les octets ?”

La compression classique a atteint un niveau impressionnant,  mais la metacompression nous permet d'atteindre un tout autre niveau en changeant de cadre.  
  
En éliminant la redondance en amont ou en transformant les données à compresser nous pouvons obtenir, sur certains corpus très redondants, de meilleurs résultats, tout en restant comparables sur les cas plus généraux.  
  
Si le sujet vous intéresse, installez Metarc, testez son efficacité sur vos répertoires, proposez vos idées de metacompression, ou partagez vos cas d’usage en commentaire. Le domaine reste largement ouvert et attend vos contributions.

[^1]: Le détail des versions, et le moyen de reproduire ces benchmarks est disponible dans la documentation du [dépôt github de Metarc](https://github.com/arhuman/metarc-go)

[^2]: La rapidité n'est pas ici une conséquence de la metacompression, mais plus de l'utilisation efficace de la concurrence que permet Go, de la simplicité architecturale du projet, et de l'utilisation d'algorithmes modernes et performants (`zstd`, `BLAKE3`...)
