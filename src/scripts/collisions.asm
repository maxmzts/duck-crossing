;; IDs de los vehiculos
DEF CAR_TILES 			EQU $04
DEF CAR_FAST_TILES		EQU	$11
DEF CAR_SLOW_TILES		EQU	$13
DEF CAR_NORMAL_TILES	EQU	$0F
DEF CAR_TILES_SIZE 		EQU 2

DEF BUS_TILES 		EQU $15 ;; cambiar
DEF BUS_TILES_SIZE 	EQU 6


;; ID de victoria
DEF VIC_TILES 		EQU $0A
DEF VIC_TILES_SIZE 	EQU 4

SECTION "Variables colisiones", WRAM0
tile_colliding_pointer:: 	DS 2
tile_ID_colliding:: 		DS 1

SECTION "Tiles de vehiculos", ROM0
vehicle_ranges::
	DB CAR_TILES, 		CAR_TILES_SIZE		;;Coche rápido
	DB CAR_FAST_TILES,	CAR_TILES_SIZE		;;Coche lento
	DB $FF, $00 

SECTION "Gestion de colisiones", ROM0

update_physics::
	ld a, [w_scene_change_pending]
	cp 0
	ret nz
	
	ld hl, player_copy ;; usamos la copia de WRAM para no acceder a la OAM
	;; cargar puntero de tilemap
	ld a, [w_current_tilemap_rom_pointer] 
	ld d, a 
	ld a, [w_current_tilemap_rom_pointer+1]
	ld e, a 

	call get_address_of_tile_being_touched
	;; HL ahora tiene la dirección donde mirar del tilemap
	call collide
	ret

;; INPUT: HL (posicion de memoria del tilemap que mirar)
collide::
	ld a, [w_scene_change_pending]
	cp 0
	ret nz

	ld a, [state]
	cp 1
	ret z  ; abortar si el jugador ha muerto
	
	ld a, [w_victory_flag]
	cp 1
	ret z  ; abortar si hay victoria

	ld a, [hl]
	ld [tile_ID_colliding], a

	ld a, CAR_TILES
	ld b, CAR_TILES_SIZE
	call check_tile_collision

	ld a, CAR_FAST_TILES
	ld b, CAR_TILES_SIZE
	call check_tile_collision

	ld a, CAR_SLOW_TILES
	ld b, CAR_TILES_SIZE
	call check_tile_collision

	ld a, CAR_NORMAL_TILES
	ld b, CAR_TILES_SIZE
	call check_tile_collision


	ld a, BUS_TILES
	ld b, BUS_TILES_SIZE
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
	;; checkear si ya hay victoria
	ld a, [w_victory_flag]
	cp 1
	ret z
	
	ld a, VIC_TILES
	ld b, VIC_TILES_SIZE
	.loop
		cp [hl]
		call z, level_man_set_victory
		inc a
		dec b
	jr nz, .loop
	ret