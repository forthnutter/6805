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
    6805.emulator.memory ;
  
!    io.encodings.binary
!    io.files
!    io.pathnames
!    peg.ebnf
!    peg.parsers
! ;
IN: 6805.emulator




CONSTANT: MEMSTART 0
CONSTANT: MEMSIZE 0xFFFF

TUPLE: memory start size array ;



GENERIC: init ( start size memory -- )
GENERIC: read-byte ( address memory -- byte )


#! Make Memory
: <memory> ( -- memory ) memory new [ MEMSTART MEMSIZE ] keep init ;

M: memory init ( start size memory -- )
  swap >>size swap >>start
  [ size>> <byte-array> ] keep  array<<
;


M: memory read-byte ( address memory -- byte )
  [ start>> + ] keep [ array>> ] call nth
;
  

TUPLE: cpu a x ccr pc sp halted? last-interrupt cycles mlist memory ;

GENERIC: reset ( cpu -- )
GENERIC: addmemory ( obj cpu -- )
GENERIC: byte-read ( address cpu -- byte )




#! do a cpu Reset
M: cpu reset ( cpu -- )
   0               >>a          ! reset reg A
   0               >>x          ! reset reg X
   "11100000" bin> >>ccr        ! reset CCR
   "FFFE" hex>     >>pc         ! reset PC this needs a relook
   "00FF" hex>     >>sp         ! reset SP
   f >>halted?
   0 >>cycles
   drop
;

#! add memory object to the cpu memory list
M: cpu addmemory ( obj cpu -- )
  mlist>> push-back* drop
;

SYMBOL: tlist



: read-instruction ( cpu -- word )
  [ pc>> ] keep   ! pc cpu
  [ over 1 + swap pc<< ] keep
  read-byte ;


: find-memory ( address list -- m t f )
  [
    [
      [ drop dup ] keep    ! make a copy of address
      start>> >=
    ] keep
    [ drop swap ] keep
    [
      [ drop dup ] keep    ! make a copy of address      
      dup size>> swap  start>> - <=
    ] call
    and
  ] dlist-find
;

M:: cpu byte-read ( addr cpu -- byte )
  #! Read one byte from memory
  #! [ drop dup ] keep
  cpu mlist>> vector?
  [
    cpu mlist>>
    [
      
    ] each
  ]
  [
    f
  ] if
  
  [ drop drop f ] [ mlist>> find-memory ] if
  [ read-byte ] [ drop 0 ] if  
;




CONSTANT: carry-flag     1
CONSTANT: zero-flag      2
CONSTANT: neg-flag       4
CONSTANT: int-flag       8
CONSTANT: half-flag      16
CONSTANT: b5-flag        32
CONSTANT: b6-flag        64
CONSTANT: b7-flag        128

: >word< ( word -- byte byte )
  #! Explode a word into its two 8 bits values.
  #! dup HEX: FF bitand swap -8 shift HEX: FF bitand swap ;
  dup "FF" hex> bitand swap -8 shift "FF" hex> bitand ;

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



: write-byte ( value addr cpu -- )
  #! Write a byte to the specified memory address.
#!  over dup 0 < swap HEX: FFFF > or
 #! [ 3drop ]
 #! [ ram>> set-nth ] if
;

: read-word ( addr cpu -- word )
  #! [ read-byte ] 2keep [ 1 + ] dip read-byte swap 8 shift bitor
;

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
: (emulate-brset) ( n cpu -- )
    [ inc-pc ] keep [ pc>> ] keep  ! n pc cpu
    [ read-byte ] keep
    [ inc-pc ] keep [ pc>> ] keep
    [ read-byte ] keep
  ;

#! BRCLR
#! d relative displacement
#! m zero Page memory location
#! n bit number
: (emulate-brclr) ( n cpu -- )
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
    { "OPC-00" [ 0 swap (emulate-brset) ] }
    { "OPC-01" [ 0 swap (emulate-brclr) ] }
    { "OPC-02" [ 1 swap (emulate-brset) ] }
    { "OPC-03" [ 1 swap (emulate-brclr) ] }
    { "OPC-04" [ 2 swap (emulate-brset) ] }
    { "OPC-05" [ 2 swap (emulate-brclr) ] }
    { "OPC-06" [ 3 swap (emulate-brset) ] }
    { "OPC-07" [ 3 swap (emulate-brclr) ] }
    { "OPC-08" [ 4 swap (emulate-brset) ] }
    { "OPC-09" [ 4 swap (emulate-brclr) ] }
    { "OPC-0A" [ 5 swap (emulate-brset) ] }
    { "OPC-0B" [ 5 swap (emulate-brclr) ] }
    { "OPC-0C" [ 6 swap (emulate-brset) ] }
    { "OPC-0D" [ 6 swap (emulate-brclr) ] }
    { "OPC-0E" [ 7 swap (emulate-brset) ] }
    { "OPC-0F" [ 7 swap (emulate-brclr) ] }
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
    "OPC-00" "BRSET" complex-instruction ,
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
  ] dip ( cpu -- ) define-declared
;



SYNTAX: INSTRUCTION: break ";" parse-tokens parse-instructions ;


#! Set the number of cycles for the last instruction that was defined. 
SYNTAX: cycles 
  scan-token string>number last-opcode get-global instruction-cycles set-nth ; 

#! Set the opcode number for the last instruction that was defined.
SYNTAX: opcode ( -- )
  last-instruction get-global 1quotation scan-token hex>
  dup last-opcode set-global set-instruction ;


: step ( cpu -- )
  dup pc>>              ! PC
  swap memory>>         ! memory
  
;

#! Description: Trace execute one instruction
: trace ( cpu -- )
;

! Get PC and Read memory data
: pc-memory-read ( cpu -- d )
  [ pc>> ] keep [ memory>> ] keep
  memory-read ;


! Branch if Bit 0 is Set
: (opcode-00) ( cpu -- )
  [ pc-memory-read ] keep 
  ;

#! Make a CPU here
: <cpu> ( -- cpu )
  cpu new
  <memory> >>memory ;