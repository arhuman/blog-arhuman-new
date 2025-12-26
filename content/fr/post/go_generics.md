+++
title = "Pourquoi j'aime les generics Golang"
categories = ["News"]
tags = ["Golang", "Programming", "Generics"]
thumbnail = "img/Go_book.jpg"
type = "post"
date = "2020-07-31"
draft = false
+++

# Pourquoi j'aime les generics golang ?

Je relisais l'excellent article de ian Taylon et Robert Grisemeer ([The next step for generics](https://blog.golang.org/generics-next-step)) et je ne pouvais m'empêcher de penser que j'adorais le sens vers lequel ça allait. En fait j'aime tellement ces nouveaux generics que j'ai décidé d'écrire un article pour le dire.


Avec la publication des derniers drafts vous devriez tous avoir une idée assez précise de ce à quoi les generics ressembleront dans les prochaine versions du langage Go. Alors plutot que de refaire une énième revue technique des changements, je vais profiter des modifications pour rappeler pourquoi j'aime ces generics car il se trouve que c'est exactement pour les mêmes raisons que j'aime le langage...


## J'aime les generics car ils sont simples

Comme les paramètres de type sont des paramètres particuliers ils sont maintenant gérés comme les autres paramètres (après le nom de la fonction) mais dans une liste optionnelle distincte qui commence par le mot clef '*type*' et qui est placée avant la liste des paramètres habituels.

```go
func Process(type T)(s []T) {
	// do something with the slice of T
}
```

L'appel est lui aussi similaire à un appel standard en précisant juste le type avant la liste des paramètres

```go
Process(int)([]int{1, 2, 3})
```

Dans certains cas (quand tous les types sont utilisés pour les types des paramètres d'entrée et pas dans le corps de la fonction) le compilateur peut même déduire le type à partir du type des paramètres.

Les contraintes sur les types sont maintenant définies dans un type interface (finis les contrats). Par exemple si on veut que le type T implémente String() on peut ajouter la contrainte d'interface Stringer

```go
// Stringer is a type constraint that requires a String method.
// The String method should return a string representation of the value.
type Stringer interface {
    String() string
}

func Process(type T Stringer)(s []T) {
	// do something with the slice of T, and call String() on slice elements
}
```

Et si l'on veut mettre une contrainte sur un opérateur on peut désormais utiliser les types de bases dans un type interface en préfixant la liste des types de bases par '*type*'

```go
// Ordered is a type constraint that matches any ordered type.
// An ordered type is one that supports the <, <=, >, and >= operators.
type Ordered interface {
	type int, int8, int16, int32, int64,
		uint, uint8, uint16, uint32, uint64, uintptr,
		float32, float64,
		string
}
```

Et pour vous simplifier encore plus la vie, la nouvelle contrainte de type '*comparable*' vient gérér le cas des 2 opérateurs '==' et '!='

```go
// Index returns the index of x in s, or -1 if not found.
func Process(type T comparable)(s []T)  {
	// Now you can compare elements of slice even if they're struct or array
}
```

Difficile de faire plus simple, non ?


## J'aime les generics car j'aime l'esprit communautaire des Gophers

Mais au dela de la fonctionnalité aujoutée au langage, ce que j'aime avec les generics c'est que leur ajout s'inscrit dans une démarche **communautaire**.

Il faut se souvenir que les generics était le 3e point (avec la gestion des dépendances/version de package, et celle des erreurs) considéré le plus important à améliorer par le [sondage des utilisateurs de Go de 2016](https://blog.golang.org/survey2016-results) et celui de 2017.

Le fait que l'évolution du langage ait été initiée sur la base du retour de la communauté (plutôt que sur les choix "dictateur bénévole à a vie") est déjà chouette.

La vitesse à laquelle les fonctionnalités ont été introduite est elle aussi un indicateur intéressant  :
* Gestion des modules (introduction dans la version 1.11 en 2018)
* Gestion des erreurs (introduction dans la version 1.13 en 2019)
* Introduction des generic (prévu pour la version 1.15 fin 2020)

On voit un cycle de relase relativement rapide sans être précipité.


## J'aime les generics car j'aime la philosophie go

Enfin j'aime les generics car ils sont conforme à la philosophie de Go.
(depuis le [Go Brand Book](https://blog.golang.org/survey2016-results) de 2018 on je devrais plutôt parler de *valeurs*)

* Simplicité : On l'a vu plus haut cette version est simple (bye bye les contrats) avec peu d'ajout au langage.


* Efficacité : Tout au long des différents drafts la performance a toujours été un objectif guidant les choix et le dernier draft réussit même le tour de force de permettre de choisir entre une compilation rapide et une éxécution plus lente ou l'inverse.


* Réfléchi : Parce qu'au lieu d'implémenter une version de generics copiée d'un langage quelconque, la communauté a pris le temps d'en concevoir une qui correspond à l'esprit du langage, d'écrire des drafts, d'en discuter, d'améliorer tout ce qui pouvait l'être et de recommencer jusqu'à obtenir une version la plus conforme à l'esprit du langage sans rien sacrifier à la performance. 

## J'aime les generics parce que c'est du concret

Go étant un langage pragmatique on peut dores et déjà tester cette mouture des generics sur le [go2go  playground](https://go2goplay.golang.org/)

Mais comme j'ai tendance à être optimiste et enthousiaste, peut être que je m'emballe, alors je vous le demande : et vous que pensez vous de cette version des generics ?
