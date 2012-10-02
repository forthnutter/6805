! Copyright (C) 2011 Joseph Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models sequences vectors ;


IN: 6805.emulator.memory

TUPLE: memory < model n string ;


! PORTA  $0000 Port A
! PORTB  $0001 Port B
! PORTC  $0002 Port C
! PORTD  $0003 Port D
! DDRA   $0004 Data Direction Register A
! DDRB   $0005 Data Direction Register B
! DDRC   $0006 Data Direction Register C
! DDRD   $0007 Data Direction Register D
!        $0008
!        $0009
! SPCR   $000A SPI Control Register
! SPSR   $000B SPI Status Register
! SPDR   $000C SPI Data Register
! BAUD   $000D SCI Baud Rate Register
! SCCR1  $000E SCI Control Register 1
! SCCR2  $000F SCI Control Register 2
! SCSR   $0010 SCI Status Register
! SCDR   $0011 SCI Data Register
! TCR    $0012 Timer Control Register
! TSR    $0013 Timer Status Register
! ICRH   $0014 Input Capture Register High
! ICRL   $0015 Input Capture Register Low
! OCRH   $0016 Output Compare Register High
! OCRL   $0017 Output Compare Register Low
! TRH    $0018 Timer Register High
! TRL    $0019 Timer Register Low
! ATRH   $001A Alternate Timer Register High
! ATRL   $001B Alternate Timer Register Low
! EPR    $001C EPROM Porgramming
! COPRST $001D COP Reset Register
! COPCR  $001E COP Control Register

GENERIC: PORTA ( memory -- )
GENERIC: PORTB ( memory -- )
GENERIC: PORTC ( memory -- )
GENERIC: PORTD ( memory -- )


M: memory PORTA
    drop
;

M: memory PORTB
    drop
;

M: memory PORTC
    drop
;

M: memory PORTD
    drop
;


: <memory> ( n value -- memory )
    memory new-model swap >>n ;

: add-memory ( object memory -- memory )
   [ add-connection ] keep 
;

: mem-setup ( -- vector )
   16  <vector> dup
    0 0 <memory> \ PORTA swap add-memory swap push dup ! Port A
    1 0 <memory> \ PORTB swap add-memory swap push dup ! Port B
    2 0 <memory> \ PORTC swap add-memory swap push dup ! Port C
    3 0 <memory> \ PORTD swap add-memory swap push dup ! Port D
    drop
    
    ;
