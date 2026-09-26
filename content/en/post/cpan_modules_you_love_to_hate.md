+++
author = "Arnaud ASSAD"
date = "2011-06-20"
description = "Dependency bloat is not about the number of dependencies: it is about functional duplication voiding the very benefits of code reuse."
title = "CPAN modules you love to hate"
linktitle = "cpan_modules_you_love_to_hate"
type = "post"
tags = ["Perl", "CPAN", "dependencies"]
categories = ["Article"]
aliases = ["/2011/06/cpan-modules-you-love-to-hate-or.html"]
+++

*Originally published in June 2011 on my previous blog. Fifteen years later the language has changed, the problem has not.*

If one thing starts to bother me in the Perl universe, it's all the dependencies which force you to pull half of the CPAN each time you try to install a major module.

Don't get me wrong: I love Perl, I love CPAN, I love modules and I definitively love code reuse BUT may be we start doing it the wrong way.

Let's think why we need code reuse:

1. Because we're lazy (as every good Perl programmer :-) ) and don't want to rewrite an existing wheel (if a good one already exist)
2. Because it reduces the code size by factorizing common parts

The factorizing aspect is especially important to me:

* Common parts (modules) are more tested as more users eventually use them
* Code is easier to maintain (smaller, less heterogeneous...)
* It forces us to think about the API, which eases enhancements

Now if I look at the dependency mess on CPAN, I realize that what's is bothering me is not the numerous dependencies, but rather that most of them void/lesser the benefits of code reuse.

Why must I use 3 different XML SAX parsers?

Why must I use 3 different Serializer modules?

Must I really use 2 different dispatch modules?

Can't I just use one error/handling module?

I wholeheartedly adhere to the TIMTOWTDI motto, but the more I use CPAN modules the more I get functional duplication code: My applications get globally bigger, more complex, heterogeneous, less tested than it could be...

What a paradox!

I'm calling to your wisdom: am I the only one to feel this dependency bloat?

Do you see any path to a more efficient Modules use?
