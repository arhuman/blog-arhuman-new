+++
date = '2026-09-23T06:30:00+02:00'
title = "Quand Anthropic se croit en droit de décider à votre place"
description = "Claude Code co-signe mes commits malgré une consigne écrite qui l'interdit. Je porte la responsabilité de mes commits et du choix de leur forme, pas l'outil ni la compagnie éditrice."
categories = ["Article"]
tags = ["AI", "Claude Code", "Git", "Software Development"]
translationKey = "who_signs_my_commits"
+++

C'est la deuxième fois ce matin.
Encore une fois, sans rien dire, Claude Code a co-signé mon commit.

```
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

Quand je lui fais remarquer, il s'excuse platement et recommence.

J'avais pourtant écrit, en majuscules, dans mon CLAUDE.md global :

> NEVER append a Co-Authored by Claude in commit description

C'est le fichier que Claude Code charge à chaque session.

Je dis publiquement que j'utilise l'IA, mais je réponds de mon code.
Avec cet ajout un client peut se demander qui répond du code, un mainteneur ce que "co-author" implique alors que ces questions n'ont pas lieu d'être.
Co-signer ce n'est pas assister, c'est revendiquer la paternité.

Et je repasse derrière lui pour réécrire mes trois commits.
Je n'achète pas de la musique avec des pubs, ni une voiture avec un panneau publicitaire, ce n'est pas pour avoir un harnais qui m'oblige à réécrire mes commits pour l'empêcher de faire de la pub malgré mon interdiction.
Personne n'a demandé ce défaut, Anthropic l'a décidé.
Et quel autre but que l'intérêt commercial ? Si l'objectif était l'aspect légal, l'entraînement des données, la confidentialité des sessions de chat auraient dû être traités en priorité.

Le mécanisme d'instructions a une hiérarchie, et la parole écrite de l'utilisateur n'est pas au sommet[^reglage] : le marketing Anthropic gagne, la liberté du développeur perd.

Il s'excuse, cite ma règle, et recommence :

> You're right, and I have no good excuse. Your global CLAUDE.md says "NEVER append a Co-Authored by Claude in commit description" [...] I added it to all three commits anyway.

Mais une excuse quand elle se répète perd toute valeur, on n'est plus dans l'opérationnel, on entre dans la représentation.

Peut-être est-il temps d'évaluer des outils qui respectent mes choix[^alternatives].

[^reglage]: Le réglage includeCoAuthoredBy: false existe, mais une consigne écrite devrait suffire. Et surtout il n'aurait pas dû être mis à true par défaut en premier lieu.

[^alternatives]: opencode (opencode.ai) et Pi (pi.dev) sont par exemple deux outils Open Source prometteurs.
