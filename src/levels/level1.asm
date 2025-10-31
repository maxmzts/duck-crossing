include "constants.inc"

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
	;; Inicializar jugador (tiles y posición)
	call init_player

	ld a, SONG_MAIN
    call music_play_id
	
	;; cargar tilemap
	ld hl, level1
	call load_32x32_tilemap
	
	;; Inicializar nivel en el level manager
	ld hl, roads_level_1
	ld de, level1
	ld b, roads_level_1.end - roads_level_1
	call level_man_init
	
	;; Solo queremos el interrupt de LCD activo
	;; cuando la escena activa es un nivel
	call enable_lyc_interrupt
	ret

level_1_check_victory::
	ld a, [w_scene_change_pending]
	cp 1
	ret z
	
	ld a, [w_victory_flag]
	cp 1
	ret nz
	
	;; Reiniciar el flag de victoria INMEDIATAMENTE
	;; antes de cualquier otra cosa para evitar doble detección
	xor a
	ld [w_victory_flag], a
	
	;; Reiniciar el puntero de colisión a un valor seguro
	;; para evitar que se detecte de nuevo en el mismo frame
	ld a, $98
	ld [tile_colliding_pointer], a
	xor a
	ld [tile_colliding_pointer+1], a
	ld [tile_ID_colliding], a
	
	call level_man_clear

	;; cambiar a nivel 2
	ld a, SCENE_LEVEL_2
	call scene_manager_change_scene 
	
	ret