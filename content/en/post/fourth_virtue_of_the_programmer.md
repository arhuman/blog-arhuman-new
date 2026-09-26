+++
author = "Arnaud ASSAD"
date = "2018-07-25"
description = "Larry Wall named laziness, impatience and hubris. The fourth virtue that actually makes you productive is consistency: in rhythm, style, tests, process and automation."
title = "The fourth virtue of the programmer"
linktitle = "fourth_virtue_of_the_programmer"
type = "post"
tags = ["Programming", "Productivity", "Perl"]
categories = ["Article"]
aliases = ["/2018/07/the-fourth-virtue-of-programmer.html"]
+++

*Originally published in July 2018 on my previous blog, and cross-posted on [Medium](https://medium.com/@arhuman/the-fourth-virtue-of-the-programmer-e1043fbb2646).*

Larry Wall once wrote "The three great virtue of the programmer are: laziness, impatience, and hubris". I took great care to follow this path to become a programmer. Though I must admit I already had great disposition for laziness.

Now, as an accomplished programmer (*cough* hubris *cough*), I think it's time to improve further. I've search for a loooooooong time. And after a week of thinking (*cough* impatience *cough*) I've decided to talk to you about the fourth virtue of the programmer.

The fourth virtue that'll make you a more productive programmer is **consistency**.

Let me show you in this article how to apply consistency for your profit easily (*cough* laziness *cough*).

## Find your rhythm and stick to it

Your mileage may vary, but for most people, being consistent in the time you allocate to a project/task will boost your productivity.

Don't take my word for it, but make an experience:

* Code one day a week on a project for one month.
* Code 1h a day for one month on another project.

On which one will you be the most productive?

Even if some tasks are hard to do in one hour, I bet a consistent work will boost your enthusiasm, ease your work and in the end make you more efficient.

Of course you probably work on several project at a time, and external factors might break your chosen rhythm. But as long as you try to be regular in your work you should see improvements.

## Find your style and stick to it

Consistency in the way you write your code is a well known quality metric: It improves readability, ease the maintenance/evolution and reduce the probability of bugs.

If choosing the coding style was easy when I was coding in Perl (Larry Wall then Damien Conway paved the way) it can be much difficult depending on your language of choice: The choice is not the same for a JavaScript/PHP programmer or a Python/Go programmer.

But whatever the abundance of choice or not, it doesn't really matter what style you pick as long as you pick one coding style.

And once you're picked one, ensure you enforce it in your usual editor.

(It's just a matter of few lines in my vim config file to have the airbnb style enforced on all my javascript files or gofmt run on my Go file)

## Ensure you have consistent goal and consistent results

Use tests!

Let's say the truth: Testing is our dark little secret, we wish we'd do it more, but in dark repositories that we don't make public there are stills many places where a test directory is missing.

However we all know that the tests is the minimal architectural work we have to do: How can we achieve our goals if we don't define them?

We all know that tests are the required safety net to refactor our code with confidence.

So stop beating about the bush, choose your framework and use it in all of your projects.

## Be consistent in your process

We all have some habits/tricks that make us more efficient. As soon as you've found one, use it consistently.

For example, I try to drop a `LAB_BOOK.txt` file in my working directories, to store tips/hints related to the current project: It can be as simple as basic commands to start/stop services, or command line examples of some unusual tools or data/steps to test/improve my code. It might seem useless, but those files prevent me from wasting precious time when I get back to a project after a long halt. Being consistent in the use and the naming of this file is what prevent me from wasting time.

I also try to store whenever possible all the private data (login/pass/ports...) in a separate file named the same way across my repos to have it protected from unwanted disclosure (thanks to specifically modified `.gitignore`).

We all have coding habits: whatever the way you work with your SCM, name your file, organize your repositories, document your project, try to be consistent; it will save you time and fatigue.

I was not a big fan of generators until lately where I realized how yeoman could be used to enforce most of the above mentioned good practices.

I'm still working on it, but having default layouts for my project is definitely a good way to boost productivity by reducing the initial friction and improving overall quality.

## Be consistent in applying what you've decided

Once you've found a good practice: automate it!

Your tool will never forget, will never be lazy, will never make an hazardous change and will never forgive :)

Your SCM hooks can be handy to autoupdate the Changefile or do some testing.

Common operations on files (conversion, generation) should be scripted.

In fact if you've done the same simple task more than 2 times, you probably should script it.

## Conclusion

I hope this rant will give you ideas to improve your coding habits. As usual I'd be glad to have your feedback/comment/suggestion on the topic. Don't hesitate to leave a comment or contact me by mail (arhuman (at) gmail dot com)
