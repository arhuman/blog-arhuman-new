+++
date = '2026-03-15T11:05:26+01:00'
title = 'Et si votre dette technique n’était pas un problème technique ?'
categories = ["Article"]
tags = ["Software Development", "Communication", "Psychology"]
+++

Alors que les méthodes se font toujours plus nombreuses, les livres toujours plus prescriptifs, les outils toujours plus performants, la démarche toujours plus industrielle, l’industrie du logiciel continue à produire autant de dette, de retard et de bugs qu’auparavant.  
C’est un secret de polichinelle et pourtant rien ne change. Pourquoi ?  
Peut-être est-il temps de chercher la cause là où trop peu regardent.

Laissez-moi vous raconter une histoire.

Imaginez, vous êtes embauché en tant que chef de projet informatique, dans une startup où le développement est complètement stoppé :

Les fondateurs ont pris une décision aussi rare que courageuse : un “Code Freeze” de plusieurs semaines ! Plus une ligne de code ne sera écrite tant qu’on n’aura pas compris pourquoi on n’arrive pas à finaliser la mise en production du logiciel phare, et qu’on n’aura pas mis en place ce qu’il faut pour débloquer la situation. Une vingtaine de développeurs, graphistes, architectes et testeurs à l’arrêt.

Cette situation, je l’ai vécue.

Mon mandat était clair : trouver les solutions pour livrer enfin cette première version. J’ai donc mené mon investigation sur tous les fronts à la fois.

J’ai participé à des réunions. J’ai audité des centaines de milliers de lignes de code. J’ai étudié la manière de travailler de chacun. Mais j’ai aussi beaucoup écouté, beaucoup observé, contribué à l’unité, au bien-être et à la motivation de l’équipe,

C’est alors seulement que les vraies causes se sont révélées.

### L’absence de communication

Les interfaces se désynchronisaient à chaque livraison, causant des bugs subtils et des régressions.

En creusant, j’ai découvert que l’équipe UI et l’équipe Backend ne se parlaient plus; un conflit ancien avait progressivement coupé toute communication. Chaque équipe travaillait dans son coin, sans se soucier de l’impact de son travail sur l’autre.

J’ai organisé des sessions de travail communes, d’abord courtes et cadrées, pour recréer un espace de dialogue neutre. Puis, je leur ai fait concevoir ensemble la documentation des modifications des interfaces, que nous avons ensuite intégrée dans la CI.

La synchronisation des interfaces s’est améliorée dès les premières semaines.

### La méfiance codée en dur

Les erreurs passées et l’absence de communication avaient aussi créé un problème de confiance/respect entre les équipes et parfois même au sein d’une même équipe, provoquant la multiplication de code redondant (et souvent inefficace) pour pallier les déficiences supposées de tel ou tel composant ou codeur :  l’UI implémentant son propre cache de métadonnées, le backend prenant en charge des transformations de présentation.

La communication a permis de prendre en compte les contraintes et le domaine de compétence de chaque équipe et de clarifier les attentes et les responsabilités de chacun.

Ceci étant fait c’est tout naturellement que le code redondant a été supprimé

### La qualité étouffée dans l’œuf

Un problème de reconnaissance/légitimité faisait que les meilleures idées étaient systématiquement étouffées par certains profils seniors, provoquant une complexification inutile de l’architecture : jusqu’à voir des commits réintroduire des structures complexes et inefficaces qu’un développeur talentueux avait pourtant réussi à simplifier.

C’est en challengeant les objections en appuyant les gains et en sollicitant les principaux opposants pour améliorer l’idée plutôt que de la combattre que j’ai pu obtenir à la fois l’adhésion de tous et la mise en œuvre des simplifications comme la refactorisation du moteur de métadonnées.

L’amélioration s’est traduite immédiatement en termes de performance mesurée et de facilité à modifier le code. Et de manière induite : moins de bugs générés à chaque modification.

### Le remède qui n’en est pas un

