
SECTION "Musica Data", ROM0

;;Nota, duracion(frames)
;;Cada nota tiene la siguiente estructura: DB LOW(Nota), Duracion en frames, HIGH(Nota)
;;LOW para la parte baja de la frecuencia que va a NR13
;;HIGH para la parte alta que va a NR14
;;MUS END para acabar la cancion y regresar el player al inicio

;;TEMA PRINCIPAL: Más animado que el resto de las canciones.
music_song0:
    DB LOW(FREQ_A4),    10, HIGH(FREQ_A4)
    DB LOW(FREQ_C5),    8,  HIGH(FREQ_C5)
    DB LOW(FREQ_D5),    8,  HIGH(FREQ_D5)
    DB LOW(FREQ_E5),    10, HIGH(FREQ_E5)

    DB LOW(FREQ_D5),    8,  HIGH(FREQ_D5)
    DB LOW(FREQ_C5),    12, HIGH(FREQ_C5)
    DB LOW(FREQ_B4),    8,  HIGH(FREQ_B4)
    DB LOW(FREQ_A4),    14, HIGH(FREQ_A4)

    DB LOW(FREQ_G4),    10, HIGH(FREQ_G4)
    DB LOW(FREQ_B4),    8,  HIGH(FREQ_B4)
    DB LOW(FREQ_C5),    10, HIGH(FREQ_C5)
    DB LOW(FREQ_D5),    8,  HIGH(FREQ_D5)

    DB LOW(FREQ_E5),    10, HIGH(FREQ_E5)
    DB LOW(FREQ_C5),    8,  HIGH(FREQ_C5)
    DB LOW(FREQ_B4),    12, HIGH(FREQ_B4)
    DB LOW(FREQ_A4),    14, HIGH(FREQ_A4)

    DB MUS_END

;;Tema del menú: Más tranquila que el resto.
music_menu:
    DB LOW(FREQ_A4),    12, HIGH(FREQ_A4)
    DB LOW(FREQ_C5),    10, HIGH(FREQ_C5)
    DB LOW(FREQ_E5),    10, HIGH(FREQ_E5)
    DB LOW(FREQ_C5),    12, HIGH(FREQ_C5)

    DB LOW(FREQ_G4),    12, HIGH(FREQ_G4)
    DB LOW(FREQ_B4),    10, HIGH(FREQ_B4)
    DB LOW(FREQ_C5),    12, HIGH(FREQ_C5)
    DB LOW(FREQ_A4),    14, HIGH(FREQ_A4)

    DB LOW(FREQ_B4),    8,  HIGH(FREQ_B4)
    DB LOW(FREQ_C5),    10, HIGH(FREQ_C5)
    DB LOW(FREQ_D5),    10, HIGH(FREQ_D5)
    DB LOW(FREQ_C5),    12, HIGH(FREQ_C5)

    DB LOW(FREQ_A4),    14, HIGH(FREQ_A4)
    
    DB MUS_END

;;Tema de muerte: Con un tono más lento u oscuro
music_death:
    DB LOW(FREQ_A4),    6,  HIGH(FREQ_A4)
    DB LOW(FREQ_E4),    5,  HIGH(FREQ_E4)
    DB LOW(FREQ_F4),    5,  HIGH(FREQ_F4)
    DB LOW(FREQ_E4),    6,  HIGH(FREQ_E4)

    DB LOW(FREQ_Gs4),   4,  HIGH(FREQ_Gs4)
    DB LOW(FREQ_A4),    8,  HIGH(FREQ_A4)
    DB LOW(FREQ_C5),    6,  HIGH(FREQ_C5)
    DB LOW(FREQ_B4),    6,  HIGH(FREQ_B4)

    DB LOW(FREQ_A4),    6,  HIGH(FREQ_A4)
    DB LOW(FREQ_G4),    6,  HIGH(FREQ_G4)
    DB LOW(FREQ_F4),    6,  HIGH(FREQ_F4)
    DB LOW(FREQ_E4),    8,  HIGH(FREQ_E4)

    DB LOW(FREQ_D4),    8,  HIGH(FREQ_D4)
    DB LOW(FREQ_F4),    6,  HIGH(FREQ_F4)
    DB LOW(FREQ_E4),    6,  HIGH(FREQ_E4)
    DB LOW(FREQ_C4),    10, HIGH(FREQ_C4)

    DB MUS_END

;;Tema de victoria: Siguiendo el clásico tu tu ru taaaaa.
music_victory:
    DB LOW(FREQ_C5),    4,  HIGH(FREQ_C5)
    DB LOW(FREQ_C5),    4,  HIGH(FREQ_C5)
    DB LOW(FREQ_E5),    6,  HIGH(FREQ_E5)
    DB LOW(FREQ_G5),    6,  HIGH(FREQ_G5)
    DB LOW(FREQ_A5),    18, HIGH(FREQ_A5)
    DB MUS_END

;;Tabla de canciones
;;Usado como unos IDs, puesto tambien en constants.inc para hacer las llamadas
SONG_TABLE::
    DW music_song0
    DW music_menu
    DW music_death
    DW music_victory