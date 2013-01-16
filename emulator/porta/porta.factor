! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models math
       6805.emulator.ports 6805.emulator.ddr ;
  


IN: 6805.emulator.porta


TUPLE: porta < model port ddr ;

: <porta> ( value -- porta )
    porta new-model  0 <ddr> >>ddr 0 <port> >>port ;


GENERIC: read ( porta -- data )


M: porta read
     [ port>> value>> ] keep [ ddr>> value>> ] keep rot bitand value>> bitor bitor ;