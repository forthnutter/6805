! Copyright (C) 2012 Joseph Moschini
!
USING: accessors arrays combinators kernel
;


IN: 6805.assembler

CONSTANT: B0 0
CONSTANT: B1 2
CONSTANT: B2 4
CONSTANT: B3 6
CONSTANT: B4 8
CONSTANT: B5 10
CONSTANT: B6 12
CONSTANT: B7 14


! Branch if bit is set in register / memory
: brset ( b dd rr -- barray )
    ;

! Branch if bit is clear in register memory
: brclr ( b dd rr -- barray )
    ;


