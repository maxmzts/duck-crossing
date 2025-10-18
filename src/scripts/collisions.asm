DEF PLAYER_CENTER_Y EQU 9 
DEF PLAYER_CENTER_X EQU 8
DEF CAR_CENTER_Y EQU 12 
DEF CAR_CENTER_X EQU 8 
DEF Y_SIZE EQU 15
DEF X_SIZE EQU 16


SECTION "Variables colisiones", WRAM0
object_1_center: 		DS 1 
object_2_center: 		DS 1
min_size_btw_centers:	DS 1
is_colliding:			DS 1 ; 0 = false, 1 = true

road_to_offset::   		DS 1

SECTION "Gestion de colisiones", ROM0

physics::
	ld hl, player
	call get_address_of_tile_being_touched
	;; hl now has the tile address on a road
	;; we need to add the scroll ofset to the
	;; address
	push hl
	call get_scroll_tile_offset
	;; returns the offset in a
	pop hl
	add l
	ld l, a

	;; check if the tile is a car tile
	ld a, $04
	cp [hl]
	ld a, $05
	cp [hl]

	call kill_player

	ret

;; OUTPUT: A (scroll tile offset)
get_scroll_tile_offset:
	ld a, [road_to_offset]
	ld hl, w_roads_level_1+2 ;; last scx
	.loop:
		cp 0
		jr z, .endloop
		inc hl
		inc hl
		inc hl
		dec a
	jr .loop
	.endloop:
	ld a, [hl]
	srl a  ;; /2
	srl a  ;; /4
	srl a  ;; /8
	ret
	
old_physics::
	;; Centro Y jugador
	ld a, [player]
	add PLAYER_CENTER_Y
	ld [object_1_center], a

	;; Centro Y coche
	ld a, [car]
	add CAR_CENTER_Y
	ld [object_2_center], a

	ld a, 15
	ld [min_size_btw_centers], a

	xor a
	ld [is_colliding], a

	call check_collision

	;; si hay colision en Y
	;; se comprueba la X
	ld a, [is_colliding]
	cp 0
	jr z, .end

	;; Centro X jugador
	ld a, [player+1]
	add PLAYER_CENTER_X
	ld [object_1_center], a

	;; Centro X coche
	ld a, [car+1]
	add CAR_CENTER_X
	ld [object_2_center], a

	ld a, 16
	ld [min_size_btw_centers], a

	xor a
	ld [is_colliding], a

	call check_collision

	;; si hay colision matamos
	;; al jugador
	ld a, [is_colliding]
	cp 0
	call nz, kill_player

	.end
	ret



check_collision::
	ld a, [object_1_center]
	ld e, a
	ld a, [object_2_center]
	ld b, a

	ld a, [min_size_btw_centers]
	ld d, a


	;; sumamos el espacio minimo para comprobar la 
	;; colision inferior del objeto 1
	;; si el resultado tiene carry (cp da negativo)
	;; no hay colision

	ld a, e
	add d
	cp b

	jr c, .no_colision

	;; restamos el espacio minimo para comprobar la 
	;; colision superior del objeto 2
	ld a, e
	sub d
	cp b

	jr nc, .no_colision

	ld a, 1 ;; hay colision
	ld [is_colliding], a
	ret
	
	.no_colision:
	ld a, 0 ;; hay colision
	ld [is_colliding], a
	ret