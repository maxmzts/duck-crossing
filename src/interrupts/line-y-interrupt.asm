include "constants.inc"
include "macros.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOCUMENTACION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interrupción de LY de STAT 
;;
;; Las interrupciones de STAT igual que la de
;; vblank, se activan en el IE, en el bit 1.
;; La diferencia es que después de eso, deben
;; activarse también haciendo set de los 
;; bits del rLCD_STAT el cual funciona como 
;; el IM pero solo para eventos de la pantalla.
;; 
;; La interrupción de línea horizontal (LY),
;; una vez activada, tiene en cuenta el valor
;; del registro rLYC (Line Y compare) y lo 
;; compara con el rLY, cada vez que se dibuja
;; una línea.
;; Si se da el caso de que son iguales se 
;; producirá la interrupción. En ese momento
;; se debe gestionar la cantidad de scroll 
;; necesario en ese conjunto de líneas y 
;; actualizar rLYC para la siguiente
;; interrupción.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Scroll horizontal
;; 
;; Para hacer scroll de nuestras carreteras
;; utilizamos un espacio de datos en la WRAM
;; que contiene la info de cada carretera de
;; un nivel:
;; 		- Linea de comienzo
;;		- Velocidad de scroll
;; 		- Dirección
;; Con esto y el STAT handler de la interrup.
;; de LYC podemos hacer el scroll. Para que 
;; el handler sepa cuál es la siguiente línea
;; que necesita scroll, hay otros dos bytes 
;; en WRAM que sirven de "apuntador" a la
;; dirección de memoria del siguiente scroll
;; en el espacio de datos. Esto no solo sirve
;; para gestionar ese scroll cuando llegue, 
;; sino para saber cuándo devolver el scroll a
;; 0. Si el siguiente LYC no coincide con la 
;; linea del siguiente scroll necesario es que
;; la carretera ha terminado y debe poner SCX
;; de nuevo a cero.
;; Cada frame es necesario reinciar el proceso
;; restaurando el valor del apuntador a la
;; primera carretera y LYC a la linea de scroll. 
;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; La dirección del handler de STAT es $0048
;; Le corresponden 2 bytes de handler por lo
;; que no vale la pena poner mucho código.
SECTION "STAT Handler", ROM0[$0048]
	jp stat_handler

SECTION "STAT Handler 2", ROM0

stat_handler:
	push af
	push hl
	push de

	;; get road from pointer
	ld hl, w_next_road_pointer
	ld a, [hl+]
	ld l, [hl]
	ld h, a

	.check_road:
	;; comprobar que hay carretera
	;; si el LY de la carretera apuntada
	;; NO es igual al LY actual, es que 
	;; ha terminado una carretera y se debe
	;; poner rSCX a cero
	ld a, [rLY]
	cp [hl]
	jr z, .update_road_scroll
	xor a
	ld [rSCX], a
	;; ademas se debe meter en rLYC la linea
	;; de la siguiente carretera
	ld a, [hl]
	ld [rLYC], a
	jr .end_handler

	.update_road_scroll
	;; gestionar scroll de la carretera
	ld a, [hl] ;; linea de carretera
	add 8
	ld [rLYC], a ;; parar en 8 lineas el scroll

	inc hl
	inc hl ;; saltar el dato TY

	;; obtener velocidad
	ld a, [hl+]  ;; vel
	ld d, [hl]   ;; last_scx
	;; comprobar si hay que mover scroll
	;; no se movera en ciertos frames para 
	;; coches lentos
	ld e, a
	ld a, [w_velocity_frame]
	and e
	jr nz, .skip_increase
	ld a, 1	
	add d
	jr .skip
	.skip_increase
	xor a
	add d
	.skip
	;; introducir nuevo scroll
	ld [rSCX], a
	ld [hl], a ;; actualizar siguiente frame

	.prepare_next_scroll
	inc hl ;; ya llegamos al siguiente road
	ld d, h
	ld e, l
	
	ld hl, w_next_road_pointer

	;; actualizar puntero
	ld [hl], d
	inc hl
	ld [hl], e

	.end_handler
	pop de
	pop hl
	pop af

	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "LYC interrupt", ROM0

enable_lyc_interrupt::
	ld hl, rIE
	set B_IE_STAT, [hl]
	;; set del "LYC select bit" del rSTAT
	ld hl, rLCD_STAT
	set 6, [hl]
	ret

disable_lyc_interrupt::
	ld hl, rIE
	res B_IE_STAT, [hl]
	;; reset del "LYC select bit" del rSTAT
	ld hl, rLCD_STAT
	res 6, [hl]
	;; Limpiar scroll horizontal por si acaso
	xor a
	ld [rSCX], a
	ret

;; esto se debe ejecutar al finalizar el 
;; dibujado de un frame para preparar el
;; scroll del siguiente
restart_roads_scroll_loop::
	;; restaurar puntero a la primera carretera
	ld hl, w_next_road_pointer
	ld de, w_current_level_roads 
	ld [hl], d
	inc hl
	ld [hl], e

	;; poner en rLYC la primera linea de la 
	;; primera carretera
	ld a, [de]
	ld [rLYC], a

	;; actualizar frame de velocidades
	;; si llega a 4 se reinicia
	ld hl, w_velocity_frame
	inc [hl]
	ld a, [hl]
	cp 4
	ret nz
	ld [hl], 0
	ret