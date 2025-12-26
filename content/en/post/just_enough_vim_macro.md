+++
author = "Arnaud ASSAD"
date = "2020-01-21"
description = ""
thumbnail = "img/vim_macros/keyboard_pexels_lukas_mayer.jpg"
linktitle = "perl_in_2020"
title = "Just enough... Vim macros"
type = "post"
tags = ["Vim", "2020", "Macros", "Tips", "Tutorial"]
categories = ["Article"]
+++

Today I'll start a series of articles dedicated to Vim:

*"Just enough Vim to be efficient"*

The main idea should be obvious from the title. Learn the bare minimum to produce useful results (and hopefully motivate you to dig even further)

This article is dedicated to Vim macros, an often overlooked feature of Vim.

But let's start from the beginning what is a macro? and why is it useful?

And if the answer to the first question is simple: A macro is just a recorded sequence of keys.

The answer to the latter is more subtle…

Whereas the common answers apply:
 * automate simple task
 * speed up some typing
 * assist your memory by shortening the key sequence you have to remember

Vim context offers additional benefits.

As Vim is a modal editor (more on this in a forecoming article) and a keyboard based text editor, Vim macros are much more powerful because:

 * Macros allow you to do *everything* you can do manually
 * Macros allow you to do complex things with few keystrokes

I would add another point which is "Vim macros are ridiculously simple to use once accustomed to them", but I you and I may disagree on it so let me show you…

Vim macros have many uses, let's see 2 of them: process multiple lines the same way and generate data.

## Macros (ultra)quickstart guide

In normal mode press 'q' then a letter between 'a' and 'z' which will be the macro name (or more precisely the register in which the macro will be stored).

From now on, every key pressed will be recorded in the macro. While recording the macro, you can change mode (normal, insert, visual…) as you like. When you're done press 'q' again in normal mode to end the recording.

Executing a macro is as simple as typing '@' followed by the macro name.

Now that you know how to record and execute a macro, let's see how it could be useful. Let's start by a basic multiple lines modification.

## Turning filename list into markdown link list

Markdown link follow a basic syntax '[url](link description)', turning a long list of filename into markdown link is easy if you use the filename as description but tedious.

Let's call macro to the rescue:

![Vim macro to turn filename to markdown link](/img/vim_macros/animated_filename_to_link.gif)

```
r !ls doc/*<enter>   fill current buffer with result of system command 'ls doc/*' listing all files present in directory doc
1G                    go to line 1
dd                    delete current line
qa                    start recording macro 'a'
0                     go to beginning of line
vEy                   yank (copy) a visual selection starting from the current position to the end of word counting symbol as part of it.
i[                    switch to insert mode and insert opening square bracket(my vim is configured to autoinsert closing bracket also)
<esc>                 switch back to normal mode (to move and manipulate text)
ll                    2 characters to the left
i                     switch to insert mode (to enter characters)
(                     opening brace (my vim is configured to insert closing braced as well)
<Escape>              switch to normal mode (to move and manipulate text)
l                     move left
x                     delete character under cursor
$                     move to the end of the line
p                     paste the selection
j                     move cursor one line down (important to enable multiple execution)
q                     stop recording the macro 'a'
@a                    execute the macro 'a'
6@a                   execute the macro 'a' 6 times (to process the 6 remaining lines)
```
With some practice, you'll get more and more efficient with macros but nonetheless you'll probably make small mistake or suboptimal choices in you (long) macro. In this case instead of rerecording everything, it's easier to modify a recorded macro.

Let's modify the markdown link macro to add a '* ' in front of each line.

![Modify a Vim macro](/img/vim_macros/animated_modify_macro.gif)

```
:badd m <enter>  create a new buffer named m
,bb              my vim config to switch between buffer, use :bn
"ap              paste macro 'a' content
0                move to beginning of line
fi               move to first 'i' (the place where we start inserting characters in the macro)
a*<space>        append star character followed by a space
<escape>         get back to normal mode
0                move to beginning of line
v$               select from current position to end of line
"ay              yank (copy) the current selection into 'a' register
:bd!             delete current buffer
@a               execute the macro (just recorded in the) 'a' (register)
7@a              execute the macro 'a' on the 7 remaining line.
```

>Tips: You probably noticed the '[^' in the pasted macro, and guessed that it stands for the escape keypress. But if you still wonder how to enter escape in insert mode here's the answer: 'Ctrl-v <Escape>' in fact 'Ctrl-v' follow by any key allow you to insert this key (also useful for backspace for example)

## Extracting information from XML

The markdown link is a little bit hair-pulled to you?
Let's display the country name and the country code from an XML country list.
Extracting information from xml data

![Extract information from XML](/img/vim_macros/animated_extract_from_xml.gif)

But macro can also save you time generating data.

## Generating data

Let's generate some IP addresses.

![Generate an IP range with macro](/img/vim_macros/animated_generate_ip_range.gif)

```
i             switch to insert mode
192.168.1.1   enter the first IP
<escape>      switch to normal mode
qa            start recording of macro 'a'
yyp           yank (copy) and paste current line
$             go to end of (pasted) line
<Ctrl+a>      increment the number under cursor
q             stop recording the macro 'a'
@a            execute the macro 'a'
251@a         execute the macro 'a' 251 times
```

## Conclusion
I hope that you're now convinced of how powerful and useful the Vim macros can be. Play with them, experiment and before you realize you they'll become one of the best move of your Vim-fu.

I hope you found this article useful. In any case, please leave a comment to give your opinion and tell me what you (dis)like about this article, and what you'd like to see improved for the next ones…

And if you *really* like this article, consider joining the Vim users group on Linkedin to show your interest in Vim.
