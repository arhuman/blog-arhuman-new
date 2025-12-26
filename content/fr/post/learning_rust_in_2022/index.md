+++
title = "Apprendre Rust en 2022"
categories = ["Article"]
tags = ["Rust"]
type = "post"
date = "2022-07-22"
featured ="rust-logo-256x256-blk.png"
draft = false
+++

# Apprendre Rust en 2022

Si vous suivez mes blogs/podcasts vous savez déjà que je suis un fan du langage Go, aprés avoir été pendant plusieurs années un utilisateur passionné de Perl.

Ce que vous ignorez peut-être c'est que j'ai utilisé ou continue à utiliser de nombreux autres langages, et que je continue régulièrement  à apprendre de nouveaux langages.

Ces 10 dernières années j'ai un peu changé ma façon de faire : pour m'immerger complètement dans le langage que j'apprend, j'essaie pendant un an de réaliser **tous** mes nouveaux projets dans ce langage. Ce n'est pas forcément le meilleur choix d'un point de vue pratique (un outil ligne de commande en Javascript peut être un peu *lourd* à déployer par exemple) mais ça me permet de m'impliquer à fond dans l'apprentissage d'un langage.

Il se trouve que cette année, j'apprends le Rust.

## Pourquoi Rust ?

Fatalement quand on fait du Go on est amené à entendre parler de Rust :

* Parce que la presse à tendance à les présenter tous les deux comme des langages de la dernière génération pour les projets industriels
* Parce que leur performance en font des alternatives au C/C++
* Parce que leur communauté loin d'être antogoniste sait reconnaitre chez l'autre les points d'excellence
* Parce que je voulais explorer une autre manière de gérer la mémoire d'une manière sure (même si le garbage collecteur du Go est ultra performant)

C'est surtout ces deux derniers points qui m'ont décidé à apprendre Rust.
Les critiques posititives des core développeurs Go envers le projet Rust[^1], m'intriguaient et j'avais envie de voir à quoi ressemblait ce système de paquet, et la gestion de la mémoire qu'ils citaient en exemple 

## L'installation de Rust

Difficile de faire plus simple :

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Ceci étant fait, `rustup` permettra de gérer les versions de rust utilisées via 3 canaux (channels) : stable, beta, nightly

Par défaut rustup utilise le canal stable, pour installer un autre canal comme la nightlly il suffit de faire : `rustup toolchain install nightly`

Pour utiliser le canal nightly par defaut : `rustup default nightly`

Pour changer de canal et revenir vers le canal stable on peut réutiliser `rustup default stable` ou localament `rustup override set stable`

Pour mettre à jour un canal : `rustup update`

et `cargo` d'effectuer toutes les taches de gestion de dépendances, compilation, exécution, vérification et formattage du code.

Pour initier un projet : `cargo new`

Pour compiler une version optimisée : `cargo build --release`

Pour exécuter : `cargo run`

Pour ajouter une dépendance (à partir de la version 1.62) : `cargo add`

Pour formatter le code : `cargo fmt`

Pour linter le code (idiomes, usages...) : `cargo clippy`

On le voit, c'est assez standard avec, me semble-t-il, une certaine uniformité/standardisation (comparé à javascript par exemple)

## Premières impressions

Après quelques mois de lecture, et quelques semaines de programmation en dilletante, je ne peux prétendre à une connaissance/compréhension du langage, mais je peux néanmoins donner les premières impressions d'un débutant.

### Le compilateur Rust

Maverick a Iceman, Batman a Robin, le programmeur Rust à rustcc.

