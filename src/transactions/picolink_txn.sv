`ifndef PICOLINK_TXN_SV
`define PICOLINK_TXN_SV

typedef enum bit {
  PICOLINK_CHAN_A = 1'b0, // Core -> CM
  PICOLINK_CHAN_B = 1'b1  // CM -> Core
} picolink_chan_e;

// A-channel opcodes (Core -> CM)
typedef enum bit [3:0] {
  PICOLINK_A_READ_SHARED    = 4'h0,
  PICOLINK_A_READ_EXCLUSIVE = 4'h1,
  PICOLINK_A_UPGRADE        = 4'h2,
  PICOLINK_A_WRITEBACK      = 4'h3,
  PICOLINK_A_INVACK         = 4'h4
} picolink_a_opcode_e;

// B-channel opcodes (CM -> Core)
typedef enum bit [3:0] {
  PICOLINK_B_GRANT_S      = 4'h0,
  PICOLINK_B_GRANT_E      = 4'h1,
  PICOLINK_B_GRANT_M      = 4'h2,
  PICOLINK_B_INVALIDATE   = 4'h3,
  PICOLINK_B_WRITEBACKACK = 4'h4,
  PICOLINK_B_NACK         = 4'h5
} picolink_b_opcode_e;

class picolink_txn extends uvm_sequence_item;

  rand picolink_chan_e                     channel;
  rand bit                 [3:0]           opcode;
  rand bit [`PICOLINK_ID_WIDTH-1:0]        endpoint_id; // src_id on A, dst_id on B
  rand bit [`PICOLINK_TXN_ID_WIDTH-1:0]    txn_id;
  rand bit [`PICOLINK_ADDR_WIDTH-1:0]      addr;
  rand bit [`PICOLINK_DATA_WIDTH-1:0]      data;
  rand bit                                 has_data;

  constraint c_has_data {
    if (channel == PICOLINK_CHAN_A) {
      has_data == (opcode == PICOLINK_A_WRITEBACK);
    } else {
      has_data == (opcode == PICOLINK_B_GRANT_S ||
                   opcode == PICOLINK_B_GRANT_E);
    }
  }

  `uvm_object_utils_begin(picolink_txn)
    `uvm_field_enum(picolink_chan_e, channel, UVM_ALL_ON)
    `uvm_field_int (opcode,      UVM_ALL_ON)
    `uvm_field_int (endpoint_id, UVM_ALL_ON)
    `uvm_field_int (txn_id,      UVM_ALL_ON)
    `uvm_field_int (addr,        UVM_ALL_ON)
    `uvm_field_int (data,        UVM_ALL_ON)
    `uvm_field_int (has_data,    UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "picolink_txn");
    super.new(name);
  endfunction

  function string convert2string();
    string s;
    picolink_a_opcode_e a_op;
    picolink_b_opcode_e b_op;
    if (channel == PICOLINK_CHAN_A) begin
      a_op = picolink_a_opcode_e'(opcode);
      s = $sformatf("A[%s] src=%0d txn=%0d addr=0x%0h",
                    a_op.name(), endpoint_id, txn_id, addr);
    end else begin
      b_op = picolink_b_opcode_e'(opcode);
      s = $sformatf("B[%s] dst=%0d txn=%0d addr=0x%0h",
                    b_op.name(), endpoint_id, txn_id, addr);
    end
    if (has_data) s = {s, $sformatf(" data=0x%0h", data)};
    return s;
  endfunction

endclass

`endif // PICOLINK_TXN_SV
