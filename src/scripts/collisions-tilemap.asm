SECTION "Colisiones tilemap", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gets the Address in VRAM of the tile the entity is touching.
;; An entity touches a tile if it is placed in the same
;; region in the screen (they both overlap).
;; As entity is placed in pixel coordinates, this routine
;; has to convert pixel coordinates to tiles coordinates.
;; Each tile is 8x8 pixels. It also takes into account the
;; Game Boy visible screen area:
;; - Horizontal: pixels 8-167 visible (0-7 off-screen left)
;; - Vertical: pixels 16-159 visible (0-15 off-screen top)
;; - A sprite at (8,16) appears at screen top-left corner.
;;
;; Receives the address of the sprite component of an
;; entity in HL:
;;
;; Address: |HL| +1| +2| +3|
;; Value: [ y][ x][id][at]
;;
;; Example: Sprite at (24, 32)
;; TX = (24-8)/8 = 2
;; TY = (32-16)/8 = 2
;; Address = $9800 + 2*32 + 2 = $9842
;;
;; 📥 INPUT:
;; HL: Address of the Sprite Component
;; 🔙 OUTPUT;
;; HL: VRAM Address of the tile the sprite is touching
;: B:  Road Y Tile address
get_address_of_tile_being_touched::
	;; 1. Convert Y to TY, and X to TX
	ld a, [hl+]
	add 8  			;; Poner centro de sprite 
	call convert_y_to_ty
	ld e, a

	push hl

	;; check if TY is the one of the roads
	ld hl, road_tiles_level_1
	ld c, road_tiles_level_1.end - road_tiles_level_1
	call check_road_tile
	;; send road tile to offset
	ld hl, road_to_offset
	ld [hl], b

	pop hl

	ld a, [hl]
	add 8 			;; Poner centro de sprite
	call convert_x_to_tx
	;; 2. Calculate the VRAM address using TX and TY
	ld l, e
	call calculate_address_from_tx_and_ty
	ret

;; INPUT:  A (TY),  HL (road tiles array), C (number of roads)
;; OUTPUT: B (road tile to offset)
check_road_tile:
	ld b, 0
	.loop
		cp [hl]
		ret z
		inc b
		inc hl
		dec c
	jr nz, .loop

	;; no road --> skip routine

	pop af   ;; delete ret to get_address_of_tile_being_touched
	pop af   ;; delete push hl
	pop af   ;; delete ret to physics
	;pop af   ;; delete ret to mainloop
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Converts a value in pixel coordinates to VRAM tilemap
;; coordinates. The value is a sprite X-coordinate
;; and takes into account the non-visible 8 pixels
;; on the left of the screen.
;;
;; 📥 INPUT:
;; A: Sprite X-coordinate value
;; 🔙 OUTPUT:
;; A: Associated VRAM Tilemap TX-coordinate value
;:
convert_x_to_tx:
	sub 8
	srl a
	srl a
	srl a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Converts a value in pixel coordinates to VRAM tilemap
;; coordinates. The value is a sprite Y-coordinate
;; and takes into account the non-visible 16 pixels
;; on the upper side of the screen.
;;
;; 📥 INPUT:
;; A: Sprite Y-coordinate value
;; 🔙 OUTPUT:
;; A: Associated VRAM Tilemap TY-coordinate value
;:
convert_y_to_ty:
	sub 16
	srl a
	srl a
	srl a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculates an VRAM Tilemap Address from itx tile
;; coordinates (TX, TY). The tilemap is 32x32, and
;; address $9800 is assumed as the address of tile (0,0)
;; in tile coordinates.
;;
;; 📥 INPUT:
;; L: TY coordinate
;; A: TX coordinate
;; 🔙 OUTPUT:
;; HL: Address where the (TX, TY) tile is stored
;:
calculate_address_from_tx_and_ty:
	ld de, $9800
	ld h, 0

	add hl, hl  ;; x2
	add hl, hl  ;; x4
	add hl, hl  ;; x8
	add hl, hl  ;; x16
	add hl, hl  ;; x32

	add hl, de

	add l
	jr nc, .skip_carry
	inc h
	.skip_carry
	ld l, a
	
	ret
