+++
title = "Metacompression: compressing structure before bytes"
type = "post"
date = '2026-04-24T02:38:37+01:00'
categoriee = ["Article"]
tags = ["metacompression", "go", "metarc"]
translationKey="what_is_metacompression"
+++

## What if the real gain wasn't at the byte level?

I have always been fascinated by compression algorithms — I was 15 when I "invented" Run Length Encoding (before learning it had been discovered more than 20 years before I was born).  
I marveled at the visual simplicity of Huffman coding, at the cleverness of Lempel-Ziv which dynamically builds its dictionary.

These algorithms are powerful, and it is no coincidence that they are continuously improved and combined to produce ever more powerful new algorithms: `Brotli`, `zstd`.

But they all share the same philosophy: data is a stream of bytes.

> **Update — May 2026**
>
> Since the first version of this article, `Metarc` has moved to a different stage.
> Current benchmarks now show smaller archives than `tar+zstd`
> on every open-source repository tested.
>
> Metacompression is no longer just an intuition to validate:
> it is now a demonstrated approach within this scope — one that needs to be improved,
> hardened, and better characterized.

## Metacompression: compressing before the bytes

Metacompression exploits structures above the byte stream to prepare and amplify classical compression.

It is not limited to the meaning of data.  
It can also work on structures, relationships between files, line patterns...  
  
That is why the term metacompression seems more appropriate to me than "semantic compression".

## Why this changes everything

Working at a different level than the byte stream gives access to a much richer level of information, and therefore to compression levers inaccessible to the simple byte stream.

