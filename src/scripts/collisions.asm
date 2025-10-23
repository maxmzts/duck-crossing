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

tile_ID_colliding:: DS 1

SECTION "Gestion de colisiones", ROM0

physics::
	ld hl, player
	call get_address_of_tile_being_touched
	;; hl now has the tile address on a road

	;; check if the tile is a car tile
	ld a, $04
	cp [hl]
	call z, kill_player
	ld a, $05
	cp [hl]
	call z, kill_player
	
	ret



	