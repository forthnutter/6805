! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models math ;
      
 

IN: 6805.emulator.port




TUPLE: pdata < model port ;

: <pdata> ( -- pdata )
    0 pdata new-model ;

TUPLE: pddr < model port ;

: <pddr> ( -- pddr )
    0 pddr new-model ;

TUPLE: port < model data ddr ;

: <port> ( -- port )
    0 port new-model
    <pdata> >>data [ data>> ] keep [ add-dependency ] keep
    [ data>> ] keep [ swap port<< ] keep
    <pddr> >>ddr [ ddr>> ] keep [ add-dependency ] keep
    [ ddr>> ] keep [ swap port<< ] keep ;

: port-data>> ( port -- data )
    data>> ;

