INCLUDE "constants.inc"
INCLUDE "macros.inc"

SECTION "Utils", ROM0

lcd_on::
	ld hl, rLCDC
	set 7, [hl]
	ret

lcd_off::
	call vblank
	ld hl, rLCDC
	res 7, [hl]
	ret

vblank::
	ld hl, rLY
	ld a, VBLANK_LAYER
	.loop:
		cp [hl]
	jr nz, .loop
	ret

;; Input:  HL (Source), A (Value), B (Bytes) 
memset::
		ld [hl+], a
		dec b
	jr nz, memset
	ret


;; Input:  HL (Source), A (Value), B (Bytes)
memcpy::
		ld a, [hl+]
		ld [de], a
		inc de
		dec b
	jr nz, memcpy
	ret

;; Input:  D (HIGH byte of the region to copy)
rutinaDMA::
	ld [rDMA], d ;; activates the copy of the given region XX00
	ld a, 40
	.espera:
		dec a
	jr nz, .espera
	ret
.fin