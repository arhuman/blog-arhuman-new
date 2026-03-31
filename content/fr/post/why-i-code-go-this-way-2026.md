+++
date = '2026-03-30T15:24:26+01:00'
title = "Pourquoi je code en Go de cette manière en 2026"
categories = ["Article"]
tags = ["Software Development", "Go"]
+++

## Pourquoi écrire encore sur le layout et les pratiques Go en 2026 ?

En 2018, Mat Ryer écrivait un article de référence [How I write HTTP services after 8 years](https://pace.dev/blog/2018/05/09/how-I-write-http-services-after-eight-years.html) qu’il a mis à jour quelques années plus tard : ["How I write HTTP services in Go after 13 years"](https://grafana.com/blog/2024/02/09/how-i-write-http-services-in-go-after-13-years/).

En 2019, je présentais déjà ma manière de coder en Go dans plusieurs [présentations d’introduction au langage](https://blog.assad.fr/slides/talk-how_I_code_in_go).

Ce texte est une version révisée de cette présentation, nourrie par mon expérience et mes contraintes en 2026.

Mais pourquoi revenir une fois de plus sur un sujet aussi rebattu ?
D’abord parce que c’est une question qui revient régulièrement chez les développeurs qui commencent à utiliser Go : comment partir sur de bonnes bases ?

Cette récurrence s’explique par un constat simple : il n’existe aucun consensus stable, ni sur le layout, ni sur les bonnes pratiques.

Il existe bien des sources comme le [go-layout](https://github.com/golang-standards/project-layout) qui malgré son nom n'est PAS
un standard, [Organizing Go code](https://go.dev/doc/modules/layout) qui se focalise sur la structure d'un module et ne décrit 
que sommairement la structure pour un serveur HTTP, [l'article de Ben Johnson](https://web.archive.org/web/20250915154151/https://www.gobeyond.dev/standard-package-layout/), ou la présentation de Kat Zien "How do you structure your Go apps?"

Dès qu’on regarde les grands projets Go sur GitHub, un constat s’impose : il n’existe pas de manière officielle unique de faire.

L’évolution du langage a également rendu une partie de ces guides moins actuels :
Depuis les modules, le sujet du vendoring ne se pose plus dans les mêmes termes.
L'architecture du code et la manière de gérer l'encodage ont été rendues plus élégantes grâce aux generics.
L’écosystème a, lui aussi, évolué, au point de rendre certaines pratiques non seulement possibles, mais parfois souhaitables.

Mon objectif ici n’est donc pas de proposer une méthode idéale, mais d’expliquer les raisons qui me font coder ainsi aujourd’hui. Ces raisons ne seront pas forcément pertinentes pour vous. Mais les exposer clairement vous permettra de choisir plus lucidement les pratiques et le layout adaptés à vos besoins.

## Le layout que j’ai retenu après plusieurs années de pratique

Voici, dans les grandes lignes, le layout que j’utilise aujourd’hui :

```bash
cmd/
  api/                          # Point d'entrée du serveur HTTP principal
  apcli/                        # Outil CLI interne

internal/
  api/                          # Handlers, routes, middleware et configuration du serveur
    task_handler.go
    account_handler.go
    monitoring_handler.go
    routes.go
    server.go

  account/                      # Domaine : gestion des comptes
    repository.go
    service.go
    repository_test.go
    service_test.go

  task/                         # Domaine : gestion des tâches
    repository.go
    service.go
    repository_test.go
    service_test.go

  models/                       # Modèles métier regroupés (pour éviter les cycles de dépendances)
    account.go
    task.go

  utils/                        # Fonctions utilitaires communes
    helpers.go

pkg/                            # Code destiné à être partagé entre plusieurs projets
  token/                        # Exemple : gestion des tokens (potentiellement réutilisable)
    token.go
    models.go

config/                         # Fichiers de configuration (policies JSON, tokens de test, etc.)
docs/                           # Documentation et spécifications OpenAPI/Swagger
conf/docker/                    # Scripts d'initialisation de base de données

docker-compose.yml              # Environnement de développement et tests
Makefile
go.mod
go.sum
```

On y retrouve plusieurs conventions assez répandues dans l’écosystème Go :

* L'utilisation de `cmd/` qui permet de lister instantanément grâce à ses sous-répertoires tous les binaires générés et d'avoir un point d'entrée clairement défini.
* J’utilise internal/ non seulement pour bénéficier de sa protection au niveau du compilateur, mais aussi pour éviter d’encombrer inutilement la racine du projet.
* Les sous-répertoires `internal/<NomEntité>/` regroupent l’essentiel du code métier par domaine, en général autour d’un `repository.go` et d’un `service.go`. J’en écarte volontairement les handlers et les modèles, pour garder une frontière plus nette entre logique métier, transport et structures partagées.
* Certains sous-répertoires ne correspondent pas à des entités métier, mais de l'infra comme `api/` qui contient les handlers, routes, middleware et le serveur...
  * `task_handler.go` et `account_handler.go` sont dans `internal/api/` plutôt que respectivement dans `internal/task/` et `internal/account/` d'une part pour la séparation des responsabilités (le handler relève plus du transport que du service associé) mais aussi d'un point de vue pragmatique parce que c'est l'endroit logique pour regrouper tous les handlers (certains non liés à des entités comme `monitoring_handler.go`)
  * Séparer toutes les routes dans un fichier `routes.go` permet là aussi un point d'entrée unique et naturel pour connaître tous les endpoints.
  `routes.go` est aussi l'endroit naturel pour configurer les middleware avec `.Use()`.
  ```go
  // Routes définit les endpoints de l'API
  func (s *Server) Routes() {
    s.Router.GET("/healthcheck", s.GetHealthcheck)

    authMiddleware := auth.NewMiddleware()

    v1 := s.Router.Group("/v1")
    {
      // Endpoints publics
      v1.GET("/docs/*any", s.GetDocs)

      // Endpoints protégés par authMiddleware
      protected := v1.Group("/")
      protected.Use(authMiddleware)

      protected.GET("/resources", s.ListResources)
      protected.POST("/resources", s.CreateResource)
      protected.GET("/resources/:id", s.GetResourceByID)
      protected.DELETE("/resources/:id", s.DeleteResourceByID)
    }
  }
  ```
  * J’applique la même logique à server.go, qui concentre la construction du serveur via NewServer() et sa configuration via SetupServer(). Cela me donne un point d’entrée naturel pour comprendre comment le service est assemblé.
  ```go
  type Server struct {
	AccountService *account.Service
	TaskService    *task.Service
	ConfigDB        *gorm.DB
	Log            *zap.Logger
	Router         *gin.Engine
	// ...
  }

  func NewServer(
    accountService *account.Service,
    taskService *task.Service,
    configDB *gorm.DB,
    log *zap.Logger,
  ) *Server {
      router := gin.New()
      router.Use(gin.Recovery())
      router.Use(utils.LoggingMiddleware(log))

      return &Server{
          AccountService: accountService,
          TaskService:    taskService,
          ConfigDB:        configDB,
          Log:            log,
          Router:         router,
      }
  }

  func SetupServer() *Server {
      c := utils.GetConfig()

      accountRepository := account.NewGormRepository(c.ConfigDB, c.Log)
      taskRepository := task.NewGormRepository(c.ConfigDB, c.Log)

      accountService := account.NewService(accountRepository, c.Log)
      taskService := task.NewService(taskRepository, c.Log)

      s := NewServer(accountService, taskService, c.ConfigDB, c.Log)
      s.Routes()

      return s
  }
  ```

* J’ai fini par regrouper mes modèles dans `internal/models/`. Ce choix est discutable[^1], mais il m’a évité à plusieurs reprises des dépendances circulaires inutiles. Je préfère ici une convention explicite à une pureté architecturale fragile.

Le problème apparaît vite dès qu’on laisse deux packages métier se référencer mutuellement :

    ```go
    package user

    import "myapp/internal/organization"

    type User struct {
        ID            string
        Email         string
        Organizations []organization.Organization
    }
    ```

    ```go
    package organization

    import "myapp/internal/user"

    type Organization struct {
        ID      string
        Name    string
        Members []user.User
    }
    ```


Ce choix s'inscrit aussi pour moi dans la même logique de regroupement (cf. `routes.go`) qui facilite la navigation dans le code.

Contrairement à certains layouts plus anciens, je n’inclus pas de `vendor/` : la gestion des dépendances passe ici directement par `go.mod` et `go.sum`.

## Ce qui a changé depuis 2019 ?

Au fil du temps, j'ai déplacé les répertoires domaines sous `internal/` pour bénéficier de la protection particulière de ce répertoire, et pour avoir un répertoire racine moins encombré.

Tant que cette réutilisation reste seulement probable, le code reste dans `pkg/`. Dès qu’elle devient réelle, j’en fais un module séparé.
Du coup les modèles métiers a priori non partageables vont dans `internal/models/` mais si j'utilise une entité qui va être partagée, je place son modèle dans son sous-répertoire `pkg/`. Imaginons que je veuille réécrire ma propre gestion des tokens pour tous mes projets, je la mets dans `/pkg/token/` qui contient `token.go` et `model.go`

En 2026, une base de tests solide est incontournable.
Je garde les tests unitaires au plus près du code (encore une fois à l'encontre de la recommandation du `go-layout`).
Cela facilite la synchronisation et ça permet aussi de cibler plus simplement un sous-ensemble de test `go test ./internal/account/`.
Mais je m’éloigne progressivement des mocks : dans beaucoup de cas, tester contre un vrai service de test me donne des tests moins fragiles et plus représentatifs[^2].

J’ai abandonné les `Init()` utilisant des variables globales au profit d’un constructeur `NewServer()`, plus explicite et bien plus testable.

J'utilise de plus en plus des erreurs encapsulées `fmt.Errorf("op: %w", err)` et des erreurs sentinelles pour une gestion plus fine.

Je m’appuie sur un Makefile pour unifier les commandes entre projets, même quand leur implémentation diffère fortement :
`make test`, `make audit`, `make compose-up`, `make compose-build`, `make compose-down` auront le résultat escompté sur mon api go, mon frontend en typescript ou mon outil CLI.
`make audit` en particulier me permet avec `golangci-lint` et `govulncheck` d'auditer d'une manière assez complète la qualité de mon code et de mes images en détectant les sources de bug avant même mon commit.
```Makefile
## tools: install Go tools
tools:
	@go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.11.3
	@go install golang.org/x/vuln/cmd/govulncheck@latest

## audit: run quality control checks
audit:
	@command -v golangci-lint > /dev/null || $(MAKE) tools
	@command -v govulncheck > /dev/null || $(MAKE) tools
	go mod verify
	golangci-lint run ./...
	govulncheck ./...
```

Je n'utilise toujours pas le répertoire /build recommandé par le go-layout, par souci de simplicité et convention (il est courant d'avoir le `docker-compose.yml` à la racine, et j'aime l'idée d'avoir `Makefile` et `docker-compose.yml` à la racine pour faciliter le lancement des commandes `make`/`docker compose`).
Mais je me pose la question pour désencombrer mon répertoire racine.

Ma façon de logger a aussi évolué, je suis passé de `logrus` à `go.uber.org/zap` pas tant pour la performance que pour le logging structuré.
C'est pourquoi, avec l'arrivée de `log/slog` dans la stdlib, la question de la migration pour réduire les dépendances et pour l'évolutivité (`slog` est une interface permettant d'utiliser différents backends) se pose.

Désormais j'utilise aussi context.Context pour toutes les opérations externes et/ou pouvant être annulées par un timeout ou une action utilisateur.
C'est une leçon durement apprise, mais réduire le temps de conservation des ressources est plus qu'une bonne idée, c'est un prérequis.

Je préfère une documentation qui naît du code à une documentation séparée qui vieillit mal.

Par exemple ma documentation Swagger se génère facilement via une cible dans mon Makefile[^3]

```Makefile
## doc: make documentation
doc:
	@which swag > /dev/null || $(MAKE) tools
	swag init -g cmd/api/main.go --parseDependency --parseInternal
```

et l'ajout de commentaires de documentation :

```go
  // CreateTask godoc
  // @Summary     Create a task
  // @Description This multi lines description
  // @Tags        task
  // @Param       task 	body CreateTaskRequest	true "A task object"
  // @Accept      json
  // @Produce     json
  // @Success     201  {object} CreateTaskResponse
  // @Failure     409  {object} APIError
  // @Failure     500  {object} APIError
  // @Router      /tasks [post]
  func (s *Server) CreateTask(c *gin.Context) {
```


Une fois ces choix posés, la comparaison avec l’approche de Mat Ryer devient plus intéressante.

## Pourquoi pas simplement comme Mat Ryer ?

Au final, j'ai convergé vers un layout et des pratiques qui s'approchent beaucoup de ce que proposait Mat Ryer.

Les différences portent essentiellement sur la manière de gérer les dépendances : je préfère les gérer une fois à l'instanciation du serveur plutôt que via des fonctions qui génèrent des `http.Handler`
Car même si j'utilise Gin, je peux utiliser un handler standard -`func (s *Server) GetApplication(c *gin.Context)` et gérer les dépendances implicitement via s.* 
Pas besoin de passer explicitement les dépendances à chaque (création de) handler.

Une autre différence est l'utilisation d'une fonction `Run()` qui est à peu près tout ce qui est appelé dans le `main()`, c'est utile pour tester le `main()`, mais comme je lance un serveur réel pour mes tests d'intégration via docker-compose, l'inertie de l'habitude fait que je n'ai pas ressenti le besoin d'implémenter ce pattern qui est pourtant sans aucun doute plus élégant.

Un point où son approche est indiscutablement meilleure est l'utilisation de helpers utilisant des generics pour encoder/décoder le JSON:
Si Gin, que j'utilise actuellement, offre nativement les fonctions `c.ShouldBindJSON()` et `c.JSON()` architecturalement (ou dans l'éventualité d'une migration) l'approche de Mat Ryer est plus élégante :

```go
func encode[T any](w http.ResponseWriter, r *http.Request, status int, v T) error {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    if err := json.NewEncoder(w).Encode(v); err != nil {
        return fmt.Errorf("encode json: %w", err)
    }
    return nil
}

func decode[T any](r *http.Request) (T, error) {
    var v T
    if err := json.NewDecoder(r.Body).Decode(&v); err != nil {
        return v, fmt.Errorf("decode json: %w", err)
    }
    return v, nil
}

...

err := encode(w, r, http.StatusOK, obj)

...

decoded, err := decode[CreateSomethingRequest](r)

```

Entre `Gin` et `net/http`, je vois moins un duel idéologique qu’un arbitrage de contexte.
J’ai choisi Gin d’abord pour réduire le code de plomberie. Aujourd’hui, il reste mon choix par défaut surtout parce qu’il est maîtrisé par les équipes. Pour un nouveau projet, je pourrais m’en écarter si la performance brute ou l’indépendance vis-à-vis du routeur devenait un objectif central.

Le point que je ferais le plus volontiers évoluer aujourd’hui est la configuration. S’appuyer directement sur `os.Getenv` complique les tests parallèles et rend cette couche plus rigide qu’elle ne devrait l’être. Avec le recul, une récupération injectable de la configuration me paraît plus propre. Son approche à base de fonction de type `func(string) string` qui sert à récupérer la config résout simplement le problème.

J'ai utilisé une méthode intermédiaire, un `config.GetConfig()`, mais qui utilise encore les `os.Getenv` et qui à la fin n'apporte pas grand-chose, à part de (mal) centraliser la gestion de la configuration.

Tous ces ajustements m’ont peu à peu conduit à une réflexion plus large sur ma manière d’écrire du Go.

Avec les années, j’ai cessé de chercher le *bon* layout Go. Je cherche désormais quelque chose de plus exigeant : une manière de coder et d’organiser un service qui reste lisible, testable et maintenable quand le projet grandit, que l’équipe change et que la production commence à répondre.
Et si la vraie maturité en Go consistait moins à appliquer des recettes qu’à choisir lucidement les compromis que son code devra supporter dans le temps ?

[^1]: Certaines personnes trouvent plus logique de mettre les modèles dans les sous-répertoires des entités à côté du `repository.go` et du `service.go`.

[^2]: Les mocks ont toujours leur utilité, pour se substituer à des services externes très lourds ou simuler des erreurs réseau. Mais les conteneurs sont généralement la voie la plus simple et rapide actuellement, comme le montre l'essor de modules comme `testcontainer-go`

[^3]: Je peux même autodocumenter mon Makefile

    ```Makefile
    ## help: display this usage
    help:
	    @echo 'Usage:'
	    @echo ${MAKEFILE_LIST}
	    @sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
    ```