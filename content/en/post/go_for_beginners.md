+++
author = "Arnaud ASSAD"
date = "2018-02-01"
description = "The notes I gathered while setting up my first Go environment in 2018: install, workspace, GOPATH, editor configuration and a curated resource list."
title = "Go (Golang) for beginners"
linktitle = "go_for_beginners"
type = "post"
tags = ["Golang", "tutorial", "beginner"]
categories = ["Article"]
aliases = ["/2018/02/go-for-beginners.html"]
draft = true
+++

*Originally published in February 2018 on my previous blog. Kept as an archive: the setup below predates Go modules, so `GOPATH` and the manual workspace no longer reflect how you should start with Go today.*

Because I might not be the only newbie in the Go world this year, I've decided to document here all the information I gathered.

## Install Go

Go installation is pretty well documented on the [official Golang page](https://golang.org/doc/install) but it can be summarized to:

Downloading the binary matching your OS and architecture from [the golang download page](https://golang.org/dl/):

```
wget https://redirector.gvt1.com/edgedl/go/go1.9.2.linux-amd64.tar.gz
```

Extracting the software (`/usr/local/go` seems to be the recommended location):

```
tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz
```

Creating your workspace. The Go workspace is the place where you put your source code and where the go packages/tools will be downloaded:

```
mkdir $HOME/go
mkdir $HOME/go/src
```

Setting the environment variables: `GOPATH` points to your workspace, then extend your `PATH`.

```
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
```

For a system-wide configuration put it in `/etc/profile`, for a per user configuration in `~/.profile`.

## Editor configuration

If you use vim as I do, you might want to use [vim-go](https://github.com/fatih/vim-go) or [vim-polyglot](https://github.com/sheerun/vim-polyglot) and read [the vim-go tutorial](https://github.com/fatih/vim-go-tutorial).

But if it's not your case, your solution is probably on the [page about the IDEs and editor plugins for Go](https://github.com/golang/go/wiki/IDEsAndTextEditorPlugins).

## So much more to explore

With this (basic) setup I'm now ready to go further:

* Setting up Go in docker
* Do some datascience
* Unleashed goroutines/channels power

But that will be in another post :-)

## Resources

There are of course many more useful resources to start with. But I hope the following ones will be as useful to you as they were to me.

**Community**

* [The Go language official site](https://golang.org/)
* [The Go forum](https://forum.golangbridge.org/)
* [Gophers Slack channel](https://invite.slack.golangbridge.org/)
* [The Go wiki](https://github.com/golang/go/wiki)

**Documentation**

* [GoDoc](https://godoc.org/)
* [Standard library documentation](https://golang.org/pkg/#stdlib)
* [A curated list of awesome Go frameworks/librairies/softwares](https://awesome-go.com/)
* [Go tooling for datascience](https://github.com/gopherdata/resources/blob/master/tooling/README.md)
* [Go FAQ](https://golang.org/doc/faq)
* [Go proverbs](https://go-proverbs.github.io/)

**Courses**

* [A tour of Go](https://tour.golang.org/)
* [Effective Go](https://golang.org/doc/effective_go.html)
* [Learn Go in Y minutes](https://learnxinyminutes.com/docs/go/)
* [Go by example](https://gobyexample.com/)
* [Common gotchas and mistakes in Go](http://devs.cloudimmunity.com/gotchas-and-common-mistakes-in-go-golang/)
* [Your basic Go](http://yourbasic.org/golang/)

**Podcast and video**

* [Just for func youtube channel](https://www.youtube.com/channel/UC_BzFbxG2za3bp5NRRRXJSw)
* [Go Time on changelog](https://changelog.com/gotime)