Pour m'être battu avec les messages d'erreur cryptiques de plusieurs langages (dont ceux de l'interpréteur Perl) je ne pouvais imaginer à quel point on pouvait être amené à apprécier les messages d'erreur d'un compilateur. Je l'avais lu plusieurs fois, mais il m'a fallu écrire mes premiers programmes en Rust pour comprendre le plaisir qu'il y a à l'utiliser. Car le compilateur Rust ne se contente pas de signaler les erreurs : Il détecte les problèmes qui pourraient survenir, et suggère souvent une correction idiomatique et un lien pour une explication détaillée.

C'est comme si on avait un mentor qui nous expliquait nos erreurs en nous indiquant la meilleur manière de les corriger.
Passé les premières frustations (parce que pour ma part mes premières versions sont toujours loin d'être idiomatiques) on en arrive à se caler dans un vrai cycle d'essai/apprentissage guidé, bien plus efficace que les tatonnements que j'ai pu avoir avec d'autres langages.

### Le tooling

Ce n'est pas propre à Rust, mais le tooling est vraiment d'excellente qualité. Pas meilleur que celui du Go, mais aussi bon et c'est déjà assez exceptionnel pour le signaler.
J'émettrai juste un bémol sur le temps de compilation, qui même s'il est très bon, est loin derrière celui du Go.

### Performances

Il n'y a pas photo, la vitesse d'exécution est une des meilleurs que j'ai pu obtenir, et mis à part le C/C++ je ne connais pas beaucoup de langage de premier plan capable de faire mieux.
Après je ne sais pas si c'est du à mon manque de connaissance et/ou à une mauvaise utilisation, mais j'ai été surpris par la taille des binaires que j'imaginais beaucoup plus petite (pas de garbage collector...)

### Concurrence

La grosse surprise pour moi a été la relative complexité de la gestion de la concurrence en Rust. Pour un débutant, la gestion des threads, de l'asynchronisme et des channels n'est pas évidente :

* Les multiples "moteurs" d'asynchronisme (tokio, async_std, smol) ne sont pas intégrés au langage, ont une sémantique différente et sont d'un usage parfois obscur
* La gestion des threads me donne l'impression de revenir dans les années 90.
* La gestion de la mémoire complique l'utilisation des channels

C'est bien sur relatif et à mettre dans le contexte de quelqu'un qui a connu la béatitude de la gestion de la concurrence en Go. ;-)

### Learning curve

Sur ce point, je ne peux pas dire que je n'avais pas été prévenu, mais c'est un fait : Rust n'est pas un langage qu'on apprivoise rapidement.

Il faut du temps pour s'habituer et **intégrer** les règles de la gestion de la mémoire et les contraintes qui en découlent.

Et même si la gestion des paquets, les macros, les traits, les temps de vie, les génériques sont plus simples. Ils ont quand même assez de spécificités pour requérir un peu de temps avant de *tout* maitriser.

## Pour apprendre

Même si Rust n'est pas le plus facile des langages à apprendre, il existe bien assez de ressources pour faciliter la tache de l'apprenti rustacean (le nom des programmeurs Rust)

Il y a le classique 'tour' en ligne:

* [Tour of Rust](https://tourofrust.com/)

Il y a des livres :

* [The Rust Programming Language](https://doc.rust-lang.org/book/)
* [Easy Rust](https://dhghomon.github.io/easy_rust/)
* [Rust by example](https://doc.rust-lang.org/rust-by-example/)
* [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/)

Il y a des exercices :

* [Rustlings](https://github.com/rust-lang/rustlings)
* [Exercism](https://exercism.org/tracks/rust)

Il y a des podcasts :

* [New Rustacean](https://newrustacean.com/)
* [Rustacean Station](https://rustacean-station.org/)

Et enfin des communautés en ligne :

* [Sur Reddit](https://www.reddit.com/r/rust/)
* [sur slack](https://rust-slack.herokuapp.com/)
* [Sur Discord](https://discord.gg/rust-lang-community)

Ce n'est bien sur qu'une petite fraction des resssources disponibles, n'hésitez pas à partager avec moi (par mail) vos liens favoris.

##  Conclusion

Je ne suis qu'au tout début de mon voyage d'apprentissage de Rust, mais plus j'avance et plus j'ai envie de continuer ce qui est pluutôt bon signe.

Les prochaines étapes ?

Continuer à lire et apprendre (les macros!) et mettre plus en pratique en participant à des projets comme [Massa](https://github.com/massalabs/massa) ou Carman (projet perso, lien pas encore disponible ;-) )
Et probablement aussi de nouveaux articles de blog sur le sujet...


[^1]: https://dave.cheney.net/2015/07/02/why-go-and-rust-are-not-competitors
