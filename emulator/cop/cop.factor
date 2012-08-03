! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel ;


IN: 6805.emulator.cop

TUPLE: cop < model ;

: <cop> ( value -- cop )
    cop newmodel ;

