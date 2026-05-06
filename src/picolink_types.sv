`ifndef __PICOLINK_TYPES__
`define __PICOLINK_TYPES__


typedef enum logic {
  Ch_A = 1'b0,
  Ch_B = 1'b1
} picolink_ch_t;

typedef enum logic [3:0] {
  ReadShared    = 4'd0,
  ReadExclusive = 4'd1,
  Upgrade       = 4'd2,
  WriteBack     = 4'd3,
  InvAck        = 4'd4,
  GrantS        = 4'd5,
  GrantE        = 4'd6,
  GrantM        = 4'd7,
  Invalidate    = 4'd8,
  WriteBackAck  = 4'd9,
  Nack          = 4'd10
} picolink_opcode_e;



`endif
