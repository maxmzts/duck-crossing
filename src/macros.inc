;; File for macros

MACRO MEMSET
   ld hl, \1
   ld a, \2
   ld b, \3
   call memset
ENDM

MACRO MEMCPY
   ld hl, \1
   ld de, \2
   ld b, \3
   call memcpy
ENDM

MACRO LOAD_TILE
   ld hl, \1 ; tile register
   ld de, \2 ; Format: $8xx0 (xx is the tile index)
   call load_tile
ENDM