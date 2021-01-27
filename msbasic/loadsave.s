.segment "CODE"

.ifdef APPLE
.include "platforms\apple\apple_loadsave.s"
.endif
.ifdef KIM
.include "platforms\kim\kim_loadsave.s"
.endif
.ifdef MICROTAN
.include "platforms\microtan\microtan_loadsave.s"
.endif
.ifdef POTPOURRI6502
.include "platforms\potpourri6502\potpourri6502_loadsave.s"
.endif


