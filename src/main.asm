include "constants.inc"
include "macros.inc"

SECTION "Main Loop", ROM0[$150]

main::
   call init
   call fade_out_black
   call fade_in_black
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)

init::
   call lcd_off

   call clear_background

   ld a, DEFAULT_PALETTE
   ld [rBGP], a

   call load_tiles

   call load_tilemap

   call lcd_on
   ret

load_tiles::
   ld hl, metal_wall_tile
   ld de, $8010
   call load_tile
   ret

load_tilemap::
   ld hl, test_tilemap
   call load_32x32_tilemap
   ret

SECTION "OAM DMA", HRAM

OAMDMA::
;DS rutinaDMA.fin - rutinaDMA