include "constants.inc"
include "macros.inc"

SECTION "Main Loop", ROM0[$150]

main::
   call init
   ;call fade_out_black
   ;call fade_in_black
   .game_loop:
      call physics
      ;call vblank
      ;call vblank_interruption
      call vblank_with_interrupt
      call update_player
      call update_car
   jr .game_loop
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)

init::
   di
   call lcd_off

   call clear_background
   call clear_oam

   call enable_obj

   ;; definir paletas 
   ld a, DEFAULT_PALETTE
   ld [rBGP], a
   ld [rOBJP0], a

   ;; inicializar variables de jugador
   call init_player

   ;; Inicializar interrupciones
   call enable_vblank_interrupt
   call enable_lyc_interrupt

   ;; coche de prueba
   call init_car

   call load_tiles

   call load_tilemap

   call lcd_on
   reti

load_tiles::
   ;; environment tiles
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