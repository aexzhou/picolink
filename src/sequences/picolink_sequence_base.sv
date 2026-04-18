`ifndef PICOLINK_SEQUENCE_BASE_SV
`define PICOLINK_SEQUENCE_BASE_SV

class picolink_sequence_base extends uvm_sequence #(picolink_txn);

  `uvm_object_utils(picolink_sequence_base)

  function new(string name = "picolink_sequence_base");
    super.new(name);
  endfunction

  // Convenience: send a GrantE (clean line, exclusive) response.
  task send_grant_e(bit [`PICOLINK_ID_WIDTH-1:0]     core_id,
                    bit [`PICOLINK_TXN_ID_WIDTH-1:0] tid,
                    bit [`PICOLINK_ADDR_WIDTH-1:0]   a,
                    bit [`PICOLINK_DATA_WIDTH-1:0]   d);
    picolink_txn tx;
    tx = picolink_txn::type_id::create("grant_e");
    start_item(tx);
    if (!tx.randomize() with {
      channel     == PICOLINK_CHAN_B;
      opcode      == PICOLINK_B_GRANT_E;
      endpoint_id == core_id;
      txn_id      == tid;
      addr        == a;
      data        == d;
    }) `uvm_fatal(get_type_name(), "GrantE randomize failed")
    finish_item(tx);
  endtask

endclass

`endif // PICOLINK_SEQUENCE_BASE_SV
