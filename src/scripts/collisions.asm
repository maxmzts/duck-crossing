;; IDs de los vehiculos
DEF CAR_TILES 		EQU $04
DEF CAR_TILES_SIZE 	EQU 2

DEF BUS_TILES 		EQU $04 ;; cambiar
DEF BUS_TILES_SIZE 	EQU 2


;; ID de victorua
DEF VIC_TILES 		EQU $0A
DEF VIC_TILES_SIZE 	EQU 4

SECTION "Variables colisiones", WRAM0
tile_colliding_pointer:: 	DS 2
tile_ID_colliding:: 		DS 1

SECTION "Gestion de colisiones", ROM0

update_physics::
	ld hl, player_copy ;; usamos la copia de WRAM para no acceder a la OAM
	;; actualizar puntero a VRAM
	call get_address_of_tile_being_touched
	ret

physics::
	;; Tomar puntero a VRAM calculado en el update
	ld a, [tile_colliding_pointer]
	ld h, a
	ld a, [tile_colliding_pointer+1]
	ld l, a

	ld a, [hl]
	ld [tile_ID_colliding], a

	ld a, CAR_TILES
	ld b, CAR_TILES_SIZE
	call check_tile_collision

	call check_victory_collision
	
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función genérica para comprobar si el jugador ha 
;; colisionado con un vehículo. Debe proporcionarse
;; el primer ID del vehiculo y la cantidad de tiles
;;
;; INPUT:  HL (TX-TY), A (Start ID), B (ID amount)
check_tile_collision:
		cp [hl]
		call z, kill_player
		inc a
		dec b
	jr nz, check_tile_collision
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Como la anterior pero para la victoria en concreto
;;
;; INPUT:  HL (TX-TY)
check_victory_collision:
	ld a, VIC_TILES
	ld b, VIC_TILES_SIZE
	.loop
		cp [hl]
		call z, level_man_set_victory
		inc a
		dec b
	jr nz, .loop
	ret
	