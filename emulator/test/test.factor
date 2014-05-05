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
    freescale.6805.emulator
    freescale.6805.emulator.memory
    freescale.6805.emulator.alu
    freescale.6805.emulator.config ;


IN: frescale.6805.emulator.test


: 6805-emu-test ( -- cpu )
    <config-default>     ! step 1 make memory config
    <cpu>                ! step 2 male cpu with cofig
    [ cpu-reset ] keep
;