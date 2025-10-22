include "macros.inc"

SECTION "Initial Car Data", ROM0
;16x16 obj     Y     X   Tile   Att
sprite_car: DB   24,   16,   $24,   %00000000
         	DB   24,   24,   $26,   %00000000

SECTION "Car OAM", OAM
car: DS 8

SECTION "Car variables", WRAM0
speed_control: DS 1

SECTION "Car Code", ROM0

init_car::
	MEMCPY sprite_car, car, 8
	;; load sprite tiles
   MEMCPY tiles_car, $8000 + ($24 * $10), 64
   xor a
   ld [speed_control], a 
   ret

update_car::
	ld hl, speed_control
	inc [hl]   
	ld a, [hl]
	and %0000011 ;; dará 0 cuando el numero sea par
	jr nz, .not_move
		call move_car	
	.not_move:
   ret
	
move_car::
	ld hl, car
	inc hl
	ld a, [hl]
	inc a
	ld [hl], a
	ld hl, car+5
	ld a, [hl]
	inc a
	ld [hl], a
	ret

SECTION "Car tiles", ROM0
tiles_car: 
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
DB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF