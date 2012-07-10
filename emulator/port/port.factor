! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessor kernel model ;

IN: 6805.emulator.port

TUPLE: port < model ddr ;

: <port> ( value -- port )
    port newmodel 0 ddr>> ;

