`ifndef PICOLINK_L2_SLAVE_MONITOR_SV
`define PICOLINK_L2_SLAVE_MONITOR_SV

// Samples both channels on valid/ready handshakes and publishes
// observed transactions on separate analysis ports.
class picolink_l2_slave_monitor extends uvm_monitor;

  `uvm_component_utils(picolink_l2_slave_monitor)

  virtual picolink_l2_slave_if vif;

  uvm_analysis_port #(picolink_txn) a_ap;
  uvm_analysis_port #(picolink_txn) b_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    a_ap = new("a_ap", this);
    b_ap = new("b_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual picolink_l2_slave_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Missing virtual interface 'vif' in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.rst_n);
    fork
      sample_a_channel();
      sample_b_channel();
    join
  endtask

  task sample_a_channel();
    picolink_txn tx;
    forever begin
      @(posedge vif.clk);
      if (vif.a_valid === 1'b1 && vif.a_ready === 1'b1) begin
        tx = picolink_txn::type_id::create("a_tx");
        tx.channel     = PICOLINK_CHAN_A;
        tx.opcode      = vif.a_opcode;
        tx.endpoint_id = vif.a_src_id;
        tx.txn_id      = vif.a_txn_id;
        tx.addr        = vif.a_addr;
        tx.data        = vif.a_data;
        tx.has_data    = (tx.opcode == PICOLINK_A_WRITEBACK);
        `uvm_info(get_type_name(), {"A: ", tx.convert2string()}, UVM_HIGH)
        a_ap.write(tx);
      end
    end
  endtask

  task sample_b_channel();
    picolink_txn tx;
    forever begin
      @(posedge vif.clk);
      if (vif.b_valid === 1'b1 && vif.b_ready === 1'b1) begin
        tx = picolink_txn::type_id::create("b_tx");
        tx.channel     = PICOLINK_CHAN_B;
        tx.opcode      = vif.b_opcode;
        tx.endpoint_id = vif.b_dst_id;
        tx.txn_id      = vif.b_txn_id;
        tx.addr        = vif.b_addr;
        tx.data        = vif.b_data;
        tx.has_data    = (tx.opcode == PICOLINK_B_GRANT_S ||
                          tx.opcode == PICOLINK_B_GRANT_E);
        `uvm_info(get_type_name(), {"B: ", tx.convert2string()}, UVM_HIGH)
        b_ap.write(tx);
      end
    end
  endtask

endclass

`endif // PICOLINK_L2_SLAVE_MONITOR_SV
