.global gfx_fb


.align 4
gfx_fb:
  .int 1024    @ +0x00: Physical width
  .int 768    @ +0x04: Physical height
  .int 1024    @ +0x08: Virtual width
  .int 768    @ +0x0C: Virtual height
  .int 0      @ +0x10: Pitch
  .int 32     @ +0x14: Bit depth
  .int 0      @ +0x18: X
  .int 0      @ +0x1C: Y
  .int 0      @ +0x20: Address
  .int 0      @ +0x24: Size
.align 2