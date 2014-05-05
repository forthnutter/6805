<<<<<<< HEAD
! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays
    kernel
    locals
    math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    vectors
    words quotations deques dlists
    6805.emulator.memory
    6805.emulator.alu ;
  

IN: 6805.emulator.config

TUPLE: config iostart iosize
    ramstart ramsize
    romstart romsize
    reset swi irq timer ;




: <config-default> ( -- config )
    config new
    0 >>iostart
    32 >>iosize
    0x20 >>ramstart
    160 >>ramsize
    0x0300 >>romstart
    0x0800 0x0300 - >>romsize
    0x07fe >>reset
    0x07fc >>swi
    0x07fa >>irq
    0x07f8 >>timer ;


: config-reset-vector ( config -- a )
    reset>> ;





=======
! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!


IN: freescale.6805.emulator.config

>>>>>>> branch 'master' of git@github.com:forthnutter/freescale.git
