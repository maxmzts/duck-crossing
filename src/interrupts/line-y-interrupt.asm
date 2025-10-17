DEF rLYC 		equ $FF45
DEF rLCD_STAT 	equ $FF41
DEF rSCY 		equ $FF42
DEF rSCX 		equ $FF43


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOCUMENTACION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interrupción de STAT 
;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SECTION "STAT Handler", ROM0[$0048]

SECTION "STAT Handler 2", ROM0

SECTION "LYC interrupt", ROM0

enable_lyc_interrupt::
	;; set del "LYC select bit" del rSTAT
	bit 6, [rLCD_STAT]
	
	ret