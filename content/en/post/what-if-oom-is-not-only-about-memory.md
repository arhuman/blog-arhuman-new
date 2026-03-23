+++
date = '2026-03-20T15:24:26+01:00'
title = "What if your OOM was not just a memory problem?"
categories = ["Article"]
tags = ["Software Development", "Go", "Bug"]
+++

Sometimes an investigation tells a different story than the one you expected.

That's what happened to me recently while investigating why a pod was ending up OOMKilled two to three times a day.

A quick look at the memory of the incriminated pod doesn't show the typical rising curve of a memory leak. I'm missing data just before the OOM (because it's always when your metrics system is migrating that this kind of incident happens), but with the day's data, the cause seems to lie elsewhere.

No matter, I can still start with a static analysis of the code to find the usual suspects:

An unclosed `resp.Body`:

```go
resp, err := client.Do(req)
if err != nil {
		fmt.Printf("error calling %s: %s", url, err.Error())
		return nil, resp, err
}
```

The omission is impactful here in a particular case, resp AND err both non-nil, which reduces its frequency. That's probably why it flies under the radar of memory observation. But it still means a file descriptor, several buffers, and connection control structures that are not freed each time.

An `io.ReadAll` without a limit:

```go
resBytes, err := io.ReadAll(resp.Body)
```

Unnecessary heap allocations.

Unnecessary allocations due to serialization of complex structures for logging:

```go
// claimsRoot is a complex structure that will be encoded for the log
Log.Info("", zap.Any("claims", claimsRoot))
```

Or through mass reallocations with slices that keep growing:

```go
var slice []string
for _, v := range source {
	slice = append(slice, v)
}
```

None of these points, taken alone, explained such violent OOM crashes.

And then I stumbled upon an insignificant detail.
A `ctx.Next()` called a second time at the end of the logging middleware.
A mundane line. A massive bug.

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

Bad copy-paste or force of habit, either way, this code compiles and ran with the effect of calling resource-intensive endpoints twice.

An amplifier bug!

And among the endpoints wrapped by this middleware, two of them call a method that launches a goroutine:

```go
func (s Service) GetUserInfo(appContext api.Context, userID string) (...) {

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	...
}
```

And if the method/goroutine uses a context, as you should for all long and cancellable operations, it does so without inheriting the parent context from the handler.
In this case, even if the user cancels their request or if upstream it was a second away from its timeout, the goroutine will here still run for up to 15 seconds.

Taken in isolation, this is not dramatic: after 15 seconds, the timeout eventually frees up resources.
Under heavy load, it's a different story. At several hundred requests per second, these goroutines accumulate faster than they disappear.
Each with its stack, its buffers, its memory structures…

And speaking of memory structures: the goroutine feeds a structure via an external call using a filter to do its processing. By bad luck, the filter is misconfigured and 20 to 30% of useless data is loaded into memory for processing. It's a purely logical bug, but it simply wastes 20% of memory and CPU.

```go
info, err = toolbox_api.GetInfo(userId, "", make(map[string]string))

// instead of the call with a populated filter
info, err = toolbox_api.GetInfo(userId, "", map[string]string{"state": "active"})
```

All of this combined gives us a good recipe for degradation under heavy load:

The middleware doubles the work done. Goroutines then continue to accumulate over a 15-second window, each processing 20% oversized data.
Result: more allocations, more CPU, more GC pressure, so a system that slows down… and worsens this accumulation even further.

But for a full disaster, one more amplifier was still needed (or maybe not) and we get it from the fact that the incriminated endpoints each launch 4 goroutines.
So we end up, no matter what, with four times more goroutines liable to accumulate, accentuating memory consumption, CPU, and GC pressure in a beautiful amplification loop that leads to OOM:

- x2 effective requests because of the middleware
- Each request launches 4 goroutines
- Goroutines live up to 15 s even if the request no longer makes sense
- They load 20–30% of useless data
- More allocations → more GC
- More GC + more CPU → slower processing
- Slower processing → more simultaneous goroutines
- More concurrency → OOM

To break this amplification loop, action was needed on three levers:

1. reduce unnecessary work,
2. better limit the lifetime of operations,
3. limit concurrency.

Concretely, here are the actions taken:

- Remove the double `ctx.Next()`
- Properly filter the data
- Add semaphores on goroutines for CPU/network gain: explicit backpressure via 503 rather than cascading timeouts
- Reduce timeouts to avoid accumulation effects
  (the sliding accumulation window related to timeouts being shorter)
- Use `io.LimitedReader` before `io.ReadAll`

```go
const maxResponseBodySize = 1 * 1024 * 1024 // 1MB
limited := &io.LimitedReader{R: resp.Body, N: maxResponseBodySize + 1}
resBytes, err := io.ReadAll(limited)
if limited.N == 0 {
	return nil, resp, fmt.Errorf("response body exceeded %d bytes limit", maxResponseBodySize)
}
```

- Reduce log volume and associated allocations
- Pre-allocate slices before the loop when the size is known

```go
slice = make([]string, 0, len(source))
```

While we're at it, complete with pod memory tuning (which were undersized to handle peaks in the first place), and add a GOMEMLIMIT at 85% of max memory.

Several lessons can be drawn from this incident, but for my part I will mainly remember that this OOM is almost a textbook case: this pod was not dying from a simple memory leak. It was dying from a system that was doing too much work, for too long, with too much concurrency, to process too much useless data.

And if, as a savvy reader, you're wondering why I didn't simply use pprof to identify these problems earlier... the answer deserves an article of its own. Spoiler: the reason is not technical.

---

*(article automatically translated with Sonnet 4.6)*
