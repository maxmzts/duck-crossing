include "constants.inc"
include "macros.inc"

SECTION "Main Loop", ROM0[$150]

main::
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)


SECTION "OAM DMA", HRAM

OAMDMA::
DS rutinaDMA.fin - rutinaDMA