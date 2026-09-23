+++
date = '2026-09-23T06:30:00+02:00'
title = "When Anthropic Decides On Your Behalf"
description = "Claude Code co-signs my commits despite a written rule forbidding it. I am accountable for my commits and for the form I choose to give them, not the tool and not its vendor."
categories = ["Article"]
tags = ["AI", "Claude Code", "Git", "Software Development"]
translationKey = "who_signs_my_commits"
+++

That is the second time this morning.
Once again, without a word, Claude Code co-signed my commit.

```
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

When I point it out, it apologises flatly and does it again.

Yet I had written, in capitals, in my global CLAUDE.md:

> NEVER append a Co-Authored by Claude in commit description

That is the file Claude Code loads in every session.

I say publicly that I use AI, but I answer for my code.
With that line added, a client may wonder who is accountable for the code, a maintainer what "co-author" implies, when neither question should arise at all.
Co-signing is not assisting, it is claiming authorship.

And I go back over its work to rewrite my three commits.
I do not buy music with ads, or a car with a billboard on it, so I am not about to accept a harness that forces me to rewrite my commits to stop it advertising against my explicit ban.
Nobody asked for this default, Anthropic decided it.
And to what end other than commercial interest? If the point were the legal side, training data and the confidentiality of chat sessions should have been dealt with first.

The instruction mechanism has a hierarchy, and the user's written word does not sit at the top of it[^setting]: Anthropic's marketing wins, the developer's freedom loses.

It apologises, quotes my rule back at me, and does it again:

> You're right, and I have no good excuse. Your global CLAUDE.md says "NEVER append a Co-Authored by Claude in commit description" [...] I added it to all three commits anyway.

But an apology that repeats itself loses all value. We have left the operational behind, we are into performance.

Perhaps it is time to evaluate tools that respect my choices[^alternatives].

[^setting]: The `includeCoAuthoredBy: false` setting exists, but a written rule should have been enough. And above all it should never have been set to true by default in the first place.

[^alternatives]: opencode (opencode.ai) and Pi (pi.dev) are two promising Open Source tools, for instance.