Un problème d’interférence par certains fondateurs qui, malgré leur bonne volonté, court-circuitaient et déstabilisaient les processus qu’ils essayaient de mettre en place : ajoutant cacophonie, latence et traitement manuel là où le process automatisé garantissait rapidité et qualité,

En caractérisant le coût de ces comportements (en temps, stress,  qualité et impact sur le moral de l’équipe), j'ai pu montrer que le gain supposé n'en valait pas la peine. Le process est devenu non négociable, avec le soutien de ceux-là mêmes qui s'accordaient le droit d'y déroger.

Moins sollicité pour des traitements manuels “exceptionnels”, la fluidité/qualité du process de livraison automatisé s’est vu grandement améliorée, de même que les conditions de travail des personnes régulièrement sollicitées qui ont pu mettre leur temps à profit pour améliorer les workflows de gestion du code source, et les suites de tests de performance/non-régression.

En valorisant les forces de chacun, en restaurant la confiance, en encourageant la communication : c’est ainsi que les changements qui n’avaient pas pu être mis en place ont enfin pu l’être, dans une spirale vertueuse. 

Il ne m’a fallu que 4 leviers.

### Nommer la dette sans punir

Je ne crois pas à une communication sincère sans confiance ; c’est pourquoi, pour parler des choses importantes, il est important de créer un climat de confiance. J’ai toujours pris soin de dépersonnaliser les problèmes et de garantir un espace d’expression neutre où les échecs et difficultés pouvaient être discutés sans jugement de personne et à fortiori sans “punition”. Parler du *pourquoi* plutôt que de *qui* reste une solution pratique pour y arriver.

### Connaître son équipe

Je ne parle pas ici de connaître le titre, les domaines d’intervention, ni même le CV de chacun.  
Je parle de connaître les talents (est-ce quelqu’un qui résout des problèmes, quelqu’un de rigoureux), les appétences : quelles technologies il apprécie, dans quelles tâches il excelle, mais aussi sa psychologie : ce qui lui fait peur, ce qui le braque, le motive.

### Trouver le vrai blocage

Je ne crois pas tant au développeur fainéant (il y en a) qu’au développeur ralenti par une peur : de mal faire, de casser le code, d’exposer son ignorance…  
Dans tous les cas, il est toujours plus efficace de travailler sur la cause que sur l’effet.  
Mettre en place une suite de tests pour rassurer avant les commits.  
Mettre en place une Knowledge Base pour favoriser l’autonomie.  
Un développeur rassuré livre mieux et plus vite qu'un développeur surveillé.

### Quantifier le coût des comportements

Un commit hors process, une fonctionnalité sans spécifications assez détaillées demandée par le CEO, une tâche “prioritaire” ajoutée en plein sprint, autant de tâches qui vont bien évidemment impacter les délais.  
Une cadence élevée demandée sur la durée (jusqu’à cette fin qui ne vient jamais) va bien sûr impacter les personnes, leur moral et au final leur productivité. Analyser le temps perdu dans un post-mortem est souvent révélateur. Les chiffres rendent visible ce que tout le monde ressent mais que personne n'ose dire.

Ces leviers ne sont pas des recettes. Ce sont des attitudes. Et parfois, elles changent une carrière, pas seulement un projet.

J’ai encore en mémoire le sourire, la fierté et l’énergie, qu’il a gardés depuis, de cet ingénieur quand il a pu, enfin, présenter et faire valider sa simplification architecturale.

Quelques semaines plus tard, deux mois après mon arrivée, un mois après la fin du Code Freeze, la première version publique sortait en production.

Mais les principales causes de ce succès ne sont dans aucun commit.

Cette réussite n’est bien sûr pas la mienne : c’est celle d’une équipe, celle que je gérais, mais aussi de la compagnie dans son ensemble : des dirigeants aux employés.

La prochaine fois que votre projet dérape, avant d’auditer le code, posez-vous une seule question : quelle est la conversation que mon équipe n’est pas en train d’avoir ?
