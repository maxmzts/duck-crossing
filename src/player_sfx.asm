INCLUDE "constants.inc"

SECTION "SFX RAM", WRAM0
sfx_req: 		ds 1
sfx_step_cd: 	ds 1

SECTION "SFX Player", ROM0

;INIT
sfx_init::
   ld a, SFX_NONE
   ld [sfx_req], a
   ;;xor a
   ;;ld [sfx_step_cd], a
   ret

;PLAY
sfx_play::
   ld [sfx_req], a
   ret

;UPDATE
sfx_update::
   ld a, [sfx_req]
   cp SFX_NONE
   ret z

   ld b, a
   ld a, SFX_NONE
   ld [sfx_req], a
   ld a, b

   .dispatch:
      cp SFX_BIP
      jr z, .do_bip
      cp SFX_NOISE
      jr z, .do_noise
      cp SFX_CAR
      jr z, .do_car
      cp SFX_DIE
      jr z, .do_die
      cp SFX_STEP
      jr z, .do_step
      .ret

   .do_bip:
      ld a, $0C
      ld de, FRECUENCY
      call sfx_sq2_blip
      ret

   .do_noise:
      call sfx_noise_click
      ret

   .do_car:
   	call sfx_noise_car
   	ret

   .do_die:
   	call sfx_noise_die
   	ret

   .do_step:
   	call sfx_noise_click
   	ret