+++
date = '2026-03-20T20:24:26+01:00'
title = "Et si votre OOM n’était pas qu’un problème de mémoire ?"
categories = ["Article"]
tags = ["Software Development", "Go", "Bug"]
+++

Parfois, une investigation raconte une autre histoire que celle que vous attendez.

C’est ce qui m’est arrivé récemment en cherchant pourquoi un pod finissait en OOMKilled deux à trois fois par jour.

Une rapide observation de la mémoire du pod incriminé ne montre pas la courbe croissante typique d’un memory leak. Je manque de données juste avant le OOM (parce que c’est toujours quand votre système de métriques est en train de migrer que ce type d’incident se produit) mais avec les données de la journée, la cause semble se trouver ailleurs.

Qu’à cela ne tienne, je peux toujours commencer par une analyse statique du code pour trouver les coupables habituels :

Un `resp.Body` non fermé :

```go
resp, err := client.Do(req)
if err != nil {    
		fmt.Printf("error calling %s: %s", url, err.Error())    
		return nil, resp, err
}
```

L'oubli est ici impactant dans un cas particulier, resp ET err non nuls, ce qui réduit sa fréquence. C'est sans doute pour cela qu'il passe sous le radar de l'observation mémoire. Mais c’est quand même à chaque fois un file descriptor, plusieurs buffers et structures de contrôle de la connexion qui ne sont pas libérés.

Un io.ReadAll sans limite :

```go
resBytes, err := io.ReadAll(resp.Body)
```

Des allocations inutiles sur le heap

Des allocations inutiles dues à la sérialisation de structures complexes pour le logging  :

```go
// claimsRoot est une structure complexe qui va être encodée pour le log
Log.Info("", zap.Any("claims", claimsRoot))
```

Ou via  des réallocations en masse avec des slices qui ne cessent de croître :

```go
var slice []string
for _, v := range source {    
	slice = append(slice, v)
}
```

Aucun de ces points n’expliquait, à lui seul, des crashs OOM aussi violents.

Et puis je suis tombé sur un détail insignifiant.  
Un `ctx.Next()` appelé une seconde fois à la fin du middleware de logging.  
Une ligne banale. Un bug énorme.

```go
func LoggingMiddleware(logger *zap.Logger) gin.HandlerFunc {    
	return func(ctx *gin.Context) {   
		// set start time to "now" in ms   						
		ctx.Set("start", time.Now().UnixMilli())            
		ctx.Next()            
		// set end time to "now" in ms            
		end := time.Now().UnixMilli()            
		start := ctx.GetInt64("start")            
		ctx.Set("processing_time", end-start)            
		if strings.HasPrefix(ctx.Request.URL.Path, "/special") {
			log.LogApiDebug(logger, ctx, "")            
		} else {                    
			log.LogApiInfo(logger, ctx, "")            
		}            
		ctx.Next() //  <- OUCH !    
		} 
}
```

Mauvais copier-coller ou habitude, toujours est-il que ce code compile et a tourné avec pour effet d’appeler  deux fois les endpoints consommateurs de ressources.

Un bug amplificateur !

Et parmi les endpoints encapsulés par ce middleware il y a deux endpoints qui appellent une méthode lançant une goroutine :

```go
func (s Service) GetUserInfo(appContext api.Context, userID string) (...) {
    
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	...
}
```

Et si la méthode/goroutine utilise un contexte, comme on doit le faire pour toutes les opérations longues et annulables, elle le fait sans récupérer le contexte parent du handler.  
Dans ce cas, même si l’utilisateur annule sa requête ou si en amont elle était à une seconde de son timeout, la goroutine va ici s’exécuter encore jusqu’à 15 s.

Pris isolément, ce n’est pas dramatique : au bout de 15 secondes, le timeout finit par libérer les ressources.  
Sous forte charge, c’est une autre histoire. À plusieurs centaines de requêtes par seconde, ces goroutines s’accumulent plus vite qu’elles ne disparaissent.  
Chacune avec sa stack, ses buffers, ses structures mémoire…

