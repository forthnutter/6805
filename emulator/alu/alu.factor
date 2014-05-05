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
    6805.emulator.memory ;


IN: 6805.emulator.alu


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


TUPLE: alu < model ;

! Create CCR
: <alu> ( value -- alu )
    alu new-model ;

! Write to CCR
: alu-write ( b alu -- )
    [ 8 bits ] dip  set-model ;

! read alu
: alu-read ( alu -- d )
    value>> 8 bits ;

#! Test the half-carry flag status
: alu-h? ( alu -- ? )
  alu-read H-FLAG H-FLAG bit-range 1 = ;

#! test the interrupt flag
: alu-i? ( alu -- bool )
  alu-read I-FLAG I-FLAG bit-range 1 =  ;

#! test the negative flag
: alu-n? ( alu -- bool )
  alu-read N-FLAG N-FLAG bit-range 1 =  ;

#! test the zero flag
: alu-z? ( alu -- bool )
  alu-read Z-FLAG Z-FLAG bit-range 1 = ;

#! test the carry flag
: alu-c? ( alu -- bool )
  alu-read C-FLAG C-FLAG bit-range 1 = ;

#! Set Flag_C
: alu-set-c ( alu -- )
    [ alu-read C-FLAG set-bit ] keep alu-write ;

#! clear flag C
: alu-clr-c ( alu -- )
    [ alu-read C-FLAG clr-bit ] keep alu-write ;


