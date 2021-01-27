.segment "CODE"
; ----------------------------------------------------------------------------
; SEE IF CONTROL-C TYPED
; ----------------------------------------------------------------------------
.ifndef CONFIG_CBM_ALL
.include "platforms\cbm\cbm_iscntc.s"
.endif
.ifdef KBD
.include "platforms\kbd\kbd_iscntc.s"
.endif
.ifdef OSI
.include "platforms\osi\osi_iscntc.s"
.endif
.ifdef APPLE
.include "platforms\apple\apple_iscntc.s"
.endif
.ifdef KIM
.include "platforms\kim\kim_iscntc.s"
.endif
.ifdef MICROTAN
.include "platforms\microtan\microtan_iscntc.s"
.endif
.ifdef POTPOURRI6502
.include "platforms\potpourri6502\potpourri6502_iscntc.s"
.endif
;!!! runs into "STOP"