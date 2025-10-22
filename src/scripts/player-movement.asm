INCLUDE "constants.inc"
include "macros.inc"

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

SECTION "Initial Data", ROM0
;16x16 obj     Y     X   Tile   Att
sprite:  DB   100,   64,   $20,   %00000000
         DB   100,   72,   $22,   %00000000

SECTION "Player", OAM
player: DS 8

SECTION "Player Variables", WRAM0

input_lock:       DS 1
move_dir:         DS 1 ; 0 = right, 1 = left, 2 = up, 3 = down, 4 = none
previous_input:   DS 1
current_input:    DS 1
pressed_input:    DS 1
state:            DS 1 ; 0 = alive, 1 = dead

SECTION "Player Movement", ROM0	

init_player::
   ;; load sprite tiles
   MEMCPY duck_player, $8000 + ($20 * $10), 64

   ;; cargar datos iniciales del jugador a la OAM
   MEMCPY sprite, player, 8 

   ;; inicializar variables
   xor a
   ld [input_lock], a
   ld [state], a
   ld a, 4
   ld [move_dir], a
   ld a, 15
   ld [previous_input], a
   ld [current_input], a
   ld [pressed_input], a
   ret

update_player::
   ;; check input lock
   ld a, [state]
   cp 0
   ret nz

	;; check input lock
	ld a, [input_lock]
	or a
	ret nz

	;; no hay lock poner anular movimiento
	ld a, 4
	ld [move_dir], a

	;; read input if needed
	call read_input
   call move

	ret

render_player::
   ;; check input lock
   ld a, [state]
   cp 0
   ret nz

   ;; check input lock
   ld a, [input_lock]
   or a
   ret z

   ld hl, input_lock
   dec [hl]   
   ld a, [hl]
   and %00000001 ;; dará 0 cuando el numero sea par
   ret z
   call continue_move
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
      push af
      ld a, SFX_MOVE_R
      call sfx_play
      pop af
      START_MOVE 0
   ret

   .left_pad_pressed:
      push af
      ld a, SFX_MOVE_L
      call sfx_play
      pop af
      START_MOVE 1
   ret 

   .up_pad_pressed:
      push af
      ld a, SFX_MOVE_U
      call sfx_play
      pop af
      START_MOVE 2
   ret

   .down_pad_pressed:
      push af
      ld a, SFX_MOVE_D
      call sfx_play
      pop af
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

kill_player:
   push af
   ld a, SFX_KILL
   call sfx_play
   pop af

   ld a, SONG_DEATH
   call music_play_id
   
   ld a, 1
   ld [state], a
   ret