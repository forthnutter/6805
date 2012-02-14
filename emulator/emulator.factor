! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations ;
  
!    io.encodings.binary
!    io.files
!    io.pathnames
!    peg.ebnf
!    peg.parsers
! ;
IN: 6805.emulator


CONSTANT: MEMSTART 0
CONSTANT: MEMSIZE  HEX: FFFF

TUPLE: memory start size array ;

GENERIC: init ( start size memory -- )

#! Make Memory
: <memory> ( -- memory ) memory new [ MEMSTART MEMSIZE ] keep init ;

M: memory init ( start size memory -- )
  swap >>size swap >>start
  [ size>> <byte-array> ] keep  array<<
;



TUPLE: cpu a x ccr pc sp halted? last-interrupt cycles ram ;

GENERIC: reset ( cpu -- )

#! Make a CPU here
: <cpu> ( -- cpu ) cpu new <memory> >>ram dup reset ;

#! do a cpu Reset
M: cpu reset ( cpu -- )
   0             >>a            ! reset reg A
   0             >>x            ! reset reg X
   BIN: 11100000 >>ccr          ! reset CCR
   HEX: FFFE     >>pc           ! reset PC this needs a relook
   HEX: 00FF     >>sp           ! reset SP
   f >>halted?
   0 >>cycles
   drop
;


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

: inc-pc ( cpu -- )
  [ pc>> ] keep
  swap
  1 + >>pc
  drop
 ;


: not-implemented ( <cpu> -- )
  drop
;

 
#! Return a 256 element vector containing the emulation words for
#! each opcode in the 6805 instruction set.
: instructions ( -- vector )
  \ instructions get-global
  [
    256 [ not-implemented ] <array> \ instructions set-global
  ] unless
  \ instructions get-global
;


: set-instruction ( quot n -- )
  instructions set-nth ;


#! Return the next instruction from the CPU's program
#! counter, but don't increment the counter.
: peek-instruction ( cpu -- word )
  [ pc>> ] keep read-byte instructions nth first ;
  

#! Dump the CPU contents
: cpu. ( cpu -- )
  [ " PC: " write pc>> >hex 4 CHAR: 0 pad-head >upper write ] keep
  [ " SP: " write sp>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " A: " write a>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " X: " write x>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " CCR: " write ccr>> >bin 8 CHAR: 0 pad-head write ] keep
  [ " Cycles: " write cycles>> number>string 5 CHAR: \s pad-head write ] keep
  [ " " write peek-instruction name>> write " " write ] keep
  nl drop
;

#! Dump the CPU contents
: cpu*. ( cpu -- )
  [ " PC: " write pc>> >hex 4 CHAR: 0 pad-head >upper write ] keep
  [ " SP: " write sp>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " A: " write a>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " X: " write x>> >hex 2 CHAR: 0 pad-head >upper write ] keep
  [ " CCR: " write ccr>> >bin 8 CHAR: 0 pad-head write ] keep
  [ " Cycles: " write cycles>> number>string 5 CHAR: \s pad-head write ] keep
  nl drop
;

#! Return a 256 element vector containing the cycles for
#! each opcode in the 6805 instruction set.
: instruction-cycles ( -- vector )
  \ instruction-cycles get-global
  [
    256 f <array> \ instruction-cycles set-global
  ] unless
  \ instruction-cycles get-global ;

#! BRSET
#! d relative displacement
#! m zero Page memory location
#! n bit number
: (emulate-BRSET) ( n cpu -- )
    [ inc-pc ] keep [ pc>> ] keep  ! n pc cpu
    [ read-byte ] keep
    [ inc-pc ] keep [ pc>> ] keep
    [ read-byte ] keep
  ;

SYMBOLS: $1 $2 $3 $4 ;

: replace-patterns ( vector tree -- tree )
  [
    {
      { $1 [ first ] }
      { $2 [ second ] }
      { $3 [ third ] }
      { $4 [ fourth ] }
      [ nip ]
    } case
  ] with deep-map
;

#! table of code quotation patterns for each type of instruction.
: patterns ( -- hashtable )
  H{
    { "BRSET0" [ 0 swap (emulate-BRSET) ] }
   }
;


#! Generate the quotation for an instruction, given the instruction in 
#! the 'string' and a vector containing the arguments for that instruction.
: generate-instruction ( vector string -- quot )
  break patterns at replace-patterns ;

#! Return a parser for then instruction identified by the token. 
#! The parser return parses the token only and expects no additional
#! arguments to the instruction.
: simple-instruction ( token -- parser )
  token [ '[ { } _ generate-instruction ] ] action ;

#! Return a parser for an instruction identified by the token. 
#! The instruction is expected to take additional arguments by 
#! being combined with other parsers. Then 'type' is used for a lookup
#! in a pattern hashtable to return the instruction quotation pattern.
: complex-instruction ( type token -- parser )
  token swap [ nip '[ _ generate-instruction ] ] curry action ;

: no-params ( ast -- ast )
  first { } swap curry ;

: one-param ( ast -- ast )
  first2 swap curry ;

: two-params ( ast -- ast )
  first3 append swap curry ;

: NOP-instruction ( -- parser )
  "NOP" simple-instruction ;

: BRSET0-instruction ( -- parser )
  [
    "BRSET0" "BRSET" complex-instruction ,
    "0" token sp hide ,
  ] seq* [ no-params ] action ;


: 6805-generator-parser ( -- parser )
  [ 
    BRSET0-instruction  ,

  ] choice* [ call( -- quot ) ] action ;



#! Given an instruction string, return the emulation quotation for
#! it. This will later be expanded to produce the disassembly and
#! assembly quotations.
: instruction-quotations ( string -- emulate-quot )
  6805-generator-parser parse
;

SYMBOL: last-instruction
SYMBOL: last-opcode


#! Process the list of strings, which should make
#! up an 6805 Instruction, and output a quotation
#! that would implement that instruction
: parse-instructions ( list -- )
  dup " " join instruction-quotations
  [
    "_" join [ "emulate-" % % ] "" make
    create-in dup last-instruction global set-at 
  ] dip (( cpu -- )) define-declared
;





SYNTAX: INSTRUCTION: break ";" parse-tokens parse-instructions ;


#! Set the number of cycles for the last instruction that was defined. 
SYNTAX: cycles 
 break scan string>number last-opcode global at instruction-cycles set-nth ; 

#! Set the opcode number for the last instruction that was defined.
SYNTAX: opcode ( -- )
 break last-instruction global at 1quotation scan 16 base>
  dup last-opcode global set-at set-instruction ; 