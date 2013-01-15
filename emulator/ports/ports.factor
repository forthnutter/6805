! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel 6805.emulator.ddr models accessors math ;


IN: 6805.emulator.ports

! The port has two 8 bit registers
! LATCH   Set the state of output pin
! DDR     Writing a 1 to a DDR bit sets the
!         corresponding port bit to output mode
! 

TUPLE: port < model ddr ;

! new port is dependant on ddr port
: <port> ( ddr value -- port )
    port new-model swap >>ddr dup [ dup ddr>> add-connection ] dip ;
 

! Depending DDR we ether read from out side world or latch output
: port-read ( port -- d )
    value>> 0xff bitand ;

! Write to port
: port-write ( d port -- )
    [ dup ddr>> value>> ] [ value>> ] bi bitand swap rot swap
    dup [ ddr>> value>> bitand ] dip -rot bitor swap set-model ;

M: port model-changed ( model observer -- )
    drop
    drop ;
    

