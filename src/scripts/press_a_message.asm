INCLUDE "constants.inc"
INCLUDE "macros.inc"

SECTION "Press A Message Variables", WRAM0
w_press_a_visible:: DS 1  ; 0 = oculto, 1 = visible

SECTION "Press A Message ROM", ROM0

;; Datos de los tiles de "Press A" desde el title screen
;; Fila 1: tiles $3D-$45 (9 tiles)
;; Fila 2: tiles $46-$4E (9 tiles)
press_a_row1:
    db $3D, $3E, $3F, $40, $41, $42, $43, $44, $45

press_a_row2:
    db $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E

;; Inicializa el sistema de mensaje
press_a_init::
    xor a
    ld [w_press_a_visible], a
    ret

;; Muestra el mensaje "Press A" arriba en el centro
;; Posición: fila 0-1, columnas 6-14 (arriba centrado)
press_a_show::
    ;; Verificar si ya está visible
    ld a, [w_press_a_visible]
    cp 1
    ret z  ; Ya está visible, no hacer nada
    
    
    ;; Calcular dirección base en VRAM
    ;; Fila 0 = $9800 + (0 * 32) = $9800
    ;; Columna 6 = offset de 6
    ld de, $9800 + 6  ; Primera fila del mensaje (arriba)
    
    ;; Copiar primera fila de "Press A"
    ld hl, press_a_row1
    ld b, 9  ; 9 tiles
.copy_row1:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy_row1
    
    ;; Calcular dirección de la segunda fila
    ;; Fila 1 = $9800 + (1 * 32) = $9820
    ld de, $9820 + 6  ; Segunda fila del mensaje
    
    ;; Copiar segunda fila de "Press A"
    ld hl, press_a_row2
    ld b, 9  ; 9 tiles
.copy_row2:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy_row2
    
    ;; Marcar como visible
    ld a, 1
    ld [w_press_a_visible], a
    ret

;; Oculta el mensaje "Press A" sin apagar el LCD
;; Esta función debe llamarse ANTES de lcd_off en el cambio de escena
press_a_hide::
    ;; Verificar si está visible
    ld a, [w_press_a_visible]
    cp 0
    ret z  ; Ya está oculto, no hacer nada
    
    ;; Marcar como oculto primero
    xor a
    ld [w_press_a_visible], a
    ret

;; llamar solo cuando LCD esté apagado
press_a_clear_vram::
    ;; Calcular dirección base en VRAM
    ld de, $9800 + 6  ; Primera fila del mensaje
    
    ;; Limpiar primera fila (9 tiles con $00 = tile vacío)
    ld a, $00
    ld b, 9
.clear_row1:
    ld [de], a
    inc de
    dec b
    jr nz, .clear_row1
    
    ;; Calcular dirección de la segunda fila
    ld de, $9820 + 6  ; Segunda fila del mensaje
    
    ;; Limpiar segunda fila
    ld a, $00
    ld b, 9
.clear_row2:
    ld [de], a
    inc de
    dec b
    jr nz, .clear_row2
    
    ret