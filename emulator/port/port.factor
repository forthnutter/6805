! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel 6805.emulator.ddr models ;


IN: 6805.emulator.port

TUPLE: port < model ;

: <port> ( value -- port )
    port new-model dup 0 <ddr> swap [ add-connection ] keep ;

