SECTION "Level 1 roads", ROM0

roads_level_1:
;;     LY ,  TY,  Vel,  Last SCX
DB     31 ,   4,    0,     0
DB     47 ,   6,    1,     0
DB     79 ,  10,    1,     0
DB     87 ,  11,    3,     0
;; out of the screen, no forman parte del nivel
DB    200,    0,    0,     0
DB    200,    0,    0,     0
.end

level_1_init::
	;; cargar tilemap
	ld hl, level1
    call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_1
	ld b, roads_level_1.end - roads_level_1
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret