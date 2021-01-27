.segment "EXTRA"

.ifdef KIM
.include "platforms\kim\kim_extra.s"
.endif

.ifdef CONFIG_CBM1_PATCHES
.include "platforms\cbm\cbm1_patches.s"
.endif

.ifdef KBD
.include "platforms\kbd\kbd_extra.s"
.endif

.ifdef APPLE
.include "platforms\apple\apple_extra.s"
.endif

.ifdef MICROTAN
.include "platforms\microtan\microtan_extra.s"
.endif

.ifdef POTPOURRI6502
.include "platforms\potpourri6502\potpourri6502_extra.s"
.endif
