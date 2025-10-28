INCLUDE "constants.inc"
INCLUDE "macros.inc"

SECTION "Press A Message Variables", WRAM0
w_press_a_visible:: DS 1  ; 0 = oculto, 1 = visible
w_press_a_backup_row1:: DS 32  ; Backup de la fila 0 completa
w_press_a_backup_row2:: DS 32  ; Backup de la fila 1 completa

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
    
    ;; Hacer backup de las dos primeras filas antes de modificarlas
    call .backup_rows
    
    ;; Copiar primera fila de "Press A"
    ld hl, press_a_row1
    ld de, $9800 + 6  ; Primera fila del mensaje (arriba)
    ld bc, 9  ; 9 tiles
    
.wait_vblank1:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank1
    
    call .copy_row
    
    ;; Copiar segunda fila de "Press A"
    ld hl, press_a_row2
    ld de, $9820 + 6  ; Segunda fila del mensaje
    ld bc, 9  ; 9 tiles
    
.wait_vblank2:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank2
    
    call .copy_row
    
    ;; Marcar como visible
    ld a, 1
    ld [w_press_a_visible], a
    ret

.copy_row:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copy_row
    ret

.backup_rows:
    ;; Backup fila 0
    ld hl, $9800
    ld de, w_press_a_backup_row1
    ld bc, 32
    call .copy_backup
    
    ;; Backup fila 1
    ld hl, $9820
    ld de, w_press_a_backup_row2
    ld bc, 32
    
.copy_backup:
.wait_vblank_backup:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank_backup
    
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copy_backup
    ret

;; Oculta el mensaje "Press A" y restaura las filas originales
press_a_hide::
    ;; Verificar si está visible
    ld a, [w_press_a_visible]
    cp 0
    ret z  ; Ya está oculto, no hacer nada
    
    ;; Restaurar fila 0 desde el backup
    ld hl, w_press_a_backup_row1
    ld de, $9800
    ld bc, 32
    
.wait_vblank1:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank1
    
    call .restore_row
    
    ;; Restaurar fila 1 desde el backup
    ld hl, w_press_a_backup_row2
    ld de, $9820
    ld bc, 32
    
.wait_vblank2:
    ld a, [rLY]
    cp 144
    jr c, .wait_vblank2
    
    call .restore_row
    
    ;; Marcar como oculto
    xor a
    ld [w_press_a_visible], a
    ret

.restore_row:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .restore_row
    ret

;; llamar solo cuando LCD esté apagado
press_a_clear_vram::
    ;; Limpiar primera fila
    ld de, $9800 + 6  ; Primera fila del mensaje 
    ld a, $00
    ld b, 9
.clear_row1:
    ld [de], a
    inc de
    dec b
    jr nz, .clear_row1
    
    ;; Limpiar segunda fila
    ld de, $9820 + 6  ; Segunda fila del mensaje
    ld a, $00
    ld b, 9
.clear_row2:
    ld [de], a
    inc de
    dec b
    jr nz, .clear_row2
    
    ret