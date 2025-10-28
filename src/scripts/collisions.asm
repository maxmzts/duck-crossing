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
	;; ✅ NUEVO: No actualizar física si hay cambio de escena pendiente
	ld a, [w_scene_change_pending]
	cp 0
	ret nz
	
	ld hl, player_copy ;; usamos la copia de WRAM para no acceder a la OAM
	;; actualizar puntero a VRAM
	call get_address_of_tile_being_touched
	ret

physics::
	;; ✅ NUEVO: No ejecutar física si hay cambio de escena pendiente
	ld a, [w_scene_change_pending]
	cp 0
	ret nz
	
	;; ✅ NUEVO: No ejecutar física si ya hay victoria detectada
	ld a, [w_victory_flag]
	cp 1
	ret z  ; Si ya hay victoria, no checkear más colisiones
	
	;; Tomar puntero a VRAM calculado en el update
	;; CORRECCIÓN: El orden ahora es correcto
	ld a, [tile_colliding_pointer]
	ld h, a                            ; tile_colliding_pointer tiene el byte alto (H)
	ld a, [tile_colliding_pointer+1]
	ld l, a                            ; tile_colliding_pointer+1 tiene el byte bajo (L)

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
	;; ✅ NUEVO: Doble verificación - no checkear si ya hay victoria
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