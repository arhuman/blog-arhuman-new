+++
title = "Compressing time to compress logs"
type = "post"
date = '2026-05-16T01:38:37+01:00'
categories = ["Article"]
tags = ["metarc", "metacompression"]
translationKey = "compressing_time"
+++

This morning, I had fun compressing time.

But before you picture me as a theoretical physics genius or a crackpot in need of a straitjacket, let me explain.

I am currently working on [Metarc](https://github.com/arhuman/metarc-go), a *metacompression* tool (understand: applying smart transformations to certain structures before handing off to a classical compressor like `zstd`). If you have never heard the term, you will understand in 5 minutes. If you are a compression expert; hang on, you might find food for debate.

Dates are a great playground for understanding this idea: they look like text, but they actually contain a very dense structure that can be exploited.

Spoiler: by exploiting this structure, `Metarc` can achieve compression gains of up to 26.5% compared to `tar+zstd`.

## What general-purpose compressors don't see in dates

The subject of my exploration this morning was therefore the compression of dates and time.

More specifically, I was trying to reduce the space taken in a text file by a date such as:

`2026-05-11 10:36:19` (19 bytes of text) into a more compact form.

General-purpose compressors work at the byte stream level. For them, `2026-05-11 10:36:19` is not fundamentally a date: it is a sequence of characters.

They can exploit pattern repetitions, but not the fact that this string represents a precise instant, with a known structure: year, month, day, hour, minute, second.

This difference in perspective changes everything. Where a general-purpose compressor sees a string of characters, `Metarc` can recognize a structure: an instant, a format, sometimes a timezone, sometimes a precision in milliseconds or nanoseconds.

But to prove it, I needed a realistic test set...

## Log files as an experimentation ground

To test this idea, log files were the obvious ground. They contain many dates, in various formats, with a very concrete constraint: you must be able to restore exactly the original text.

Effectively compressing a date while keeping enough information to restore it in its original textual format imposes three constraints:
1) Limit the complexity of detection/compression.
2) Minimize the size of format metadata.
3) Compress the most frequent formats first.

The last point is crucial: the more formats I support, the more information I must store to distinguish them. Up to 256 formats, one byte is enough. Beyond that, two are needed. The size/variety trade-off is permanent.

While looking for the most common formats on my laptop (RFC 3339, ISO 8601, MacOS), I quickly understood that the standards hid a forest of variants. My list quickly turned into a Prévert-style inventory:

* ISO 8601 with nanoseconds UTC
* ISO 8601 UTC
* ISO 8601 with offset
* RFC 3339 with nanoseconds and offset
* ...

To validate the principle, no need to be exhaustive: a sufficiently widespread reduced subset should allow compression on most encountered cases.

From there, the transformation applied by `Metarc` can be understood in three steps.

## Step 1 — Reduce the instant: from text to timestamp

A dated moment is a point on a timeline. If you choose an origin, in computing often January 1st 1970, it can be represented by a simple distance to that origin.

Thus, the date 2026-05-11 10:36:19 in Paris (summer time) is exactly 1778488579 seconds away from January 1st 1970. In computing, this instant can be represented by a Unix timestamp.

`Metarc` encodes the instant in fixed numeric form on 8 bytes, with a granularity sufficient for the modern log formats targeted. With 8 bytes the gain is spectacular: we transform a textual string of 19 bytes into a fixed numeric block of 8 bytes, even if the date appears only once in the file.

This has two important consequences for *metacompression*:
1) Part of the gain comes from understanding the structure, not just from repetition.
2) Unlike classical statistical compression, a unique date can already be reduced efficiently.

## Step 2 — Restore exactly: the format problem

At this stage, we have only solved half of the problem. Because the instant can be represented in a multitude of formats.

Depending on the context, the same date can be written in dozens of ways:

* 2026-05-11 10:36:19
* Mon May 11 10:36:19 2026
* 11/May/2026:10:36:19
* 2026/05/11T10:36:19Z
* ...

Not to mention timezones, milliseconds or nanoseconds.

In reality the number of possible formats is almost infinite. To restore the date identically, I must therefore store both the timestamp **and** enough information about the format.

The trade-off is therefore permanent: detect/encode fast, store little and remain more compact than the original date.

The first versions worked well... but not always better than zstd alone. This finding forced me to dig deeper.

## Step 3 — Helping zstd: ordering bytes by their entropy

Once the timestamp and the format were encoded, a problem remained in the structure of the compressed format: the order of the bytes.

```
[0x00][fmt_byte][uint64 timestamp][int16 tz_min][uint8 subsec_digits]
\__ Low ___/    \___ HIGH ___/    \___________ Low ________________/
```

By reorganizing the format to group low entropy[^1] at the beginning, we create a repetitive string much longer that `zstd` can compress better:

