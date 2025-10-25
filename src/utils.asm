INCLUDE "constants.inc"
INCLUDE "macros.inc"

SECTION FRAGMENT "Utils", ROM0

lcd_on::
	ld hl, rLCDC
	set 7, [hl]
	ret

lcd_off::
	di
	call vblank
	ld hl, rLCDC
	res 7, [hl]
	ei
	ret

vblank::
	ld hl, rLY
	ld a, VBLANK_LAYER
	.loop:
		cp [hl]
	jr nz, .loop
	ret

;; Espera al modo 0 de la PPU (Hblank)
wait_hblank_start::
	ld hl, rLCD_STAT
	ld a, %00000011
	.loop:
		and [hl]
	jr nz, .loop
	ret

;; Input:  C (Vblank count)
multiple_vblanks::
	ld hl, rLY
	ld a, VBLANK_LAYER
	.loop:
		cp [hl]
	jr nz, .loop
	dec c
	jr nz, .espera
	ret

	.espera:
		xor a
		cp [hl]
	jr nz, .espera
	jr multiple_vblanks

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

enable_obj::
	ld hl, rLCDC
	set rLCDC_obj_enable, [hl]
	set rLCDC_16x8_obj_enable, [hl]
	ret

;; Input:  A (HIGH byte of the region to copy)
rutinaDMA::
	ld [rDMA], a ;; activates the copy of the given region XX00
	ld a, 40
	.espera:
		dec a
	jr nz, .espera
	ret
.fin:

;; Input:  HL (Source Tile), DE (Destiny format:$8XX0)
load_tile::
	ld b, $10
	call memcpy
	ret

;; Screen has 1024 bytes of data
clear_background::
	ld hl, VRAM_SCREEN
	ld a, 0
	ld b, 255
	call memset ; 256 bytes cleared
	ld b, 255
	call memset ; 512 bytes cleared
	ld b, 255
	call memset ; 768 bytes cleared
	ld b, 255
	call memset ; 1024 bytes cleared
	ret

clear_oam::
	ld hl, OAM_START
	ld a, 0
	ld b, 160
	call memset
	ret

;; Input:  HL (Tilemap)
load_32x32_tilemap::
	ld de, VRAM_SCREEN
	ld b, 255
	call memcpy ; 256 bytes cleared
	ld b, 255
	call memcpy ; 512 bytes cleared
	ld b, 255
	call memcpy ; 768 bytes cleared
	ld b, 255
	call memcpy ; 1024 bytes cleared
	ret

fade_out_black::
	ld c, 10
	call multiple_vblanks
	ld a, FADE_1_PALLETE
	ld [rBGP], a

	ld c, 10
	call multiple_vblanks
	ld a, FADE_2_PALLETE
	ld [rBGP], a
	
	ld c, 10
	call multiple_vblanks
	ld a, FADE_3_PALLETE
	ld [rBGP], a
	
	ld c, 10
	call multiple_vblanks
	ld a, FADE_4_PALLETE
	ld [rBGP], a
	
	ld c, 10
	call multiple_vblanks
	ld a, FADE_5_PALLETE
	ld [rBGP], a
	
	ld c, 10
	call multiple_vblanks
	ld a, FADE_6_PALLETE
	ld [rBGP], a
	
	ret

fade_in_black::
	ld c, 10
	call multiple_vblanks
	ld a, FADE_6_PALLETE
	ld [rBGP], a

	ld c, 10
	call multiple_vblanks
	ld a, FADE_5_PALLETE
	ld [rBGP], a

	ld c, 10
	call multiple_vblanks
	ld a, FADE_4_PALLETE
	ld [rBGP], a

	ld c, 10
	call multiple_vblanks
	ld a, FADE_3_PALLETE
	ld [rBGP], a

	ld c, 10
	call multiple_vblanks
	ld a, FADE_2_PALLETE
	ld [rBGP], a

	ld c, 10
	call multiple_vblanks
	ld a, FADE_1_PALLETE
	ld [rBGP], a

	ld c, 6
	call multiple_vblanks
	ld a, DEFAULT_PALETTE
	ld [rBGP], a

	ret

mute_APU::
	xor a
	ld [NR52], a
	ret

sound_init::
	ld a, $80
	ld [NR52], a

	ld a, $77
	ld [NR50], a

	ld a, $FF
	ld [NR51], a

	ret
	