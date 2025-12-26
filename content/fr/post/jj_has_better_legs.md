+++
author = ""
categories = [""]
date = ""
description = ""
featured = ""
featuredalt = ""
featuredpath = ""
linktitle = ""
title = ""
type = "post"
draft = true

+++

En xxx l'article XXX expliquait pourquoi selon lui git allait s'imposer en tant que gestionnaire de sources.
L'histoire prouva la justesse des ses arguments et actuellement git est LE gestionnaire de sources utilise partout, et rares sont ceux qui se souviennent de Mercurial, Dark, SVK, ou subversion.
Git s'est revele tellement efficace dans son role, que peu d'entre nous se posent la question d'une autre solution.
Heureusement, certains ne renoncent jamais a explorer de nouvelles voies pour essayer d'ameliorer les choses.
C'est grace a ces personnes que nous avons maintenant jujutsu (jj pour les intimes)

J'avoue que quand j'ai decouvert pour la premiere fois (completement par hasard) jujutsu et sa promesse existentielle "Faire tout se que fait git mais plus simplement" j'etais assez dubitatif. Dans mon esprit s'est forme une premiere objection: "comment jujutsu pourait faire aussi bien que git plus simplement".
  "There's no such thing as a free lunch" disent nos amis anglo-saxons, et l'informatique n'est qu'une histoire de compromis espace/vitesse, puissance/simplicite, difficile a croire a un outil qui promet le beurre et l'argent du beurre, et pourtant.

L'argument de la simplicite annoncee introduit ma seconde objection:
La pretendue complexite de git, n'est elle pas qu'une meconnaissance du fonctionnement et des structure internes de git.
Nombre d'expert git repetent a loisir que git n'est pas complique quand on le comprend et qu'on l'utilise correctement.
Ne vaudrait-il pas mieux apprendre plus a fond le fontionnement de git, plutot que le fonctionnement d'un autre outil?

J'y ai bien reflechi, et je pense que si la maitrise de git efface une bonne partie de la complexite, il reste une complexite structurelle :
Au debut je pensait que c'est le nombre de concepts dans l'architecture de git (index, reflog, commit, working copy, branche, stash...) et le manque d'uniformite sur les commandes rendait intresequement git plus complexe qu'un outil qui a deliberement choisit de reduire le nombre de ces concepts (exit l'index dans jujutsu, et plus besoin de stash au passage) et qui offre une interface simplifiee et unifiee sur ses commandes.
Mais en creusant, c'est plus subtile que ca, c'est la separation claire des responsabilites qui concourt le plus a la simplicite de jujutsu: 
La separation changeset/commit rend les operations plus simples, et moins dangereuses. 
Branche (bookmarks) / Changeset / Working copy adresses distinctement a la difference de git qui melange allegrement tout ca avec HEAD par exemple.
Le nombre d'operations elementaires necessaires pour faire certaines operations fonctionnelles (annulation, correction de commits) est aussi un indicateur de complexite pour moi, une operation fonctionnelle devrait idealement ne demander qu'une operation git, et ce n'est pas toujours le cas. 
Cette complexite structurelle de git est incompressible, et depasse selon moi la complexite d'apprentissage de jujutsu.

Ce qui nous ramene a la premiere objection : Comment jujutsu pourrait faire aussi bien que git plus simplement.

Pour repondre a cette question, j'ai choisi de l'experimenter dans une situation la plus proche possible de mon utilisation git:

Dans le cadre de mon travail, je manipule des depots gits clones de github, je fais des modifications locales en utilisant des branches de travails le plus souvent (directement sur master/develop pour certains repos, ou operations telles que des commits de tagging/build.)
Premier constat, jj permet de faire cela tres facilement en s'appuyant sur l'infra git, et ne necessite aucun travail "double".

```
jj git init --colocate
```

cree le repertoire .jj

a partir de la, je n'utilise plus que des commandes jj, pour faire mes operations.

Voyons si c'est vraiment plus simple.

## Premiere constation plus d'index

Jujutsu n'utilise pas d'index, chaque working directory est un changeset (l'equivalent d'un commit, mais plus facilement modifiable TODO:check terminology)
Passe le petit moment de panique ou je realise que TOUT ce qui est dans le repo, sera commite alors que j'ai tendance a remplir mon working directory de fichiers locaux qui ne sont pas destines a etre versionnes (resultat de commandes, doc temporaire...)
Ce choix de jujutsu va vite se reveler utile:
apres avoir mis a jour mon .gitignore et creer un repertoire pour mes documents locaux a ne pas versionnes, je me suis retrouve avec un repertoire plus propre, moins de risque de commiter par erreur via un glob un fichier a ne pas versionner et en bonus la gain de ne plus jamais avoir a faire de git add

Le veritable gain de cette simplication sera toutefois vraiment visble dans ma navigation entre les changeset (TODO: terminology)

## Deuxieme constation les commandes sont simples

Les commandes de base sont identiques aux commandes git, je suis immediatement operationnel avec des commandes comme

```
jj log 		            # Pour obtenir mon historique
jj commit -m "commit msg"   # Pour commiter mon travail
jj status"                  # Pour savoir quelles modifications sont en cours
```

Mais rapidement je me rends compte que jj me simplifie a vie

la commande ```jj`` sans rien est equivalent a une des commandes que j'utilise le plus ```jj log```
la commande ```jj commit``` est en fait un alias pour 2 commandes ```jj new``` et ```jj desc``` qui offrent des possibilites de simplifier ma facon de travailler.la commande ```jj status``` peut se simplifier comme la plupart des commandes jj, en ```jj st```


la simplifaction de 'status' en 'st' peut vous sembler anecdotique, mais ce n'est pas que la reduction du nombre de caracteres a tapper pour une commandes.
C'est revelateur d'un parti pris de jj de systematiquement vous faciliter la vie si c'est possible et que le cout est nul.
Prenons la commande ```jj``` evoquee plus haut, outre le fait qu'elle affiche la commande la plus courrament utilisee (log) l'affichage lui meme est interressant:

[](image jj)

mais on retrouve ce souci de facilitation meme dans l'affichage, ou la partie unique du changeID, tout comme le commit ID est clairement visble pour permettre une reference plus rapide. Car si git permet de referencer des commit par une partie de leur commit ID, il n'offre pas a la difference de jj visuellement la partie minimale discriminante permettant de referencer un commit.

a la lecture de ce jj (log) il est facile de faire ```jj edit l``` pour editer le premier changeset.


## Pour creuser

### oplog

### revset
