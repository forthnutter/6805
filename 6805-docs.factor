! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences strings 6805.emulator ;
IN: 6805


ARTICLE: { "cpu-6805" "cpu-6805" } "Freescale 6805 CPU Emulator"
"The cpu-6805 library provides an emulator for the Freescale 6805 CPU"
" instruction set. It is complete enough to emulate some 6805 controllers" 
"The emulated CPU can load 'ROM' files from disk using the "
" and  words. These expect "
"the  variable to be set to the path "
"containing the ROM file's." ;

ABOUT: { "cpu-6805" "cpu-6805" } 
