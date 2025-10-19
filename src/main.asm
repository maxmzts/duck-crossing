INCLUDE "constants.inc"

SECTION "Input RAM", WRAM0
btn_prev: ds 1

SECTION "Entry point", ROM0[$150]

mute_APU:
   xor a
   ld [NR52], a
   ret

;;Encender la APU y mandar todos los canale spor ambos lados
sound_init::
   ;;Encender APU
   ld a, $80            ;;1000 0000 Audio ON
   ld [NR52], a

   ;;Volumen maestro L/R
   ld a, $77            ;;0111 0111 Salida igual por ambos lados
   ld [NR50], a

   ;;Panning
   ld a, $FF            ;;1111 1111 Todos los canales por ambos lados
   ld [NR51], a

   ret

input_init::
   xor a
   ld [btn_prev], a
   ret

;;Para meter pausas temporales entre frames. Ahora mismo no se usa porque lo detecta por las teclas.
;;Se usa para que un sonido suene, espere y suene el otro sonido.
wait_frames:
   .w_in:
      ld a, [rLY]
      cp 144
      jr c, .w_in

   .w_out:
      ld a, [rLY]
      cp 144
      jr nc, .w_out
      dec b
      jr nz, wait_frames
   ret

joy_read_edges:

   ld a, $30
   ld [rJOYP], a

   ld a, SELECT_BUTTONS
   ld [rJOYP], a
   ld a, [rJOYP]
   ld a, [rJOYP]
   ld a, [rJOYP]

   cpl
   and %00001111
   ld b, a

   ld a, [btn_prev]
   cpl
   and b
   ld d, a

   ld a, b
   ld [btn_prev], a

   ld a, $30
   ld [rJOYP], a

   ld a, d
   ret

check_keyboard_fx:
   call joy_read_edges

   bit 0, a

   jr z, .b
      ;;ld a, $0C version sin player
      ;;ld de, FRECUENCY
      ;;call sfx_sq2_blip
      ld a, SFX_BIP
      call sfx_play

   .b:
      bit 1, a
      jr z, .sel
         ld a, SFX_DIE
         call sfx_play
         ;;call sfx_noise_click Version sin players
   .sel:
      bit 2, a
      jr z, .start
         ld a, SFX_CAR
         call sfx_play
   .start:
      bit 3, a
      jr z, .end
         ld a, SFX_DIE
         call sfx_play
   .end:
   ret

main::
   call init
   ;call fade_out_black
   ;call fade_in_black
   .game_loop:
      ;call vblank
      ;call vblank_interruption
      call update_player
      ;;sonido
      call sfx_update
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

   ;; Inicializar el sonido
   call mute_APU
   call sound_init
   call sfx_init

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