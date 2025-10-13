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
;; HALT RACE CONDITION BUG:
;;
;; Este es un error que se produce cuando un
;; reti vuelve a un halt. Según pandocs cuando
;; ei se ejecuta (o reti), tiene un delay de
;; una instruccion. Por tanto el halt vuelve
;; a ejecutarse.
;;
;; Una solución es hacer pop del stack para
;; sacar el ret del wait_vblank. Esto solo 
;; pasará con esta iterrupcion por lo que si
;; otra desactiva el halt, se comprueba el 
;; flag y al ser 0 (no haber pasado por el
;; handler de Vblank) se vuelve a hacer halt.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "VBLANK Handler", ROM0[$0040]

vblank_interrupt_handler::
	;; set flag to non-zero
	push af
	ld a, 1
	ld [vblank_flag], a
	jr vblank_handler_continue

;; cambiar direccion de rom si 
;; usamos la interrupcion STAT
SECTION "VBLANK Handler 2", ROM0[$0048]
vblank_handler_continue::
	pop af
	pop af ;; delete the ret from wait_vbklank
	reti

SECTION FRAGMENT "Utils", ROM0

enable_vblank_interrupt::
	ld hl, rIE
	set B_IE_VBLANK, [hl] 
	;; clear rIF before setting vblank
	xor a
	ldh [rIF], a
	;; set flag to 0
	ld [vblank_flag], a
	reti

;; USAR SOLO SI LA UNICA INTERRUPCION
;; ACTIVADA ES VBLANK
vblank_interruption::
	halt		;; suspend until an interrupt happens
	ret

;; USAR SI HAY MAS DE UNA INTERRUPCION
vblank_with_interrupt::
	.wait:
		halt		;; suspend until an interrupt happens
		ld a, [vblank_flag]
		and a		;; check if the flag is zero
	jr z, .wait     ;; keep waiting
	xor a
	ld [hl], a      ;; set back to zero for the next frame
	ret

SECTION "VBLANK_FLAG", WRAM0
vblank_flag: DS 1