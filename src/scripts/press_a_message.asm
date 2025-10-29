INCLUDE "constants.inc"
INCLUDE "macros.inc"

SECTION "Press A Message Variables", WRAM0
w_press_a_visible:: DS 1  ; 0 = oculto, 1 = visible

SECTION "Press A Message ROM", ROM0

;; Datos de los tiles de "Press A" desde el title screen
;; Una sola fila: tiles $55-$59 (5 tiles)
press_a_row1:
    db $55, $56, $57, $58, $59

;; Tiles que había originalmente en esas posiciones (del nivel)
;; Estos tiles son los del cielo/fondo del nivel (usualmente tile $00 o $01)
press_a_clear_row:
    db $00, $00, $00, $00, $00

;; Inicializa el sistema de mensaje
press_a_init::
    xor a
    ld [w_press_a_visible], a
    ret

;; Muestra el mensaje "Press A" arriba en el centro
;; Posición: fila 0, columnas 6-10 (arriba centrado)
press_a_show::
    ;; Verificar si ya está visible
    ld a, [w_press_a_visible]
    cp 1
    ret z  ; Ya está visible, no hacer nada
    
    ;; Esperar VBlank antes de escribir en VRAM
.wait_vblank1:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank1
    
    ;; Copiar fila de "Press A"
    ld hl, press_a_row1
    ld de, $9800 + 6  ; Primera fila del mensaje (arriba)
    ld b, 5  ; 5 tiles
    call .copy_row
    
    ;; Marcar como visible
    ld a, 1
    ld [w_press_a_visible], a
    ret

.copy_row:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy_row
    ret

;; Oculta el mensaje "Press A" poniendo tiles vacíos
press_a_hide::
    ;; Verificar si está visible
    ld a, [w_press_a_visible]
    cp 0
    ret z  ; Ya está oculto, no hacer nada
    
    ;; Esperar VBlank antes de limpiar
.wait_vblank1:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank1
    
    ;; Limpiar fila con tiles vacíos
    ld hl, press_a_clear_row
    ld de, $9800 + 6  ; Primera fila del mensaje
    ld b, 5
    call .copy_row
    
    ;; Marcar como oculto
    xor a
    ld [w_press_a_visible], a
    ret

.copy_row:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy_row
    ret

;; llamar solo cuando LCD esté apagado
press_a_clear_vram::
    ;; Limpiar fila
    ld de, $9800 + 6  ; Primera fila del mensaje 
    ld a, $00
    ld b, 5
.clear_row1:
    ld [de], a
    inc de
    dec b
    jr nz, .clear_row1
    
    ret