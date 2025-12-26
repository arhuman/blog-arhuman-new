+++
title = "Installer Hugo"
categories = ["Article"]
tags = ["Hugo"]
type = "post"
date = "2019-07-28"
+++

# Hugo

Cette semaine, sur les bons conseils de mes amis de la [frenchgo](https://frenchgo.fr), j'installe Hugo pour héberger mon blog.

## Objectif

J'ai déjà un blog sur Blogger depuis 2007, et un sur Medium depuis 2016 alors pourquoi vouloir héberger mon blog ?

Je quitte Medium car l'idée de devoir payer pour consulter des articles sur un site sur lequel je publie du contenu m'est devenu insupportable. Le choix de cette plateforme m'avait plus ou moins été imposé par un éditeur, même si je dois l'avouer la visibilité procurée a été un critère pour rester dans un premier temps. Mais, n'ayant plus d'articles à produire pour cet éditeur je suis désormais libre de choisir ma plateforme, et je ne vais certainement pas rester sur Medium.

Mais pourquoi ne pas simplement continuer à utiliser blogger ? Parce qu'il est temps de se désengager des produits Google, parce que la gestion de la coloration syntaxique sous blogger est (vraiment) pénible, parce que j'ai les ressources pour héberger ce blog et parce que l'autohébergement m'offre à la fois plus de liberté technique et la possibilité d'apprendre...


## Pourquoi Hugo ?

Avec tous les moteurs de blog existant pourquoi aller choisir cet obscur générateur de site statique ?
Pourquoi se priver du riche écosystème de Wordpress ou de la simplicité d'un Ghost, ou des performance de Jekyll par exemple ?

Premièrement, ce n'est pas un secret, j'aime le langage Go (Golang) et l'idée de pouvoir modifier mon outil est un plus.
Ajouté à cela avantages habituels des outils développés en Go (consommation des ressources minimale, performances, facilité de déploiement) et la solution Hugo présente beaucoup d'intérêt.
En parlant de performances [Hugo écrase Jekyll](https://forestry.io/blog/hugo-vs-jekyll-benchmark/) en terme de rapidité de génération de site.

Oui mais pourquoi Hugo, un générateur de site statique, et pas [Journey](https://github.com/kabukky/journey) qui est un moteur de blog écrit lui aussi en Go ?
Essentiellement parce que Journey n'a pas été mis à jour depuis des années alors que non seulement Hugo est un projet actif mais doté d'une communauté d'utilisateurs particulièrement vivante (et dithyrambique, ce qui est plutôt bon signe)



## Les spécificités d'Hugo ?

Un générateur de site statique en 2019 je comprends que ça puisse faire sourire et pourtant le projet affiche une vitalité étonnante. Voyons un peu les raisons de son succès.

* La sécurité - Ce n'est pas propre à Hugo, mais les générateurs de sites statiques offrent une surface d'attaque bien infèrieure à celle des sites dynamiques.
* La Performance - Encore une fois les performances sont bien meilleures que celles d'un site dynamique, tout en offrant assez de souplesse pour gérer un site évolutif comme un blog. La vitesse de génération du site est elle tout simplement un ordre de magnitude plus grande que celle de son principal concurrent.
* La simplicité - Pas besoin de base de données, le posts sont de simples fichiers markdown
* L'adéquation avec l'écosystème dévops - Comme le contenu n'est que du text, le site peut être versionné simplement même quand plusieurs personnes travaillent dessus et peut bénéficier de tous les outils associés au code, build/test/déploiement automatisés dans une chaine de CI (On pourrait parler de "Blog as a code"TM :-D) 
Clairement ce point n'est un avantage que pour les profils techniques mais c'est un avantage de poids.

Alors Hugo serait le blog idéal ?

Non pas vraiment, il suffit de m'imaginer devoir expliquer la procédure de publication à une stagiaire en marketing option storytelling : "Tu as juste à cloner le dépot git, créer un article en ligne de commande avec 'hugo new monposte.md' puis de saisir son contenu en markdown avant de relancer un build du site..." => dépression instantanée garantie...
Ensuite les spécialistes vous parleront du pipeline

Hugo c'est un excellent blog pour un codeur, et c'est déjà pas mal.



## L'installation d'Hugo

Je vous ai déjà parlé de sa simplicité ? 


Vous avez plusieurs manière d'installer Hugo mais la plus simple reste sans doute d'installer le binaire le binaire adapté à partir de la page [des releases d'Hugo](https://github.com/gohugoio/hugo/releases)

Sur ma Debian l'opération se réduit à :

```
wget https://github.com/gohugoio/hugo/releases/download/v0.56.0/hugo_0.56.0_Linux-64bit.tar.gz
tar xzvf hugo_0.56.0_Linux-64bit.tar.gz
sudo mv hugo /usr/local/bin
```

Voilà vous avez installé Hugo.
La mise en service d'un site se révèle tout aussi simple :

```
hugo new site monsite
cd monsite
git clone https://github.com/budparr/gohugo-theme-ananke.git themes/ananke && rm -rf themes/ananke/.git
echo 'theme = "ananke"' >> config.toml
hugo new posts/my-first-post.md
```

*Note : Je ne suis pas fan des submodules c'est pourquoi je préfère cloner le theme puis supprimer le répertoire .git, mais ce n'est pas l'approche recommandée par la documentation officielle (ni même une bonne pratique)*

Vous pouvez maintenant éditer le fichier content/posts/my-first-post.md

```
---
title: "My First Post"
date: 2019-07-26T08:47:11+01:00
draft: False
---

“You can always edit a bad page. You can’t edit a blank page.”
― Jodi Picoult

```

En lançant le server

```
hugo server
```

Vous pourrez vérifier le succès de votre installation.

Si vous voulez industrialiser le processus, lancer la commande

```
hugo
```

Sans argument[^1] crééra le site statique dans le répertoire `public`
[^1]: A la racine du site !

Il ne vous restera plus qu'a servir ce contenu statique, avec docker et traefik par exemple :

```
version: '2'

services:
  static-html:
    image: pierrezemb/gostatic
    expose:
      - 8043
    volumes:
      - ./public:/srv/http
    labels:
      - "traefik.frontend.headers.SSLHost=blog2.assad.fr"
      - "traefik.frontend.rule=Host:blog2.assad.fr"
      - "traefik.port=8043"
      - "traefik.enable=true"
    networks:
      - proxy
networks:
  proxy:
    external: true
```

*proxy* étant le réseau docker sur lequel mon traefik écoute sur internet.


##  Conclusion

Il y aurait beaucoup plus à écrire pour personnaliser l'installation et la rendre un peu plus "industrielle", et cela fera sans doute l'objet d'un autre post si vous êtes intéressés.
Mais vous avez déjà assez d'éléments pour choisir et utiliser Hugo si il correspond à vos besoins.
