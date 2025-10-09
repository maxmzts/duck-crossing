;; File for macros

MACRO MEMSET
   ld hl, \1
   ld a, \2
   ld b, \3
   call memset_256
ENDM

MACRO MEMCPY
   ld hl, \1
   ld de, \2
   ld b, \3
   call memcpy_256
ENDM