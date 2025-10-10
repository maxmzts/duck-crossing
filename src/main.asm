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
   call clear_oam

   call enable_obj

   ;; define palletes
   ld a, DEFAULT_PALETTE
   ld [rBGP], a
   ld [rOBJP0], a

   call load_tiles

   call load_tilemap

   call lcd_on
   ret

load_tiles::
   ;; environment tiles
   ld hl, metal_wall_tile
   ld de, $8010
   call load_tile

   ;; load sprite tiles
   MEMCPY tiles_player, $8000 + ($20 * $10), 64
   MEMCPY sprite, OAM_START, 8 
   ret

load_tilemap::
   ld hl, test_tilemap
   call load_32x32_tilemap
   ret

SECTION "Initial Data", ROM0
;16x16 obj     Y     X   Tile   Att
sprite:  DB   24,   16,   $20,   %00000000
         DB   24,   24,   $22,   %00000000

SECTION "OAM DMA", HRAM

OAMDMA::
;DS rutinaDMA.fin - rutinaDMA