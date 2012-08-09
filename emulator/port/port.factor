! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel 6805.emulator.ddr models accessors ;


IN: 6805.emulator.port

TUPLE: port < model latch ;

: <port> ( value -- port )
    port new-model 0 <ddr> swap [ add-connection ] keep ;

! Depending DDR we ether read from out side world or latch output
: port-read ( port -- d )
     value>>
     ;
 