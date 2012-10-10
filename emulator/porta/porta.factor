! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel 6805.emulator.ports 6805.emulator.ddr models ;


IN: 6805.emulator.porta


TUPLE: porta < model latch ddr ;

: <porta> ( pvalue dvalue -- porta )
     <ddr> swap <port> porta new-model swap >>latch swap >>ddr ;

: porta-read ( porta -- data )
    value>> ;