INCLUDE "constants.inc"

MACRO MOVE_SPRITE
   ld hl, player + \2
   ld a, [hl]
   add \1
   ld [hl], a
   ld hl, player + 4 + \2
   ld a, [hl]
   add \1
   ld [hl], a
ENDM

SECTION "Player Movement", ROM0

read_input::
   ;; ACTIVAR BITS DE LECTURA
   ld a, SELECT_PAD
   ld [rJOYP], a  ;; we are selecting the buttons by inserting their rDir on rJOYP
   ld a, [rJOYP]
   ld a, [rJOYP]  ;; we do this 3 times to wait before bytes readjust correctly
   ld a, [rJOYP]


   bit RIGHT_PRESSED, a 
   jr z, right_pad_pressed

   bit LEFT_PRESSED, a 
   jr z, left_pad_pressed

   bit UP_PRESSED, a 
   jr z, up_pad_pressed

   bit DOWN_PRESSED, a 
   jr z, down_pad_pressed
   ret


   ;; ACTUALIZAR POSICIÓN DEL JUGADOR
   right_pad_pressed:
      MOVE_SPRITE 1,1
   ret

   left_pad_pressed:
      MOVE_SPRITE -1,1
   ret 

   up_pad_pressed:
      MOVE_SPRITE -1,0
   ret

   down_pad_pressed:
      MOVE_SPRITE 1,0
   ret