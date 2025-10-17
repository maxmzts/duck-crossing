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

   call mute_APU
   ld b, 30
   call wait_frames
   call sound_init
   call sfx_init
   call input_init

   .mainloop:

      call check_keyboard_fx
      call sfx_update

   jr .mainloop

   ;;Esto es para que suene un sonido detras de otro, sin usar botones
   ;;ld a, $0C
   ;;ld de, $06D7
   ;;call sfx_sq2_blip

   ;;ld b, 60
   ;;call wait_frames

   ;;call sfx_noise_click

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
