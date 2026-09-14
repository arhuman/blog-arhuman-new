+++
date = '2026-09-13T10:30:00+02:00'
title = "The Logging Dilemma"
description = "Drowning in logs when everything is fine, or doomed to miss them during an incident. You no longer have to choose: dynamic level gives you the best of both approaches."
categories = ["Article"]
tags = ["Software Development", "Go", "Logging", "dllog"]
translationKey = "log_dilemma"
+++

Every developer has lived through this scene: the adrenaline spike when a production incident is announced. That mix of dread about what you are going to find and frenzy to collect any piece of information that will let you understand and then fix the problem. It happened to me again a few days ago. I can still picture myself rushing to the logs, and I still remember the frustration of finding nothing but basic information and an unhelpful error message: "Unable to load cache".

Frustration quickly gave way to anger: we had lowered the log level a few months earlier, tired of being drowned day after day in debug logs telling us that everything was fine, that our probes were connecting without trouble, and that the databases were returning their data just fine.

Drowning in logs when everything is fine, or doomed to miss them during an incident. This logging dilemma looked to me like a curse there was no escaping.

Of course, we had also put in place a hot toggle for the log level, reassured by the promise that the powerful filters of our logging tool would give us, once the level was switched to debug, all the information needed to resolve an incident.
But raising the log level after the fact is sometimes a bad bet, especially when the error is tied to a temporal context (load spike, database backup, and so on), because it then becomes difficult or even impossible to reproduce the error in order to collect the information in the logs.
And that is without mentioning the small operational frictions which, while not blocking, slow down reproduction, understanding, and therefore the fix: how do you identify the right pod on which to raise the log level? How do you handle the security of the toggle endpoints? How do you make their semantics clear: does /log/increase raise the log level or the log verbosity? Does /log/increase move the level toward error or toward debug?
In hindsight, the verdict is clear: the dynamic toggle is an improvement, but not the solution for our use case.

All the more so because the powerful filters do not solve the problem, at best they soften it: with more debug logs, I have the information about the incident, but it stays buried in all the noise of unrelated debug information. Looking for one very specific needle in a haystack does not fundamentally change the nature or the difficulty of the task.

**The real problem is that you have to decide before the incident which logs deserve to be kept, when you only find out afterwards which ones were actually useful.**

Hence the idea of a "dynamic" per-operation level, implemented by [dllog](https://github.com/arhuman/dllog) (that is the DL, Dynamic Level, in dllog):
error logs retroactively change the log level to reveal the debug logs that preceded them.
When everything is fine you only see the logs at the current level (Info, for example), but in case of an error the Debug-level logs before and after the error are displayed as well.

In principle, you just plug into the existing logger (slog or zap for now):

```go
logger := slog.New(dllog.NewJSON(os.Stderr))
slog.SetDefault(logger)

mux := http.NewServeMux()
mux.HandleFunc("/order", func(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Buffered: invisible if the request succeeds.
	slog.DebugContext(ctx, "loading cart", "user", 42)
	slog.DebugContext(ctx, "applying discount", "code", "SUMMER")

	// An Error record first replays everything buffered above.
	slog.ErrorContext(ctx, "payment declined", "provider", "stripe")

	w.WriteHeader(http.StatusInternalServerError)
})

// The middleware opens one scope per request, triggering the replay on 5xx and on panic.
http.ListenAndServe(":8080", dllog.Middleware()(mux))
```

For the implementation, you have to watch out for performance and for the various concurrency issues:
* Circular buffers
* sync.Pool
* Lock-free operations
* Deferred formatting
* ...

The result is something usable:

![slog at Info](/img/demo-info.gif)
![dllog at Info](/img/demo-dllog.gif)
![slog at Debug](/img/demo-debug.gif)

The difference is striking: less noise when everything is fine, but the useful context when things break. The payoff: potentially fewer logs to store, and above all less time wasted understanding the incident.

So this curse was not inevitable after all. That is what I love about my job: there are always paths to explore outside of habits and near-certainties, and those paths are sometimes surprisingly effective.

*Translated from french by AI*
