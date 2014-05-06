! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: 
    accessors arrays
    kernel
    locals
    math math.bitwise sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    vectors
    words quotations
    6805.emulator.memory
    6805.emulator.alu
    6805.emulator.config ;
  

IN: 6805.emulator

TUPLE: cpu config alu a x pc sp halted? last-interrupt cycles mlist memory ;




: >word< ( word -- byte byte )
  #! Explode a word into its two 8 bits values.
  #! dup HEX: FF bitand swap -8 shift HEX: FF bitand swap ;
  dup "FF" hex> bitand swap -8 shift "FF" hex> bitand ;



: read-word ( addr cpu -- word )
   drop drop 0
  #! [ read-byte ] 2keep [ 1 + ] dip read-byte swap 8 shift bitor
;

! Increment PC
: PC+ ( cpu -- )
   [ pc>> ] keep swap 1 + >>pc drop ;

! Decrement PC
: PC- ( cpu -- )
   [ pc>> ] keep swap 1 - >>pc drop ;

! add the relative displacement to pc
: pc-relative ( r cpu -- )
  [ dup 7 bit? ] dip swap
  [
    [ 7 clear-bit ] dip
    [ pc>> swap - 16 bit-range ] keep
    pc<<
  ]
  [
    [ pc>> + 16 bit-range ] keep
    pc<<
  ] if ;
  

! move bit or flag into carry flag
: >C ( ? cpu -- )
  alu>> >alu-c ;
  
: not-implemented ( <cpu> -- )
  drop
;

: write-byte ( d a cpu -- )
   memory>> memory-write ;


: read-byte ( a cpu -- d )
   memory>> memory-read ;


! Get PC and Read memory data
: pc-memory-read ( cpu -- d )
  [ pc>> ] keep memory>> memory-read ;



! BRSET0
: (opcode-00) ( cpu -- )
   [ PC+ ] keep
   [ pc-memory-read ] keep
   [ 0 bit? ] dip [ >C ] keep
   [ alu>> alu-c? ] keep swap
   [
     [ PC+ ] keep
     [ pc-memory-read ] keep
     [ PC+ ] keep
     [ pc-relative ] keep
   ]
   [ [ PC+ ] keep PC+ ] if
  ;



! BRCLR0
: (opcode-01) ( cpu -- )
  drop ;




! BRSET1
: opcode-02 ( cpu -- )
  drop ;

! BRCLR1
: opcode-03 ( cpu -- )
  drop ;


! add memory tuple
: cpu-add-memory ( memory cpu -- )
  memory<< ;


: cpu-reset ( cpu -- )
  ! all DDR = 0
  ! SP = 0x00ff
  ! I bit in the CCR set to 1 to inhibit maskable interrupts
  ! External interrupt latch cleared
  ! STOP latch cleared
  ! WAIT latch cleared
  [ config>> config-reset-vector ] keep
  [ read-word ] keep
  pc<< ;

: cpu-add-config ( config cpu -- )
  config<< ;




 
! step 1 Make a CPU here
: <cpu> ( -- cpu )
  cpu new
  0 >>pc
  0xe0 <alu> >>alu ;

