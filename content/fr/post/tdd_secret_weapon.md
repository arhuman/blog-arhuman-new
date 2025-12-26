+++
author = "Arnaud (Arhuman) ASSAD"
date = "2020-06-02"
description = ""
thumbnail = "img/ferenc-almasi-EWLHA4T-mso-unsplash.jpg"
linktitle = "L'avantage ignoré du TDD"
title = "L'avantage ignoré du TDD"
type = "post"
tags = ["TDD", "test driven development", "test", "tests", "développement"]
categories = ["Article"]
draft = false

+++

Ces derniers temps, le hasard a fait que j'ai beaucoup entendu parler de Test Driven Development.

Souvent sur le vieux thème "le TDD est mort" (https://dhh.dk/2014/tdd-is-dead-long-live-testing.html) et avec les mêmes questions qui resurgissent :

* *jQuelle est la définition des différents types de tests ?*
* *Quel est le pourcentage de couverture de code idéal ?*
* *Comment gérer les tests fragiles ? Les tests lents ?*

Et si je vais adresser rapidement ces questions aujourd'hui, c'est plus par souci de complétude que par réel intérêt.
En effet ces questions ne sont pas propres au TDD, mais communes à l'activité du test logiciel.

Pour le TDD il convient d'aborder les questions spécifiques suivantes :

* *Pourquoi écrire les tests **en premier** avant tout code ?*
* *Quel est l'apport du TDD au-delà de la technique ?*

Cette dernière question permet en effet de toucher le principal intérêt du TDD par rapport aux autres méthodologie de test.

Mais avant d'y venir, éclaircissons certains points.

## Les différents types de tests

Aucune discussion sérieuse sur le test logiciel ne fera jamais l'économie du débat autour de la définition des différents types de test : *Qu'est-ce qu'un test unitaire ? un test d'intégration ? un test fonctionnel ?*

Si la majorité s'accorde à définir les tests unitaires comme "les tests permettant de de vérifier le bon fonctionnement d'une partie précise d'un logiciel ou d'une portion d'un programme appelée unit", leur périmètre varie selon les interprétations et les contextes : *Pour vous l'unit est-elle une classe ? un module/une librairie ? une fonction ?*

Et si la définition des tests unitaires vous semble subjective, que dire des tests d'intégrations ? La "définition" la plus consensuelle des tests d'intégrations que je pourrais donner serait : les tests faisant interagir simultanément plus d'une unité de code"

Du coup ça devient simple, si ça ne touche qu'un composant c'est unitaire, si je dois tester l'interaction d'au moins 2 composants (idéalement testés unitairement en parallèle), ça devient de l'intégration. Un exemple simple serait un test faisant intervenir un composant base de données et un composant faisant du calcul.

*Et du coup le test fonctionnel ?*

Ça serait un test qui vérifie un scénario fonctionnel (par opposition à technique) de bout en bout : Tester le passage d'une commande par exemple.

On voit bien qu'il faudra dans ce cas tester plus qu'un test d'intégration qui ne fait qu’enregistrer une commande dans la base de données.

Maintenant, même si l'on est d'accord sur ces définitions, et nombreux sont ceux qui pourraient à juste titre en proposer de meilleures, ça ne sera pas forcément évident de fixer la limite entre par exemple un test fonctionnel simple et un test d'intégration complexe.

Pour ma part, j'ai pris le parti de n'attacher qu'une importance relative à ces définitions.
Peu importe le nom ou la catégorie du test que j'ai écrit pour peu qu'il fasse son travail, à savoir vérifier le fonctionnement de mon programme, de la manière la plus efficace possible.

## Quel est  pourcentage de couverture de code idéal ?

*Quel est le pourcentage de code devant être vérifié par des tests ? 100% ?*

La plupart des gens, et j'en fais partie, s'accordent à dire que ce n'est pas forcément souhaitable et que même si l'on doit tendre vers ce chiffre,  il y a un seuil ou le jeu n'en vaut probablement plus la chandelle.

*Doit-on vraiment tester tous les cas d'erreurs ?  Si je dois vraiment tester *tous* les cas d'erreur même les plus improbables, comment les provoquer/simuler ? Comment le faire sans rendre mes test fragiles ?* Et plus important *est-ce que dans cette éventualité 100% de couverture indique bien 100% des cas testés ?*

Tout le monde a sa réponse à ces questions mais laissez-moi vous rappeler quelque chose

Soit le fichier article.go

``` Go
package mylib

func Divide(a int, b int) int {
        return a / b
}
```

Et le fichier de test associé article_test.go

``` Go
package mylib

import (
        "testing"
)

func TestDivide(t *testing.T) {
        r := Divide(12, 4)
        if r != 3 {
                t.Errorf("Expected 3 got %d", r)
        }
}
```

Il est facile de vérifier que la couverture du code est de 100%

```
$ go test -cover
PASS
coverage: 100.0% of statements
ok   _/home/arnaud/article.go 0.001s

```
Mais avons-nous testé 100% des cas ?

Evidemment non. Il n'aura échappé à personne qu'un appel de notre fonction avec le second argument à 0 produira un comportement visiblement pas anticipé.

C'est pourquoi le pourcentage de couverture ne doit pas être autre chose qu'un indicateur, surement pas un but ni même une garantie.

Pour être honnête, je ne l'utilise que comme une métrique pour mesurer l'évolution de la couverture mais c'est sur la base d'un sentiment beaucoup plus subjectif de "qualité" de la suite de tests que je décide de la complétude ou pas de ma suite de tests.

## Comment gérer les test fragiles ? La lenteur des tests ?

Si vous avez écrit/exécuté un nombre conséquent de tests, vous êtes forcément tombé sur un test fragile, un test qui semble donner un résultat irrégulier.  Que ce soit lié à une race condition, une latence réseau, une dépendance non identifiée, ce test peut parfois renvoyer un résultat erroné sans raison pour fonctionner parfaitement la plupart du temps.

Vous avez aussi probablement déjà pesté contre le temps perdu à les exécuter (sauf ces 2 là  https://www.xkcd.com/303/)

J'ai tendance à adresser ces 2 problèmes pourtant très différent de la même manière car ils ont au final le même effet : ils réduisent l'attractivité de ma suite de tests (l'un en entamant la confiance que j'ai en elle, l'autre en rendant son usage plus désagréable)

Pour que ma suite de tests reste ma meilleure alliée, elle doit être fiable et rapide pour que n'hésite pas une seconde à l'utiliser le plus souvent possible pour m'assurer que la qualité de mon code ne s'est pas dégradée.

Du coup plutôt que de renoncer aux tests lents ou fragiles, je coupe la poire en deux, je les déporte dans une partie de ma suite de test qui n'est pas lancée systématiquement (uniquement quand je positionne une certaine variable d'environnement) mais que je peux lancer quand je veux faire des tests plus lents ou plus exhaustifs mais potentiellement moins fiables.

Cela ne m’empêche pas de travailler aussi à les améliorer, en les rendant plus rapides et/ou moins fragile[^1], mais le pragmatisme me pousse à mettre mes efforts à l'endroit où les bénéfices seront les plus importants et dans cette perspective les tests lents/fragiles sont rarement des priorités.
[^1]: Une approche générique horrible, mais terriblement efficace pour certains tests fragiles, est de les exécuter plusieurs fois et de prendre le résultat "statistique"

## Pourquoi écrire les tests *avant le code* ?

La première loi du TDD est "Vous devez écrire un test qui échoue avant de pouvoir écrire le code de correspondant"

*Quel intérêt ? Vous forcer à écrire un test pour chaque portion de code ?*

Oui évidemment, avec à terme l'idée de disposer d'assez de tests pour vous permettre de refactorer votre code avec un filet de sécurité, vous signalant les régressions/introductions de bug.

C'est d'ailleurs pour ça que j'ai commencé le TDD, cette assurance de voir la qualité de mon code s'améliorer est une promesse que j'ai pu vérifier rapidement. Mais indirectement, devoir écrire le test avant le code, nous force à écrire du code testable avec tous les bénéfices qui en découlent.

Un code prévu pour être testable est souvent plus atomique, plus modulaire, avec moins d'adhérence qu'un code qui ne l'est pas.

*Vous forcer à réfléchir en amont a la manière dont votre code est sensé fonctionner ?*

C'est évident que les tests capturent simplement la base de ce contrat de fonctionnement qui constitue l'API du composant et la base de sa documentation et que d'y réfléchir à priori vous assure que ce travail sera toujours effectué.

*Quoi d'autre ?*

Les raisons évoquées plus haut et communément admises, justifient à elles seules l'usage du TDD, mais avec le temps j'ai réalisé que le principal intérêt pour moi est tout autre, plus subtil mais bien plus impactant : **Le TDD n'a pas seulement un impact qualitatif il a avant tout un impact psychologique.**

Accordez-moi quelques minutes à vous l'expliquer avant de froncer les sourcils.

Être capable d'écrire le meilleur code qui soit, ne sert à rien si on ne le fait pas. Nombre d'auteurs le savent bien, bloqués devant leur feuille blanche.

Et même si les développeurs n'ont pas forcément ce genre de blocage, j'ai observé tout au long de ma carrière une zone de friction au début d'un projet. Souvent le développeur (votre serviteur y compris) ne sait pas par quel bout prendre le projet, même quand des specifications existent les premiers blocs de codes sont les plus difficiles à écrire.

>"Un commencement est un moment d'une délicatesse extrême" -- Frank Herbert (Dune)

Le test first est un cadre qui permet de s'affranchir de cette résistance :

Le test est un pas, simple, rassurant, qui initie le mouvement. Il appelle un autre pas tout aussi simple qui entretient le mouvement et nous rapproche de notre destination.

L'image du mouvement est choisie à dessein car la vélocité permet de vérifier l'impact psychologique du test first : On rentre plus vite dans le projet, on produit plus vite du code.

Même quand le projet est bien lancé, la suite de tests permet d'entretenir cette vélocité, là ou un codeur sans suite de test hésitera à corriger/améliorer/augmenter son code de peur de tous casser, un adepte du TDD rassuré par la capacité de sa suite de tests à signaler les régressions ne ralentira pas le rythme de ses boucles red/green/refactor et continuera à produire plus de code.

C'est un cercle vertueux, plus on écrit de tests plus on va vite et plus on a confiance et donc plus on peut écrire de code et donc de test...

Le pourcentage de couverture de code ne cesse d'augmenter renforçant ce sentiment de confiance, en témoignant non pas de la qualité du code mais au moins de l'amélioration de celle-ci.

Même ceux qui souffrent du syndrome de l'imposteur, et ils sont nombreux parmi les codeurs que j'ai rencontrés, y voient non une indication absolue de leur talent (ça serait si simple...) mais la certitude et le réconfort de voir la qualité de leur code se hisser vers les niveaux de qualité qu'ils imaginent être la norme.

