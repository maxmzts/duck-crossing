INCLUDE "constants.inc"
include "macros.inc"

MACRO MOVE_SPRITE
   ld hl, player_copy + \2
   ld a, [hl]
   add \1
   ld [hl], a
   ld hl, player_copy + 4 + \2
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
sprite:  DB   140,   80,   $20,   %00000000
         DB   140,   88,   $22,   %00000000

SECTION "Player", OAM
player: DS 8

SECTION "Player copy", WRAM0
player_copy: DS 8

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
   MEMCPY duck_player_down, $8000 + ($20 * $10), 64

   ;; cargar datos iniciales del jugador a la OAM
   MEMCPY sprite, player, 8 
   MEMCPY player, player_copy, 8 

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
   call press_a_init
   
   ret

destroy_player::
   MEMSET player, 0, 8 
   ret

update_player::
   ;; check dead
   ld a, [state]
   cp 0
   jp nz, read_restart

   ;; check input lock
   ld a, [input_lock]
   or a
   jr nz, .input_lock

   ;; no hay lock poner anular movimiento
   ld a, 4
   ld [move_dir], a

   ;; read input if needed
   call read_input
   call move

   ret

   .input_lock
   ld hl, input_lock
   dec [hl]   
   ld a, [hl]
   and %00000001 ;; dará 0 cuando el numero sea par
   ret z
   call continue_move
   ret

render_player::
   ;; check dead
   ld a, [state]
   cp 0
   ret nz

   ;; check input lock
   ld a, [input_lock]
   or a
   ret z

   call update_player_tiles

   MEMCPY player_copy, player, 8
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

update_player_tiles::
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

    .loop:


.right:
    MEMCPY duck_player_right + 4, $8000 + ($20 * $10) + 4, 56
    jr .done

.left:
    MEMCPY duck_player_left + 4, $8000 + ($20 * $10) + 4, 56
    jr .done

.up:
    MEMCPY duck_player_up + 4, $8000 + ($20 * $10) + 4, 56
    jr .done

.down:
    MEMCPY duck_player_down + 4, $8000 + ($20 * $10) + 4, 54

.done:
    ret

read_restart:
   ;; Verificar input de botones (A, B, Start, Select)
   ld a, SELECT_BUTTONS
   ld [rJOYP], a
   ld a, [rJOYP]
   ld a, [rJOYP]  ; Lectura doble para estabilidad

   ;; Invertir bits (0 = presionado)
   cpl
   and $0F

   ;; Si algún botón está presionado, iniciar nivel
   cp 0
   ;; reiniciar escena si se ha pulsado la A
   call nz, restart

   ret

restart:
   call level_man_clear
   ld a, [w_current_scene]
   call scene_manager_change_scene
   ret

kill_player:
   ;; retornar si ya está muerto
   ld a, [state]
   cp 1
   ret z

   call vblank_with_interrupt

   MEMCPY duck_player_dead_up, $8000 + ($20 * $10), 64

   push af
   ld a, SFX_KILL
   call sfx_play
   pop af

   ld a, SONG_DEATH
   call music_play_id

   ld a, 1
   ld [state], a
   
   call press_a_show
   
   ret
