+++
author = "Arnaud ASSAD"
date = "2016-07-06"
description = "Functional programming in JavaScript seen by a Perl coder: why Ramda's auto-currying and data-last design make composition explode, and where to look next."
title = "The devil codes in Pramda"
linktitle = "the_devil_codes_in_pramda"
type = "post"
tags = ["JavaScript", "Perl", "functional programming"]
categories = ["Article"]
aliases = ["/2016/07/the-devil-codes-in-pramda-wandering-in.html"]
+++

*Originally published in July 2016 on [Hello.js](https://blog.hellojs.org/the-devil-codes-in-pramda-wandering-in-the-javascript-functional-programming-world-17fc3bf93def), then on my previous blog.*

As a Perl coder, I'm a big fan of functional programming.

If that sounds odd to you, think about all that features that are considered as idiomatic Perl:

* List processing (map, grep)
* High order functions (Mark Jason Dominus ;-) )
* Lazy evaluation (iterators)
* Lamda calculus (closure)

Functional programming is a fascinating thing but it's not so easy to use consistently. We all love the concept, feel the inner power. We all use lists, closure, functions as parameter, but how many of us manage to fully apply functional programming everywhere and commit to pure functions and immutability?

I recently discovered a wonderful library for functional programming in JavaScript that could help you embrace functional programming even more and I'd like to share it with you: it's called [Ramda](http://ramdajs.com/).

There are several other functional programming libraries (more on that below) but what makes Ramda so practical and somewhat unique is its combination of auto-currying and the design choice to put the data last. These two things empower you and give you endless possibilities through composition.

You probably already know how map and grep can compose to solve many different tasks in a clean way. Now imagine that Ramda offers you one hundred of such functions. The number of combinations, solutions and tasks that you can solve easily just explodes! [^1]

This might seem theoretical, but for a simple demonstration of how Ramda can ease your life, just read ["Why Ramda?"](http://fr.umio.us/why-ramda/) by Scott Sauyet.

Among the other things that make Ramda so powerful, is its ability to mix with promises through `pipeP` and `composeP`. Being able to use both functional programing and promises through a clean syntax is priceless to me.

I should also underline the fact that Ramda promotes immutability: it doesn't mutate input data by default but still allows you to produce modified one through `assoc`.

As a final note: Don't be scared by Ramda's API, it offers probably far more than you want, but everything you need. Follow the easy path: just pick/learn functions one by one.

## Going further

That being said, it would be unfair to limit functional programing in JavaScript to Ramda. If you'd like go further and explore the domain, here are some other projects that I'd suggest to examine:

The well known 'generic' libraries offer functional tools, like the venerable [underscore](http://underscorejs.org/), [lodash](https://lodash.com/) and it's speedy brother [lazy](http://danieltao.com/lazy.js/) to name a few.

The reactive programming world also provide functional features with [RxJs](https://github.com/Reactive-Extensions/RxJS), [Kefir](https://rpominov.github.io/kefir/) or [Bacon](https://baconjs.github.io/) for the UI.

And if you want to experiment immutability, the choice is your: You can climb on the shoulders of a giant and use Facebook's [immutable](https://github.com/facebook/immutable-js/) or favour speed with [mori](https://github.com/swannodette/mori) or try the frozen object approach of [icepick](https://github.com/aearly/icepick).

In a future article I'd like to talk about my current favourite youtube tech channel: ['funfunfunction'](https://www.youtube.com/channel/UCO1cgjhGzsSYb1rsB4bFe4Q) so stay tuned! It's a really great channel about functional programing, JavaScript and other topics of interest.

## PS

Oh, and if you wonder about the title:

I like Ramda so much that I wanted to use it in my daily work, and started to write a port in Perl: Pramda (Perl Ramda). Any resemblance to any film title is purely coincidental...

[^1]: Functions like [`transpose`](http://ramdajs.com/0.21.0/docs/#transpose), [`unfold`](http://ramdajs.com/0.21.0/docs/#unfold), [`times`](http://ramdajs.com/0.21.0/docs/#times), [`allPass`](http://ramdajs.com/0.21.0/docs/#allPass), [`cond`](http://ramdajs.com/0.21.0/docs/#cond) are the first examples that come to my mind, but I bet you'll learn to love the others while using Ramda.
