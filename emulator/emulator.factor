! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case ;
!    assocs
!    combinators
!    fry
!    io.encodings.binary
!    io.files
!    io.pathnames
!    lexer
!    make
!    namespaces
!    parser
!    peg
!    peg.ebnf
!    peg.parsers
!    quotations
!    sequences.deep
!    words
! ;
IN: 6805.emulator

TUPLE: cpu a x ccr pc sp halted? last-interrupt cycles ram ;

GENERIC: reset ( cpu -- )

CONSTANT: carry-flag     HEX: 01
CONSTANT: zero-flag      HEX: 02
CONSTANT: neg-flag       HEX: 04
CONSTANT: int-flag       HEX: 08
CONSTANT: half-flag      HEX: 10
CONSTANT: b5-flag        HEX: 20
CONSTANT: b6-flag        HEX: 40
CONSTANT: b7-flag        HEX: 80

: >word< ( word -- byte byte )
  #! Explode a word into its two 8 bits values.
  #! dup HEX: FF bitand swap -8 shift HEX: FF bitand swap ;
  dup HEX: FF bitand swap -8 shift HEX: FF bitand ;

: flag_h? ( cpu -- bool )
  #! Test the half-carry flag status
  ccr>> half-flag bitand 0 = not ;

: flag_i? ( cpu -- bool )
  #! test the interrupt flag
  ccr>> int-flag bitand 0 = not ;

: flag_n? ( cpu -- bool )
  #! test the negative flag
  ccr>> neg-flag bitand 0 = not ;

: flag_z? ( cpu -- bool )
  #! test the zero flag
  ccr>> zero-flag bitand 0 = not ;

: flag_c? ( cpu -- bool )
  #! test the carry flag
  ccr>> carry-flag bitand 0 = not ;

#! Set Flag_C
: set_flag_c ( f cpu -- )
  dup rot
  [ ccr>> carry-flag bitor ]
  [ ccr>> carry-flag bitnot bitand ]
  if
  >>ccr drop ;

: read-byte ( addr cpu -- byte )
  #! Read one byte from memory
  over HEX: FFFF <= [ ram>> nth ] [ 2drop HEX: FF ] if ;

: write-byte ( value addr cpu -- )
  #! Write a byte to the specified memory address.
  over dup 0 < swap HEX: FFFF > or
  [ 3drop ]
  [ ram>> set-nth ] if ;

: read-word ( addr cpu -- word )
  [ read-byte ] 2keep [ 1 + ] dip read-byte swap 8 shift bitor ;

: write-word ( value addr cpu -- )
  [ >word< ] 2dip [ write-byte ] 2keep [ 1 + ] dip write-byte ;

 

#! do a cpu Reset
M: cpu reset ( cpu -- )
   0             >>a            ! reset reg A
   0             >>x            ! reset reg X
   BIN: 11100000 >>ccr          ! reset CCR
   HEX: FFFE     >>pc           ! reset PC this needs a relook
   HEX: 00FF     >>sp           ! reset SP
   HEX: FFFF <byte-array> >>ram !
 
!   HEX: FFFF 0 <array> >>ram ! create memory
   f >>halted?
   0 >>cycles
   drop
;

#! Dump the CPU contents
: cpu. ( cpu -- )
  [ " PC: " write pc>> >hex 4 CHAR: 0 pad-head >upper write ] keep
  [ " SP: " write sp>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " A: " write a>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " X: " write x>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " CCR: " write ccr>> >bin 8 CHAR: 0 pad-head write ] keep
  [ " Cycles: " write cycles>> number>string 5 CHAR: \s pad-head write ] keep
  nl drop
;



#! Make a CPU here
: <cpu> ( -- cpu ) cpu new dup reset ;
