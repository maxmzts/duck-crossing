include "constants.inc"
include "macros.inc"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOCUMENTACION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Info de niveles
;;
;; El videojuego necesita cierta información 
;; para gestionar los niveles jugables. El
;; problema es que hay que plantear un sistema
;; que tome la información del nivel cargado.
;; Para eso también se necesita una estructura
;; de datos para cada nivel.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ESTRUCTURA DE INFO DE NIVELES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aparte del tilemap, el cual contiene bastante
;; información relevante, cada nivel necesita
;; la información de dónde están sus carreteras
;; para asistir al código de scroll y colisiones.
;; Planteamos una lista de carreteras, cada una
;; tiene 4 bytes de info: 
;;    1.La linea en Y en la que empieza.
;;    2.La posicion de tile en Y que ocupa
;;    3.Su velocidad (mas info adelante)
;;	  4.El último dato de scroll aplicado.
;; Ćada nivel tendrá una lista así y la copiará
;; a un espacio de la WRAM para usar esa info
;; cada frame.
;;
;; --------------------------------------------
;; Velocidades
;;
;; Las velocidades funcionan con una operacion
;; logica que limita el número de frames que 
;; se mueven los coches. Esta operación se 
;; realiza sobre un contador que está en WRAM
;;
;; Rapido: 			1 		px/frame
;; 					%00000000 todos los frames
;; Normal:			0.5   px/frame (1 cada 2)
;;					%00000001 frames pares
;; Lento:			0.25	px/frame (1 cada 4)
;; 					%00000011 multiplo de 4
;; --------------------------------------------
;; Ejemplo 
;;
	SECTION "Example", ROM0
	roads_level_example:
	;;     LY ,  TY,  Vel,  Last SCX
	DB     31 ,   4,    0,     0
	DB     47 ,   6,    1,     0
	DB     79 ,  10,    1,     0
	DB     87 ,  11,    3,     0
	.end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "Level Manager Data", WRAM0

w_level_man_variables:
;; puntero para iterar sobre las carreteras
w_next_road_pointer:: DS 2

;; este espacio para el array de roads deberá
;; tener el tamaño del array más grande, es decir
;; utilizar el tamaño del nivel con más carreteras
;w_current_level_roads:: DS roads_level_1.end - roads_level_1
w_current_level_roads:: DS 24 ; he puesto 16 porque es el tamaño del array del primer nivel

;; un dato que indica la cantidad de carreteras 
;; que tiene el array sin necesidad de recorrerlo
w_current_level_roads_count:: DS 1

;; contador de 0 a 4 utilizado para gestionar
;; la velocidad de los coches
w_velocity_frame:: DS 1

;; flag que marca la victoria del nivel
;; 0 = jugando   ,  1 = victoria

w_victory_flag:: DS 1
w_level_man_variables_end:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "Level Manager Code", ROM0

;; INPUT:  HL (level roads array), B (roads array length)
level_man_init::
	;; inicializar puntero
	ld a, h
	ld [w_next_road_pointer], a
	ld a, l
	ld [w_next_road_pointer+1], a

	;; poner en rLYC la primera linea de la 
	;; primera carretera
	ld a, [hl]
	ld [rLYC], a

	;; poner cantidad de carreteras
	;; la longitud del array entre 4 
	ld a, b
	srl a ; /2
	srl a ; /4
	ld [w_current_level_roads_count], a

	;; inicializar info de carreteras
	ld de, w_current_level_roads
	.mempcy:
		ld a, [hl+]
		ld [de], a
		inc de 
		dec b
	jr nz, .mempcy

	xor a
	ld [w_victory_flag], a
	ret

level_man_clear::
    MEMSET w_level_man_variables, 0,  w_level_man_variables_end - w_level_man_variables 
    ret

level_man_set_victory::
	ld a, 1
	ld [w_victory_flag], a
	ret

;; OUTPUT:  A (victory flag)
level_man_get_victory::
	ld a, [w_victory_flag]
	ret