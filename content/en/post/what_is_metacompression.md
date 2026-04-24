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
  
It should be noted that for common use cases, the ratios, while not better, are promising at this stage of the project. Here is a comparison performed on various popular GitHub repositories using different languages[^1]:

| Repo | Original size | Files | tar+zstd | marc | **% of tar** |
|------|---------------|-------|----------|------|----------|
| kubernetes | 374M | 29254 | 81.2M | 81.5M | **100.3%** |
| docker-compose | 4.5M | 706 | 1.1M | 1.1M | **102.1%** |
| vuejs | 9.8M | 732 | 3.2M | 3.3M | **101.2%** |
| numpy | 50M | 2372 | 18.4M | 18.6M | **100.9%** |
| redis | 28M | 1784 | 8.9M | 9.0M | **100.7%** |
| bootstrap | 27M | 820 | 13.9M | 13.8M | **99.5%** |
| express | 1.6M | 242 | 345.8K | 356.1K | **103.0%** |
| react | 65M | 6888 | 18.4M | 18.4M | **100.1%** |
| prometheus | 37M | 1627 | 9.6M | 9.6M | **100.8%** |

On average across these repositories: `Metarc` is broadly equivalent to `tar + zstd` (between 99% and 103% of the size).

Important: metacompression is particularly effective on corpora of multiple files with inter-file redundancies. On a single file, already heavily compressed or random, it brings no additional gain compared to `zstd` alone, and its preliminary analysis may even add a slight time overhead.

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

## Metarc: exploring this forgotten layer

These are just a few examples of a much broader field.

Metacompression is a relatively young domain where there is still much to invent.

That is why I wrote [Metarc](https://github.com/arhuman/metarc-go), an archiver written in Go enabling practical exploration of metacompression: a tool that seeks to reduce certain redundancies before applying and optimizing standard compression (`zstd`).

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
  
`Metarc` extends that intuition today within a more ambitious framework: no longer as a simple proof of concept, but as a concrete experimentation ground to explore compression beyond the byte stream.

## The right question may no longer be "how to better compress bytes?"

Classical compression has reached an impressive level, but metacompression allows us to reach a whole other level by changing the frame.  
  
By eliminating redundancy upstream or by transforming the data to be compressed, we can obtain, on certain highly redundant corpora, better results, while remaining comparable on more general cases.  
  
If the subject interests you, install `Metarc`, test its effectiveness on your directories, propose your metacompression ideas, or share your use cases in the comments. The field remains wide open and awaits your contributions.

[^1]: The details of versions and the way to reproduce these benchmarks are available in the documentation of the [Metarc GitHub repository](https://github.com/arhuman/metarc-go)

[^2]: Speed here is not a consequence of metacompression, but rather of the efficient use of concurrency that Go enables, the architectural simplicity of the project, and the use of modern and performant algorithms (`zstd`, `BLAKE3`...)

*Translated by AI*
