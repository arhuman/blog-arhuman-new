+++
author = "Arnaud (Arhuman) ASSAD"
date = "2020-06-02"
lastmod = "2026-09-08"
translationKey = "tdd_secret_weapon"
description = "Why write tests first? The ignored advantage of test driven development, beyond code coverage and the endless is-TDD-dead debates."
thumbnail = "img/ferenc-almasi-EWLHA4T-mso-unsplash.jpg"
linktitle = "TDD's Ignored Advantage"
title = "TDD's Ignored Advantage"
type = "post"
tags = ["TDD", "test driven development", "test", "tests", "development"]
categories = ["Article"]
draft = false

+++

Lately, chance has had me hearing a lot about Test Driven Development.

Often around the old "TDD is dead" theme (https://dhh.dk/2014/tdd-is-dead-long-live-testing.html) and with the same questions resurfacing:

* *What is the definition of the different types of tests?*
* *What is the ideal code coverage percentage?*
* *How do you handle flaky tests? Slow tests?*

And if I address these questions quickly today, it is more for completeness than out of real interest.
These questions are not specific to TDD; they are common to software testing as a whole.

For TDD, the questions worth asking are these:

* *Why write the tests **first**, before any code?*
* *What does TDD bring beyond the technical?*

That last question is the one that touches the main advantage of TDD over other testing methodologies.

But before we get there, let's clear up a few points.

## Test driven development in a nutshell

For those discovering it: Test Driven Development (TDD) is a development method in three steps, the famous red/green/refactor loop:

1. **Red**: write a failing test that describes the expected behavior.
2. **Green**: write the minimal code that makes this test pass.
3. **Refactor**: improve the code, protected by the test.

Nothing more. And if you have come across the phrase "development driven testing", it is most often an accidental inversion: the test drives the development, not the other way around.

## The different types of tests

No serious discussion about software testing will ever escape the debate around the definition of the different types of tests: *What is a unit test? An integration test? A functional test?*

While most people agree to define unit tests as "the tests verifying the correct behavior of a specific part of a program, called a unit", their scope varies with interpretations and contexts: *Is your unit a class? A module or a library? A function?*

And if the definition of unit tests seems subjective to you, what about integration tests? The most consensual "definition" of integration tests I could give would be: the tests making more than one unit of code interact at the same time.

So it becomes simple: if it touches only one component it is a unit test, and if I have to test the interaction of at least 2 components (ideally unit-tested in parallel), it becomes integration. A simple example would be a test involving a database component and a computation component.

*And functional tests, then?*

That would be a test verifying a functional scenario (as opposed to a technical one) end to end: testing the placement of an order, for example.

Clearly that requires testing more than an integration test that merely stores an order in the database.

Now, even if we agree on these definitions, and many could rightly propose better ones, it will not always be obvious to draw the line between, say, a simple functional test and a complex integration test.

For my part, I have chosen to give these definitions only relative importance.
I do not care about the name or category of the test I wrote, as long as it does its job: verifying that my program works, as efficiently as possible.

## What is the ideal code coverage percentage?

*What percentage of code should be verified by tests? 100%?*

Most people, and I am one of them, agree that it is not necessarily desirable, and that even if we should tend toward that number, there is a threshold where the game is probably no longer worth the candle.

*Should we really test every error case? If I really must test *all* error cases, even the most improbable ones, how do I trigger or simulate them? How do I do it without making my tests flaky?* And more importantly, *in that scenario, does 100% coverage really mean 100% of cases tested?*

Everyone has their own answer to these questions, but let me remind you of something.

Take the file article.go

``` Go
package mylib

func Divide(a int, b int) int {
        return a / b
}
```

And the associated test file article_test.go

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

It is easy to verify that code coverage is 100%

```
$ go test -cover
PASS
coverage: 100.0% of statements
ok   _/home/arnaud/article.go 0.001s

```
But have we tested 100% of the cases?

Obviously not. Nobody will have missed that calling our function with 0 as the second argument will produce a behavior that was visibly not anticipated.

That is why the coverage percentage must be nothing more than an indicator, certainly not a goal, and not even a guarantee.

To be honest, I only use it as a metric to track how coverage evolves, but it is on the basis of a much more subjective feeling of "quality" of the test suite that I decide whether my test suite is complete or not.

## How to handle flaky tests? Slow tests?

If you have written or run a substantial number of tests, you have inevitably run into a flaky test, a test that seems to give irregular results. Whether it is caused by a race condition, network latency or an unidentified dependency, this test can sometimes return a wrong result for no reason, while working perfectly most of the time.

You have also probably cursed the time lost running them (except these two guys https://www.xkcd.com/303/)

I tend to address these 2 quite different problems the same way, because in the end they have the same effect: they reduce the attractiveness of my test suite (one by eroding the trust I have in it, the other by making its use more unpleasant).

For my test suite to remain my best ally, it must be reliable and fast, so that I do not hesitate a second to use it as often as possible to make sure the quality of my code has not degraded.

So rather than giving up on slow or flaky tests, I split the difference: I move them into a part of my test suite that is not run systematically (only when I set a specific environment variable) but that I can run whenever I want slower or more exhaustive, though potentially less reliable, tests.

That does not prevent me from also working to improve them, making them faster and/or less flaky[^1], but pragmatism pushes me to put my effort where the benefits are greatest, and from that perspective slow or flaky tests are rarely a priority.
[^1]: A horrible but terribly effective generic approach for some flaky tests is to run them several times and take the "statistical" result.

## Why write the tests *before the code*?

The first law of TDD is "You must write a failing test before you can write the corresponding code."

*What is the point? Forcing you to write a test for every piece of code?*

Yes, obviously, with the long-term goal of having enough tests to let you refactor your code with a safety net, flagging regressions and introduced bugs.

That is actually why I started TDD: the assurance of seeing my code quality improve was a promise I could verify quickly. But indirectly, having to write the test before the code forces us to write testable code, with all the benefits that follow.

Code designed to be testable is often more atomic, more modular, with less coupling than code that is not.

*Forcing you to think ahead about how your code is supposed to work?*

Obviously the tests simply capture the basis of that behavioral contract, which constitutes the component's API and the basis of its documentation, and thinking about it up front guarantees that this work will always be done.

*What else?*

The reasons mentioned above, widely accepted, justify the use of TDD on their own. But over time I realized that the main benefit for me is something else entirely, more subtle but far more impactful: **TDD does not only have a qualitative impact, it has above all a psychological one.**

Give me a few minutes to explain before you frown.

Being able to write the best possible code is useless if you do not write it. Many authors know this well, stuck in front of a blank page.

And even if developers do not necessarily suffer that kind of block, I have observed throughout my career a friction zone at the start of a project. Often the developer (yours truly included) does not know which end to grab the project by; even when specifications exist, the first blocks of code are the hardest to write.

>"A beginning is the time for taking the most delicate care" -- Frank Herbert (Dune)

Test first is a framework that frees you from that resistance:

The test is a step, simple and reassuring, that initiates the movement. It calls for another equally simple step that sustains the movement and brings us closer to our destination.

The image of movement is chosen on purpose, because velocity is how you can verify the psychological impact of test first: you get into the project faster, you produce code faster.

Even when the project is well underway, the test suite sustains that velocity. Where a coder without a test suite will hesitate to fix, improve or extend their code for fear of breaking everything, a TDD practitioner, reassured by the ability of their test suite to flag regressions, will not slow down the rhythm of their red/green/refactor loops and will keep producing more code.

It is a virtuous circle: the more tests you write, the faster you go and the more confident you are, so the more code you can write, and therefore more tests...

The code coverage percentage keeps rising, reinforcing that feeling of confidence, attesting not to the quality of the code but at least to its improvement.

Even those who suffer from impostor syndrome, and they are numerous among the coders I have met, see in it not an absolute indication of their talent (that would be too easy...) but the certainty and the comfort of watching their code quality rise toward the levels they imagine to be the norm.

Years later, this psychological dimension of development remains at the heart of my thinking: [What if your technical debt was not a technical problem?](/post/what-if-tech-is-not-the-answer/) (in French) and [The code works. But is it any good?](/post/code_audit/) (in French) are its direct continuations.
