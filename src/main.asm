include "constants.inc"
include "macros.inc"

SECTION "Main Loop", ROM0[$150]

main::
   call init
   ;call fade_out_black
   ;call fade_in_black
   .game_loop:
      ;call vblank
      ;call vblank_interruption
      call update_player
      call vblank_with_interrupt
      call reset_vblank_flag
      call restart_roads_scroll_loop
      call render_player
      call physics
      ;call update_car
   jr .game_loop
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)

init::
   call lcd_off

   di

   call clear_background
   call clear_oam

   call enable_obj

   ;; definir paletas 
   ld a, DEFAULT_PALETTE
   ld [rBGP], a
   ld a, %11100001
   ld [rOBJP0], a

   ;; inicializar variables de jugador
   call init_player

   ;; Inicializar interrupciones
   call enable_interrupts

   ;; coche de prueba
   call init_car

   call load_tiles

   call load_tilemap

   call init_level_1_roads

   call lcd_on
   reti

load_tiles::
   MEMCPY Tileset1, $8000, Tileset1.end - Tileset1
   ret

load_tilemap::
   ld hl, level1
   call load_32x32_tilemap
   ret

enable_interrupts:
   call enable_vblank_interrupt
   call enable_lyc_interrupt
   ;; clear rIF before any interrupt
   xor a
   ldh [rIF], a
   ret


SECTION "OAM DMA", HRAM

OAMDMA::
;DS rutinaDMA.fin - rutinaDMA