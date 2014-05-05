! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays
    kernel
    locals
    math sequences byte-arrays io
    math.parser math.bitwise unicode.case
    namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    vectors words quotations deques dlists models
    freescale.6805.emulator.memory ;


IN: freescale.6805.emulator.ccr


! 7  6  5  4  3  2  1  0
! B7 B6 B5 HF I  N  Z  C

CONSTANT: carry-flag     1
CONSTANT: zero-flag      2
CONSTANT: neg-flag       4
CONSTANT: int-flag       8
CONSTANT: half-flag      16
CONSTANT: b5-flag        32
CONSTANT: b6-flag        64
CONSTANT: b7-flag        128
CONSTANT: C-FLAG         0
CONSTANT: Z-FLAG         1
CONSTANT: N-FLAG         2
CONSTANT: I-FLAG         3
CONSTANT: H-FLAG         4
CONSTANT: B5-FLAG        5
CONSTANT: B6-FLAG        6
CONSTANT: B7-FLAG        7


TUPLE: ccr < model ;

! Create CCR
: <ccr> ( value -- ccr )
    ccr new-model ;

! Write to CCR
: ccr-write ( b ccr -- )
    [ 8 bits ] dip  set-model ;

! read CCR
: ccr-read ( ccr -- d )
    value>> 8 bits ;

#! Test the half-carry flag status
: ccr-h? ( ccr -- ? )
  ccr-read H-FLAG H-FLAG bit-range 1 = ;

#! test the interrupt flag
: ccr-i? ( ccr -- bool )
  ccr-read I-FLAG I-FLAG bit-range 1 =  ;

#! test the negative flag
: ccr-n? ( ccr -- bool )
  ccr-read N-FLAG N-FLAG bit-range 1 =  ;

#! test the zero flag
: ccr-z? ( ccr -- bool )
  ccr-read Z-FLAG Z-FLAG bit-range 1 = ;

#! test the carry flag
: ccr-c? ( ccr -- bool )
  ccr-read C-FLAG C-FLAG bit-range 1 = ;

#! Set Flag_C
: ccr-set-c ( ccr -- )
    [ ccr-read C-FLAG set-bit ] keep ccr-write ;

#! Clr flag c
: ccr-clr-c ( ccr -- )
    [ ccr-read C-FLAG clear-bit ] keep ccr-write ;


! write to carry flag
: >ccr-c ( ? ccr -- )
    [ >boolean ] dip swap
    [ ccr-set-c ] [ ccr-clr-c ] if ;
        


