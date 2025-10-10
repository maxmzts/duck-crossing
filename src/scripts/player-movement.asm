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

SECTION "Player Variables", WRAM0

input_lock:       DS 1
move_dir:         DS 1 ; 0 = right, 1 = left, 2 = up, 3 = down, 4 = none
previous_input:   DS 1
current_input:    DS 1
pressed_input:    DS 1

SECTION "Player Movement", ROM0	

init_player::
   xor a
   ld [input_lock], a
   ld a, 4
   ld [move_dir], a
   ld a, 15
   ld [previous_input], a
   ld [current_input], a
   ld [pressed_input], a
   ret

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
   call move

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
   ld a, [current_input]
   ld [previous_input], a

   ;; ACTIVAR BITS DE LECTURA
   ld a, SELECT_PAD
   ld [rJOYP], a  ;; we are selecting the buttons by inserting their rDir on rJOYP
   ld a, [rJOYP]
   ld a, [rJOYP]  ;; we do this 3 times to wait before bytes readjust correctly
   ld a, [rJOYP]

   ld [current_input], a

   ;; solo se contará que un input es valido
   ;; si la tecla no estaba pulsada previamente

   ;; para ello usamos una operacion logica
   ;; si son iguales y negamos uno, el resultado
   ;; será cero. Si es cero omitimos el input
   
   ld a, [previous_input]  ;; previous
   ld b, a
   ld a, [current_input]   ;; current
   cpl                     ;; !current
   and b                   ;; !current && previous
   jr z, .delete_input     ;; será 0 cuando sean iguales 
   cpl 
   ld [pressed_input], a
   ret

   .delete_input:
   ld a, 15 
   ld [pressed_input], a
   ret   

move:
   ld a, [pressed_input]

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