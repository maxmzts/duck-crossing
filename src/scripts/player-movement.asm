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

MACRO START_MOVE
	;; Para moverse hay que reiniciar el contador
	;; de input lock e indicar la dir. de movimiento
	
	;; reset input_lock
   ld a, 16
   ld [input_lock], a
   ld a, \1
   ld [move_dir], a
ENDM

SECTION "Player Movement", ROM0	

update_player::
	;; check input lock
	ld a, [input_lock]
	or a
	jr nz, .skip_input

	;; no hay lock poner anular movimiento
	ld a, 4
	ld [move_dir], a

	;; read input if needed
	call read_input
	ret

	.skip_input:
   	ld hl, input_lock
   	dec [hl]   
   	ld a, [hl]
   	and %00000001 ;; dará 0 cuando el numero sea par
   	jr nz, .not_move
   		call continue_move	
   	.not_move:
   ret

read_input::
   ;; ACTIVAR BITS DE LECTURA
   ld a, SELECT_PAD
   ld [rJOYP], a  ;; we are selecting the buttons by inserting their rDir on rJOYP
   ld a, [rJOYP]
   ld a, [rJOYP]  ;; we do this 3 times to wait before bytes readjust correctly
   ld a, [rJOYP]


   bit RIGHT_PRESSED, a 
   jr z, .right_pad_pressed

   bit LEFT_PRESSED, a 
   jr z, .left_pad_pressed

   bit UP_PRESSED, a 
   jr z, .up_pad_pressed

   bit DOWN_PRESSED, a 
   jr z, .down_pad_pressed

   ret


   ;; ACTUALIZAR POSICIÓN DEL JUGADOR
   .right_pad_pressed:
      START_MOVE 0
   ret

   .left_pad_pressed:
      START_MOVE 1
   ret 

   .up_pad_pressed:
      START_MOVE 2
   ret

   .down_pad_pressed:
      START_MOVE 3
   ret



continue_move:
	ld a, [move_dir]

	cp 0
   jr z, .right

   cp 1
   jr z, .left

   cp 2
   jr z, .up

   cp 3
   jr z, .down
   ret


   ;; ACTUALIZAR POSICIÓN DEL JUGADOR
   .right:
      MOVE_SPRITE 1,1
   ret

   .left:
      MOVE_SPRITE -1,1
   ret 

   .up:
      MOVE_SPRITE -1,0
   ret

   .down:
      MOVE_SPRITE 1,0
   ret