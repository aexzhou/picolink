`ifndef PICOLINK_SCOREBOARD_SV
`define PICOLINK_SCOREBOARD_SV

`uvm_analysis_imp_decl(_a)
`uvm_analysis_imp_decl(_b)

// Very basic scoreboard: logs A requests, matches each with the first B
// response sharing the same {core_id, txn_id}. No protocol checking yet.
class picolink_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(picolink_scoreboard)

  uvm_analysis_imp_a #(picolink_txn, picolink_scoreboard) a_imp;
  uvm_analysis_imp_b #(picolink_txn, picolink_scoreboard) b_imp;

  // Pending requests keyed by {core_id, txn_id}
  protected picolink_txn pending [string];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    a_imp = new("a_imp", this);
    b_imp = new("b_imp", this);
  endfunction

  protected function string key(bit [`PICOLINK_ID_WIDTH-1:0] id,
                                bit [`PICOLINK_TXN_ID_WIDTH-1:0] tid);
    return $sformatf("c%0d_t%0d", id, tid);
  endfunction

  function void write_a(picolink_txn tx);
    string k = key(tx.endpoint_id, tx.txn_id);
    `uvm_info(get_type_name(), {"req:  ", tx.convert2string()}, UVM_MEDIUM)
    pending[k] = tx;
  endfunction

  function void write_b(picolink_txn tx);
    string k = key(tx.endpoint_id, tx.txn_id);
    `uvm_info(get_type_name(), {"resp: ", tx.convert2string()}, UVM_MEDIUM)
    if (pending.exists(k)) begin
      pending.delete(k);
    end else if (picolink_opcode_e'(tx.opcode) != Invalidate) begin
      `uvm_warning(get_type_name(),
                   $sformatf("B response with no matching A request: %s",
                             tx.convert2string()))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    if (pending.size() != 0)
      `uvm_warning(get_type_name(),
                   $sformatf("%0d request(s) had no response", pending.size()))
  endfunction

endclass

`endif // PICOLINK_SCOREBOARD_SV
