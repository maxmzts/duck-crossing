include "constants.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOCUMENTACION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interrupción de VBlank
;;
;; Para activar la interrupción de VBlank, se
;; debe set del bit 0 de la rIE (interrupt
;; enable). Luego esto hará que cuando la CPU
;; esté en HALT y detecte que empieza VBlank, 
;; se saltará automáticamente a la dirección
;; $0040. Ahí tenemos 8 bytes para definir un
;; handler.
;;
;; En nuestro caso simplemente pone un flag 
;; de la WRAM a 1 para que la función de wait
;; vblank sepa que halt ha terminado por la 
;; interrupción de vblank
;;
;; CHECKEAR PORQUE EL JUEGO ES MÁS LENTO  
;; USANDO ESTA TECNICA
;;
;; En pandocs se indica que:
;; Note though that a VBlank interrupt might 
;; happen after the cp instruction and before
;; the jr, in which case the interrupt would 
;; go unnoticed by the procedure, which would
;; jump again into a halt.
;;
;; Parece que algo asi ocurre porque el juego
;; se siente que va a 30 frames.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "VBLANK Handler", ROM0[$0040]

vblank_interrupt_handler::
	;; set flag to zero
	ld a, 1
	ld [vram_flag], a
	reti

SECTION FRAGMENT "Utils", ROM0

enable_vblank_interrupt::
	ld hl, rIE
	set B_IE_VBLANK, [hl] 
	;; clear rIF before setting vblank
	xor a
	ldh [rIF], a
	;; set flag to 0
	ld [vram_flag], a
	reti

;; USAR SOLO SI LA UNICA INTERRUPCION
;; ACTIVADA ES VBLANK
vblank_interruption::
	halt		;; suspend until an interrupt happens
	ret

;; USAR SI HAY MAS DE UNA INTERRUPCION
vblank_with_interrupt::
	ld hl, vram_flag
	xor a
	.wait:
		halt		;; suspend until an interrupt happens
		xor a
		cp [hl]		;; check if the flag is zero
	jr z, .wait     ;; keep waiting
	ld [hl], a      ;; set back to zero for the next frame
	ret

SECTION "VRAM_FLAG", WRAM0
vram_flag: DS 1