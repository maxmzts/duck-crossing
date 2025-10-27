include "constants.inc"
include "macros.inc"

SECTION "Main Loop", ROM0[$150]
main::
   call init

   .game_loop:
      ;; Procesar cambios de escena si hay pendientes
      call scene_manager_update

      ;; Actualizar lógica de la escena actual
      call scene_manager_update_logic

      call sfx_update
      call music_update

      ;; Esperar VBlank
      call vblank_with_interrupt
      call reset_vblank_flag

      ;; Renderizar la escena actual
      call scene_manager_render

   jr .game_loop

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)

init::
   call lcd_off
   di
   call clear_background
   call clear_oam
   call enable_obj

   ;; Definir paletas 
   ld a, DEFAULT_PALETTE
   ld [rBGP], a
   ld a, %11100001
   ld [rOBJP0], a

   ;; CARGAR TILES PRIMERO (antes de cualquier escena)
   call load_tiles

   ;;SFX
   call mute_APU
   call sound_init
   call sfx_init

   ;;Musica
   call music_init
   ld a, SONG_MENU
   call music_play_id

   ;; Inicializar interrupciones
   call enable_interrupts


   ;; INICIALIZAR SCENE MANAGER CON PANTALLA DE TÍTULO
   ld a, SCENE_TITLE
   call scene_manager_change_scene

   call lcd_on
   ;; Forzar primer cambio de escena a título
   call scene_manager_update
   call lcd_off

   call lcd_on
   reti

load_tiles::
   MEMCPY Tileset1, $8000, Tileset1.end - Tileset1
   ret

enable_interrupts::
   call enable_vblank_interrupt
   ;; Clear rIF before any interrupt
   xor a
   ldh [rIF], a
   ret