Et en parlant de structures mémoire : la goroutine alimente une structure via un appel externe utilisant un filtre, pour faire son traitement. Par manque de chance, le filtre est mal configuré et ce sont 20 à 30 % de données inutiles qui sont récupérées en mémoire pour faire le traitement. C’est un bug purement logique, mais il gaspille juste 20 % de mémoire et de CPU.

```go
info, err = toolbox_api.GetInfo(userId, "", make(map[string]string))

// au lieu de l'appel avec un filtre renseigné
info, err = toolbox_api.GetInfo(userId, "", map[string]string{"state": "active"})
```

Tout cela combiné, on a déjà une bonne recette pour une dégradation sous forte charge : 

Le middleware double le travail effectué. Des goroutines continuent ensuite à s’accumuler sur une fenêtre de 15 secondes, chacune traitant des données surdimensionnées de 20 %.  
Résultat : plus d’allocations, plus de CPU, plus de pression sur le GC, donc un système qui ralentit… et aggrave encore cette accumulation.

Mais pour une catastrophe, il manquait encore (ou pas) un amplificateur et on va l’avoir avec le fait que les endpoints incriminés lancent chacun 4 goroutines.  
On se retrouve donc, quoi qu’il arrive, avec quatre fois plus de goroutines susceptibles de s’accumuler, accentuant la consommation mémoire, CPU et la pression sur le GC dans une belle boucle d’amplification qui mène à l’OOM

- x2 requêtes effectives à cause du middleware
- Chaque requête lance 4 goroutines
- Les goroutines vivent jusqu’à 15 s même si la requête n’a plus de sens
- Elles chargent 20–30 % de données inutiles
- Plus d’allocations → plus de GC
- Plus de GC + plus de CPU → traitement ralenti
- Traitement ralenti → plus de goroutines simultanées
- Plus de simultanéité → OOM

Pour casser cette boucle d’amplification, il fallait agir sur trois leviers :

1. réduire le travail inutile,
2. mieux limiter la durée de vie des traitements,
3. limiter la concurrence.

Concrètement, voici les actions mises en oeuvre :

- Supprimer le double `ctx.Next()`
- Filtrer correctement les données
- Ajouter des sémaphores sur les goroutines pour un gain CPU/réseau : backpressure explicite via 503 plutôt que timeout en cascade.
- Réduire les timeouts pour éviter les effets d’accumulation  
  (la fenêtre glissante d’accumulation liée aux timeouts étant plus courte)
- Utiliser un `io.LimitedReader` avant `io.ReadAll`

```go
const maxResponseBodySize = 1 * 1024 * 1024 // 1MB
limited := &io.LimitedReader{R: resp.Body, N: maxResponseBodySize + 1}
resBytes, err := io.ReadAll(limited)
if limited.N == 0 {    
	return nil, resp, fmt.Errorf("response body exceeded %d bytes limit", maxResponseBodySize)
}
```

- Réduire le volume de logs et les allocations associées
- Préallouer des slices avant la boucle dont on connaît la taille

```go
slice = make([]string, 0, len(source))
```

Tant qu’à faire, compléter avec le tuning de la mémoire des pods (qui étaient par ailleurs sous-dimensionnés pour tenir les pics), et ajouter un GOMEMLIMIT à 85 % de la mémoire max

On peut tirer plusieurs leçons de cet incident, mais pour ma part je retiendrai surtout que cet OOM est quasiment un cas d’école : ce pod ne mourait pas d’une simple fuite mémoire. Il mourait d’un système qui faisait trop de travail, trop longtemps, avec trop de concurrence, pour traiter trop de données inutiles.

Et si, en tant que lecteur avisé, vous vous demandez pourquoi je n’ai pas simplement utilisé pprof pour identifier ces problèmes plus tôt... la réponse mérite un article à elle seule. Spoiler : la raison n'est pas technique.
