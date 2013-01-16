! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.

! Port Register is basically a latch to hold the output bits

USING: kernel 6805.emulator.ddr models accessors math ;


IN: 6805.emulator.ports

! The port has two 8 bit registers
! LATCH   Set the state of output pin

TUPLE: port < model ;

! new port is dependant on ddr port
: <port> ( value -- port )
    port new-model ;
 
GENERIC: read ( port -- d )
GENERIC: write ( d port -- )

! Depending DDR we ether read from out side world or latch output
M: port read ( port -- d )
    value>> 0xff bitand ;

! Write to port
M: port write ( d port -- )
    set-model ;


    

