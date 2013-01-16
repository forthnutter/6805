! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
! Data Direction Register
USING: accessors kernel models math ;


IN: 6805.emulator.ddr

TUPLE: ddr < model ;

! New DDR register
: <ddr> ( value -- ddr )
    ddr new-model ;

GENERIC: read ( ddr -- d )
GENERIC: write ( d ddr -- )

! Depending DDR we ether read from out side world or latch output
M: ddr read ( ddr -- d )
    value>> 0xff bitand ;

! Write to port
M: ddr write ( d ddr -- )
    set-model ;
