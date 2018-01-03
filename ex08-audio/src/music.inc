song_list:
  .word Title
  .word Main

sfx_list:
  .word sfx_bounce

envelopes_list:
  .word volume
  .word arpeggio
  .word pitch
  .word duty

volume:
  .word volume0
  .word volume1

arpeggio:
  .word arpeggio0
  .word arpeggio1

pitch:
  .word pitch0

duty:
  .word duty0

volume0:
  .byte 15,ENV_STOP
volume1:
  .byte 0,ENV_STOP

arpeggio0:
  .byte 0,3,6,ENV_LOOP,0
arpeggio1:
  .byte 0,ENV_STOP

pitch0:
  .byte 0,ENV_STOP

duty0:
  .byte 0,DUTY_ENV_STOP

Title:
  .byte 0
  .byte 6
  .byte 0
  .byte 5
  .word 0
  .word Title_square2
  .word Title_triangle
  .word 0
  .word 0

Title_square2:
Title_square2_loop:
  .byte CAL,<(Title_square2_0),>(Title_square2_0)
  .byte GOT
  .word Title_square2_loop

Title_triangle:
Title_triangle_loop:
  .byte CAL,<(Title_triangle_0),>(Title_triangle_0)
  .byte GOT
  .word Title_triangle_loop

Title_square2_0:
  .byte STV,0,SAR,1,STP,0,SDU,0,SL2,C3,D3,E3,F3,G3,A3,B3,SLA,C4
  .byte STV,1,SL1,A0
  .byte RET

Title_triangle_0:
  .byte STV,0,SAR,1,STP,0,SDU,0,SL3,C3,STV,1,SL1,A0,STV,0,SL3
  .byte C3,STV,1,SL1,A0,STV,0,SL3,E3,STV,1,SL1,A0,STV,0,SLC,C3
  .byte STV,1,SL1,A0
  .byte RET

Main:
  .byte 0
  .byte 6
  .byte 0
  .byte 5
  .word Main_square1
  .word Main_square2
  .word Main_triangle
  .word Main_noise
  .word 0

Main_square1:
Main_square1_loop:
  .byte CAL,<(Main_square1_0),>(Main_square1_0)
  .byte CAL,<(Main_square1_1),>(Main_square1_1)
  .byte GOT
  .word Main_square1_loop

Main_square2:
Main_square2_loop:
  .byte CAL,<(Main_square2_0),>(Main_square2_0)
  .byte CAL,<(Main_square2_0),>(Main_square2_0)
  .byte GOT
  .word Main_square2_loop

Main_triangle:
Main_triangle_loop:
  .byte CAL,<(Main_triangle_0),>(Main_triangle_0)
  .byte CAL,<(Main_triangle_0),>(Main_triangle_0)
  .byte GOT
  .word Main_triangle_loop

Main_noise:
Main_noise_loop:
  .byte CAL,<(Main_noise_0),>(Main_noise_0)
  .byte CAL,<(Main_noise_0),>(Main_noise_0)
  .byte GOT
  .word Main_noise_loop

Main_square1_0:
  .byte STV,1,SAR,1,STP,0,SDU,0,SLL,48,A0
  .byte RET

Main_square1_1:
  .byte STV,0,SAR,0,STP,0,SDU,0,SL2,G3,STV,1,SAR,1,SL1,A0,STV,0
  .byte SAR,0,SL2,G3,STV,1,SAR,1,SL1,A0,STV,0,SAR,0,SL4,G3,STV,1
  .byte SAR,1,SL2,A0,STV,0,SAR,0,G3,STV,1,SAR,1,SL1,A0,STV,0
  .byte SAR,0,SL2,G3,STV,1,SAR,1,SL1,A0,STV,0,SAR,0,SL3,G3,STV,1
  .byte SAR,1,SL1,A0,STV,0,SAR,0,SL3,G3,FS3,SL6,F3,SL5,F3,SL9
  .byte E3
  .byte RET

Main_square2_0:
  .byte STV,0,SAR,1,STP,0,SDU,0,SL3,E2,G2,SL6,E2,SL3,E2,B2,SL4
  .byte E2,SL3,E2,DS2,SL5,D2,STV,1,SL1,A0,STV,0,SL5,D2,SL3,E2,SL4
  .byte G2,SL2,E2
  .byte RET

Main_triangle_0:
  .byte STV,0,SAR,1,STP,0,SDU,0,SL4,E2,STV,1,SL2,A0,STV,0,SL4
  .byte E2,STV,1,SL2,A0,STV,0,C2,STV,1,SL1,A0,STV,0,SL2,D2,STV,1
  .byte SL1,A0,STV,0,SL4,E3,STV,1,SL2,A0,STV,0,SL4,E2,STV,1
  .byte SL2,A0,STV,0,SL4,E2,STV,1,SL2,A0,STV,0,C2,STV,1,SL1,A0
  .byte STV,0,SL2,D2,STV,1,SL1,A0,STV,0,SL4,E2,STV,1,SL2,A0
  .byte RET

Main_noise_0:
  .byte STV,0,SAR,1,STP,0,SDU,0,SL1,4,STV,1,SL2,A0,STV,0,SL1,9,STV,1
  .byte SL2,A0,STV,0,SL1,4,STV,1,SL2,A0,STV,0,SL1,9,STV,1,SL2
  .byte A0,STV,0,SL1,4,STV,1,SL2,A0,STV,0,SL1,9,STV,1,SL2,A0,STV,0
  .byte SL1,4,STV,1,A0,STV,0,4,9,STV,1,SL2,A0,STV,0,SL1,4,STV,1
  .byte SL2,A0,STV,0,SL1,9,STV,1,SL2,A0,STV,0,SL1,4,STV,1,SL2
  .byte A0,STV,0,SL1,9,STV,1,SL2,A0,STV,0,SL1,4,STV,1,SL2,A0,STV,0
  .byte SL1,9,STV,1,SL2,A0,STV,0,SL1,4,STV,1,A0,STV,0,4,9,STV,1
  .byte SL2,A0
  .byte RET

sfx_bounce:
  .byte 0, 1
  .byte 0, 1
  .word 0
  .word 0
  .word sfx_bounce_triangle
  .word 0
  .word 0

sfx_bounce_triangle:
  .byte CAL,<(sfx_bounce_triangle_0),>(sfx_bounce_triangle_0)
  .byte TRM
sfx_bounce_triangle_0:
  .byte SLL,1,STV,0,SAR,1,STP,0,SDU,0,FS4
  .byte RET

