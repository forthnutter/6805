! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models ;


IN: 6805.emulator.ddr

TUPLE: ddr < model ;

: <ddr> ( value -- port )
    ddr new-model ;

