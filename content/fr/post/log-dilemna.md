+++
date = '2026-09-13T10:30:00+02:00'
title = "Le dilemme des logs"
description = "Noyé sous les logs quand tout va bien ou condamné à en manquer en cas d'incident. On n'est plus obligé de choisir : le niveau dynamique offre le meilleur des deux approches."
categories = ["Article"]
tags = ["Software Development", "Go", "Logging", "dllog"]
+++

Tous les développeurs ont déjà vécu cette scène : le pic d'adrénaline à l'annonce de l'incident en production. Ce mélange d'angoisse de ce que l'on va découvrir et de frénésie à collecter toute information qui nous permettra de comprendre puis corriger le problème. Cela m'est à nouveau arrivé il y a quelques jours, je me revois me précipiter sur les logs et je me souviens encore de la frustration de n'y trouver que des infos basiques et un message d'erreur peu explicatif "Impossible de charger le cache".

La frustration a vite laissé place à la colère : on avait réduit le niveau de log il y a quelques mois, lassés d'être noyés jour après jour par les logs de debug qui nous répétaient que tout allait bien, que nos sondes se connectaient sans souci, et que les infos étaient bien retournées par les bases de données.

Noyé sous les logs quand tout va bien ou condamné à en manquer en cas d'incident. Ce dilemme des logs m'apparaissait alors comme une malédiction à laquelle on ne pouvait échapper.

Bien sûr nous avions mis en place au passage un toggle à chaud du niveau de log, conforté par la promesse que les puissants filtres de notre outil de log nous permettraient, une fois le niveau basculé en debug, d'obtenir toutes les informations nécessaires à la résolution d'un incident.
Mais augmenter le niveau de log a posteriori est parfois un mauvais pari, en particulier si l'erreur est liée à un contexte temporel (pic de charge, backup de base de données...) car il sera alors difficile voire impossible de reproduire l'erreur pour collecter les informations dans les logs.
Et je ne parle pas des petites frictions opérationnelles qui, bien que non bloquantes, ralentissent la reproduction, la compréhension et donc la correction du problème : comment identifier le bon pod sur lequel augmenter le niveau de log ? Comment gérer la sécurité des endpoints de toggle ? Comment rendre leur sémantique claire : /log/increase augmente-t-il le niveau de log ou la verbosité des logs ? /log/increase modifie-t-il le niveau vers error ou vers debug ?
Avec le recul, le constat est sans appel, le toggle dynamique est un mieux, mais pas la solution à notre usage.

D'autant plus que les puissants filtres ne règlent pas le problème, au mieux ils l'atténuent : avec plus de log de debug, j'ai les informations sur l'incident mais elles restent noyées au milieu de tout le bruit des informations de debug qui n'ont rien à voir. Chercher une aiguille bien précise dans une meule de foin ne change pas profondément la nature ni la difficulté de la tâche.

**Le vrai problème est qu'on doit décider avant l’incident quels logs méritent d’être conservés, alors qu’on ne sait qu’après lesquels étaient réellement utiles.**

D'où l'idée d'un niveau « dynamique » par opération implémenté par dllog (c'est le DL, Dynamic Level, de dllog) : 
les logs en erreur modifient rétroactivement le niveau de log pour faire apparaître les logs de debug qui les précèdent. 
Quand tout va bien on ne voit que les logs du niveau courant (Info par exemple) mais en cas d'erreur les logs de niveau Debug qui précèdent ou suivent l'erreur sont aussi affichés.

Sur le principe, il suffit de se brancher sur le logger existant (slog ou zap pour l'instant) :

```go
logger := slog.New(dllog.NewJSON(os.Stderr))
slog.SetDefault(logger)

mux := http.NewServeMux()
mux.HandleFunc("/order", func(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Bufferisés : invisibles si la requête réussit.
	slog.DebugContext(ctx, "loading cart", "user", 42)
	slog.DebugContext(ctx, "applying discount", "code", "SUMMER")

	// Un record Error rejoue d'abord tout ce qui est bufferisé au-dessus.
	slog.ErrorContext(ctx, "payment declined", "provider", "stripe")

	w.WriteHeader(http.StatusInternalServerError)
})

// Le middleware ouvre un scope par requête, déclenche le replay sur 5xx et sur panic.
http.ListenAndServe(":8080", dllog.Middleware()(mux))
```

Pour l'implémentation, il faut faire attention aux performances et aux différents problèmes liés à la concurrence :
* Des buffers circulaires
* Des sync.Pool
* Des opérations lock-free
* Un formatage retardé 
* ...

On obtient alors quelque chose d'utilisable :

![slog à Info](/img/demo-info.gif)
![dllog à Info](/img/demo-dllog.gif)
![slog à Debug](/img/demo-debug.gif)

La différence saute aux yeux : moins de bruit quand tout va bien, mais le contexte utile quand ça casse. À la clé, potentiellement moins de logs à stocker et surtout moins de temps perdu à comprendre l’incident.

Cette malédiction n'était donc pas une fatalité. C'est ce que j'aime dans mon métier : il y a toujours des voies à explorer en dehors des habitudes, des quasi-certitudes et ces voies sont parfois étonnamment efficaces.