```
[0x00][fmt_byte][int16 tz_min][uint8 subsec_digits][uint64 timestamp]
\____________________ Low ________________________/ \___ HIGH ___/
```

**Metacompression acts here doubly: by compressing the date and by optimizing the byte ordering for further compression by `zstd`. It is the knowledge of the structure (what changes a lot and what changes little) that enables this double gain.**

The first tests confirmed that this simple modification improved the final compression by `zstd`.

The principle being validated, all that remained was to optimize *metacompression*, by increasing the number of recognized formats and trying to reduce the size of the format information.

Reducing the size of format information is more of an optimization matter:
For some variants storing a timezone is useless and rather than using the generic format `[0x00][fmt_byte][int16 tz_min][uint8 subsec_digits][uint64 timestamp]`, `[0x00][fmt_byte][uint64 timestamp]` is enough, saving 3 bytes per date.

I also extended the idea to delimiters (', "), with two extra characters encoded at no cost, even on a unique date, and without penalty for `zstd`.

## Results: up to 26.5% gain on Loghub

For my tests, I used a corpus that contains real log files produced by standard software: [loghub](https://github.com/logpai/loghub/tree/dd61d0952749ee7963bde24220d1be5ede023033).

On this Loghub corpus, with the formats currently recognized by `log-date-subst/v2`, `Metarc` gains up to 26.5% compared to `tar+zstd`. On unrecognized formats, the gain is logically 0%.

Here are the results after compression by `tar+zstd` (`tar --zstd -cvf xxx.tar.zstd xxx`) and Metarc (`marc archive xxx.marc xxx`).

> [!NOTE]
> Metarc archives files by applying metacompression transformations and then compresses with zstd by default, which is why comparisons are made with tar + zstd.


| Dataset | Directory size | tar+zstd size | Metarc size | Metacompression benefit |
|---|---:|---:|---:|---:|
| Mac | 844K | 136K | 100K | 26.5% |
| OpenStack | 1.3M | 136K | 104K | 23.5% |
| BGL | 776K | 136K | 116K | 14.7% |
| HDFS | 708K | 136K | 112K | 17.6% |
| Spark | 500K | 36K | 32K | 11.1% |
| OpenSSH | 580K | 40K | 36K | 10.0% |
| HealthApp | 472K | 44K | 40K | 9.1% |
| Android | 736K | 52K | 48K | 7.7% |
| Zookeeper | 648K | 52K | 48K | 7.7% |
| Apache | 432K | 28K | 28K | 0.0% |
| Hadoop | 920K | 44K | 44K | 0.0% |
| HPC | 372K | 56K | 56K | 0.0% |
| Linux | 548K | 36K | 36K | 0.0% |
| Proxifier | 592K | 52K | 52K | 0.0% |
| Thunderbird | 768K | 64K | 64K | 0.0% |
| Windows | 684K | 32K | 32K | 0.0% |

**For recognized formats** the size gain brought by metacompression is **14% on average.**

You can check the detail of the gain per archive with the `--explain` flag.

```
time marc archive --explain mac.marc Mac

--- Plan Summary ---
Total entries:      4
Transforms applied: 1
Estimated gain:     104.0 KB

Breakdown by transform:
  log-date-subst/v2        1 applied      0 skipped  ~104.0 KB saved
  raw                      0 applied      3 skipped  ~0 B saved

marc archive --explain mac.marc Mac  0.10s user 0.01s system 99% cpu 0.111 total
```

## (All) That remains to be improved

Implementing more formats without degrading performance remains an obvious axis for improvement.

Adding a format can sometimes come down to encoding a simple variant, such as the date separator (/ or -). But more often, it requires detecting a new pattern in a new set of log files. The real work is therefore to broaden coverage without blowing up the detection cost.

But there are also still many optimizations to implement and new gains to find.

For example, I will probably fragment the compressed storage formats to optimize each format: no point, for instance, keeping timestamps in uint64 format for formats that do not need nanoseconds.

## The quintessence of metacompression

The real result of this exploration is not, for me, the average 14% compression gain obtained.

The interest of date compression is that it illustrates *metacompression* in its most complete form: **An upstream compression that adds to and optimizes the downstream byte stream compression**.

That was `Metarc`'s bet: compress the structure before compressing the bytes.

The next step will not play out on a hand-picked example, but on your real data: code repositories, logs, technical archives, heterogeneous corpora.
That is how an intuition becomes a tool.

Try `Metarc`, compare it to `tar+zstd`, and [share your results](https://github.com/arhuman/metarc-go/issues/new?template=feedback.md).

And if you like the concept of metacompression and want to give the project some visibility, add a ⭐️ to [Metarc](https://github.com/arhuman/metarc-go) on GitHub.


[^1]: Shannon's information theory establishes that low-entropy data (repetitive, structured) can be heavily compressed, unlike high-entropy data (changing, random...)

---
*(AI translated from French)*