On certain types of directories with a lot of redundancy, we already observe better compression ratios than standard tools. Below are some results using [Metarc](https://github.com/arhuman/metarc-go) for metacompression:

```
6.5G	my_homedir (106442 files, mostly git repos)        
1.8G	my_homedir.tar.zst  72.3% compression
1.4G	my_homedir.marc     78.5% compression   <- Metacompression
```

Of course my home directory is not necessarily representative, but you can see for yourself the same compression ratios on a JavaScript directory backup.  
If you have 50 JavaScript projects, you store 50 times the same versions of Lodash. Metacompression sees this; `tar + zstd` mostly sees an archive as one long continuous stream — it can exploit nearby repetitions, but it does not explicitly retain the notion of "this file is the same as that other one at such a location in the tree". That is precisely the information metacompression uses.  
  
It is worth noting that the first benchmarks were only promising:
at that stage, `Metarc` was broadly equivalent to `tar+zstd` — sometimes slightly better,
sometimes slightly worse.

That is no longer the case today.

In the current benchmarks, run on several popular open-source repositories,
`Metarc` (v0.8.0-5-g8045d64e) now produces smaller archives than `tar+zstd` on every repository tested:

| Repo | Original size | Files | tar+zstd | marc | marc / tar |
|---|---:|---:|---:|---:|---:|
| kubernetes | 376M | 29838 | 81.1M | 74.2M | 91.4% |
| docker-compose | 4.5M | 702 | 1.1M | 1.1M | 99.1% |
| vuejs | 9.9M | 728 | 3.2M | 3.2M | 97.5% |
| numpy | 50M | 2364 | 18.4M | 17.5M | 95.3% |
| redis | 29M | 1780 | 8.9M | 8.4M | 93.7% |
| bootstrap | 27M | 816 | 13.9M | 13.3M | 95.9% |
| express | 1.6M | 238 | 345.6K | 339.3K | 98.2% |
| react | 65M | 6884 | 18.5M | 17.1M | 92.4% |

These numbers do not prove that `Metarc` is better for every use case.
They prove something narrower, but more important:
on real source-code trees, upfront structural compression can beat
a conventional `tar+zstd` pipeline.

So the question is no longer only: “does the idea work?”
The question becomes: “how far can this approach be pushed, and on which corpora?”

For large and highly redundant corpora, metacompression methods have their uses.  
Here are some of those methods.

### File deduplication

Two identical files will be compressed twice if we only work at the stream level.  
Metacompression allows compressing them only once and storing the information that a copy exists somewhere in the file tree, since it has information about their identical nature and their attributes (location, permissions...). Modern hash algorithms like BLAKE3 are particularly well suited to this task and to current hardware.

This method alone largely explains the gain obtained in my example above compared to `tar + zstd`.

### Near-identical files

This is a form of file deduplication, but when files are not identical yet very similar: license files, boilerplate files...  
In this case, a compressed reference file is stored, but for near-identical files only the delta is stored (the year and the copyright owner for a license) in a compressed form. In this case the Myers diff algorithm proves as effective as ever for finding small differences.

### Logs

Logs, by their simultaneously structured and repetitive nature, provide a wealth of information enabling more efficient compression than at the byte stream level.

The order and nature of the fields allows isolating highly locally compressible structures: such as timestamps whose date formats are often known and limited (ISO format), log levels which have limited cardinality.

One can store only a date format and a timestamp, a level (DEBUG, INFO, WARN, ERROR...) and a text pattern in an optimized form.

### Structured formats

JSON, CSV, and even source code have known structural information and redundancies that allow compressing before processing at the byte stream level.  
At this level one can compress regularities that bytes alone express poorly.

## Metarc: exploiting this forgotten layer

These are just a few examples of a much broader field.

Metacompression remains a largely under-explored field.
Early practical results show that the approach works, but there is still a lot to invent to make it more general, more robust,
and more effective across different types of corpora.

That is why I wrote [Metarc](https://github.com/arhuman/metarc-go), an archiver written in Go enabling practical exploitation of metacompression: a tool that reduces certain redundancies before applying and optimizing standard compression (`zstd`).

Although it offers compression ratios at least equivalent, and shorter compression/decompression times[^2], `Metarc` does not aim to replace standard archivers.  
It does not (yet) have their robustness, nor their functional richness.

`Metarc` is designed to explore compression beyond the byte stream:

- Structured format normalization
- Pattern extraction
- Pre-transformations to optimize compression

## Where does this idea come from?

The term metacompression has not always meant the same thing.  
At one point, it was used rather to refer to tools capable of dynamically choosing the best compression algorithm depending on the data.

But the idea I describe here is older than the word itself.

Long before anyone spoke of metacompression, some already opposed purely syntactic compression, which works on the byte stream, to a more semantic or more structural compression, capable of exploiting the very nature of the data.

In other words, the idea was already there: compress better by working at a higher level than bytes.

As for me, it was in 2016 that I started using this term, following a very simple intuition: if you want to better compress a set of files, you sometimes need to stop looking at them as a simple continuous stream.  
 That intuition had given birth to an article, *Improving tar with a simple idea and a few lines of JavaScript*, as well as a proof of concept, [jntar](https://github.com/arhuman/jntar).

I had at that time no particular knowledge of pre-existing work on the subject.  
 The term had come to me naturally, and it is still the one I prefer today.

Why?  
Because semantic compression seems too narrow to me. Metacompression does not only work on meaning: it can also exploit structure, relationships between files, repetitions, patterns, or even purely technical transformations that improve compression without strictly falling under semantics.  
  
`Metarc` now takes this intuition further: not as a simple proof of concept anymore, but as a practical implementation of an idea now validated on real source-code trees.

## The right question may no longer be "how to better compress bytes?"

Classical compression has reached an impressive level, but metacompression allows us to reach a whole other level by changing the frame.  
  
By eliminating redundancy upstream, Metarc now shows that structural compression can outperform a conventional `tar+zstd` pipeline on the source-code repositories tested.
  
If the subject interests you, try `Metarc` on your own source-code trees, compare it with `tar+zstd`, and share your results, edge cases, or metacompression ideas through a GitHub issue.

If you think this approach deserves more attention, starring the repository is the simplest way to help it reach more developers.

[^1]: The details of versions and the way to reproduce these benchmarks are available in the documentation of the [Metarc GitHub repository](https://github.com/arhuman/metarc-go)

[^2]: Speed here is not a consequence of metacompression, but rather of the efficient use of concurrency that Go enables, the architectural simplicity of the project, and the use of modern and performant algorithms (`zstd`, `BLAKE3`...)

*Translated by AI*
