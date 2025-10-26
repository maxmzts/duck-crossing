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

	ld a, [hl]
	add 8 			;; Poner centro de sprite
	call convert_x_to_tx
	ld d, a

	;; 2. check if TY is the one of the roads
	ld hl, w_current_level_roads + 1 ; TY data
	ld a, [w_current_level_roads_count]
	ld c, a
	ld a, e
	call check_road_tile
	cp 0
	jr z, .update_pointer
	call get_scroll_tile_offset
	push de 
	call fix_tile_offset
	pop de
	ld d, a  ;; introducir fixed tile offset


	;; 3. Calculate the VRAM address using TX and TY
	.update_pointer
	ld l, e
	ld a, d
	call calculate_address_from_tx_and_ty
	;; hl tiene la posicion de VRAM

	;; actualizar apuntador 
	ld a, h
	ld [tile_colliding_pointer], a 
	ld a, l
	ld [tile_colliding_pointer+1], a 
	ret

;; INPUT:  A (TY),  HL (road tiles array), C (number of roads)
;; OUTPUT: B (road tile to offset)
check_road_tile:
	ld b, 0
	.loop
		cp [hl]
		ret z
		inc b
		;; go to next TY slot of the array
		inc hl
		inc hl
		inc hl
		inc hl
		dec c
	jr nz, .loop

	;; no road --> skip routine
	ld a, 0
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT:  B (road tile to offset)
;; OUTPUT: A (scroll tile offset)
get_scroll_tile_offset:
	ld a, b
	ld hl, w_current_level_roads+3 ;; last scx
	.loop:
		cp 0
		jr z, .endloop
		inc hl
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para comprobar si el scroll que se debe 
;; aplicar en tiles produciría un overflow. Buscamos
;; evitar que se compruebe la colisión en la línea 
;; de abajo. Pasos:
;;	
;; 1.   Se calcula los tiles necesarios para hacer overflow
;; 2.   Se resta los tiles de scroll con lo anterior
;; 3.A  Si da negativo es que no se hace overflow
;; 3.B  Si da positivo es que se hace overflow y se tiene
;;      que restar la diferencia
;;
;; INPUT:  D (TX), A (scroll tile offset)
;; OUTPUT: A (fixed scroll tile offset)
fix_tile_offset:
	push af     ; guardar TScroll
	ld a, $1F   ; End of X line
	sub d       ; Final - TX = tiles to overflow (TTO)
	ld b, a     ; B = TTO

	;; comprobar si se produce overflow
	pop af 		; recuperar TScroll
	ld c, a     ; C = TScroll 
	sub b       ; TScroll - TTO = TDiff
	ld b, a     ; B = TDiff  (TTO ya no hace falta)
	ld a, d     ; A = TX
	jr c, .skip
	
	;; si no carry, se produce overflow, se debe restar la diferencia
	sub b   	; TX - TDiff
	ret

	;; si hay carry, no se produce overflow, se suma TScroll normalmente
	.skip:
	add c		; TX + TScroll
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT:  A (Sprite X)
;; OUTPUT: A (Sprite TX)

convert_x_to_tx:
	sub 8
	srl a
	srl a
	srl a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT:  A (Sprite Y)
;; OUTPUT: A (Sprite TY)

convert_y_to_ty:
	sub 16
	srl a
	srl a
	srl a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculates an VRAM Tilemap Address from itx tile
;; coordinates (TX, TY). 
;;
;; INPUT:   L (TY),  A (TX)
;; OUTPUT:  HL (Address where the (TX, TY) tile is stored)

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
