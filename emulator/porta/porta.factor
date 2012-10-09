! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel 6805.emulator.ports 6805.emulator.ddr ;


IN: 6805.emulator.porta


TUPLE: porta latch ddr ;

: <porta> ( pvalue dvalue -- porta )
     <ddr> swap <port> porta new swap >>latch swap >>ddr ;

: porta-read ( porta -- data )
    dup latch>> ddr>> ;