`ifndef PICOLINK_L2_SLAVE_IF_SV
`define PICOLINK_L2_SLAVE_IF_SV

`include "picolink_defines.sv"

// Two-channel PicoLink interface. Valid/ready handshake per channel.
// Channel A: Core -> CM (requests, writebacks, invacks)
// Channel B: CM -> Core (grants, invalidates, acks, nacks)
interface picolink_l2_slave_if #(
  parameter int ADDR_W  = `PICOLINK_ADDR_WIDTH,
  parameter int DATA_W  = `PICOLINK_DATA_WIDTH,
  parameter int ID_W    = `PICOLINK_ID_WIDTH,
  parameter int TXN_W   = `PICOLINK_TXN_ID_WIDTH
) (
  input logic clk,
  input logic rst_n
);

  // A channel (Core -> CM)
  logic             a_valid;
  logic             a_ready;
  logic [3:0]       a_opcode;
  logic [ID_W-1:0]  a_src_id;
  logic [TXN_W-1:0] a_txn_id;
  logic [ADDR_W-1:0] a_addr;
  logic [DATA_W-1:0] a_data;

  // B channel (CM -> Core)
  logic             b_valid;
  logic             b_ready;
  logic [3:0]       b_opcode;
  logic [ID_W-1:0]  b_dst_id;
  logic [TXN_W-1:0] b_txn_id;
  logic [ADDR_W-1:0] b_addr;
  logic [DATA_W-1:0] b_data;

endinterface

`endif // PICOLINK_L2_SLAVE_IF_SV
