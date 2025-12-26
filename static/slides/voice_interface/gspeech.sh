#!/bin/bash
say() { 
    local IFS=+;
    # You can substitute your player here (mpg123) instead of mplayer
    /usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols \ 
	"http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=$*&tl=Fr-fr"; 
}
say $*
