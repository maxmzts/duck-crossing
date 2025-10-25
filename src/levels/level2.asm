include "constants.inc"

SECTION "Level 2 roads", ROM0

roads_level_2:
;;     LY,   TY,  Vel,  Last SCX
DB     55,    7,    0,     0
DB     63,    8,    1,     0
DB     79,   10,    1,     0
DB     87,   11,    3,     0
DB    111,   14,    3,     0
DB    119,   15,    3,     0
.end:

level_2_init::
	;; cargar tilemap
	ld hl, level2
    call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_2
	ld b, roads_level_2.end - roads_level_2
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_2_check_victory::

	ld a, [w_victory_flag]
	cp 1
	ret nz
	;; cambiar a nivel 2
	ld a, SCENE_TITLE
	call scene_manager_change_scene 
	
	ret