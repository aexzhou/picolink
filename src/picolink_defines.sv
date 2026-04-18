`ifndef PICOLINK_DEFINES_SV
`define PICOLINK_DEFINES_SV

// ---------------------------------------------------------------------------
// PicoLink protocol parameters
// See docs/message_fields.rst for field sizing notes.
// ---------------------------------------------------------------------------

`ifndef PICOLINK_ADDR_WIDTH
  `define PICOLINK_ADDR_WIDTH 42
`endif

`ifndef PICOLINK_DATA_WIDTH
  `define PICOLINK_DATA_WIDTH 512
`endif

`ifndef PICOLINK_ID_WIDTH
  `define PICOLINK_ID_WIDTH 4
`endif

`ifndef PICOLINK_TXN_ID_WIDTH
  `define PICOLINK_TXN_ID_WIDTH 4
`endif

`endif // PICOLINK_DEFINES_SV
