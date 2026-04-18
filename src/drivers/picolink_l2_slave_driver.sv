`ifndef PICOLINK_L2_SLAVE_DRIVER_SV
`define PICOLINK_L2_SLAVE_DRIVER_SV

// Slave-side driver: accepts A-channel requests from the DUT (core) and drives
// B-channel responses supplied by the sequencer.
class picolink_l2_slave_driver extends uvm_driver #(picolink_txn);

  `uvm_component_utils(picolink_l2_slave_driver)

  virtual picolink_l2_slave_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual picolink_l2_slave_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Missing virtual interface 'vif' in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    reset_signals();
    @(posedge vif.rst_n);
    fork
      drive_b_channel();
      accept_a_channel();
    join
  endtask

  task reset_signals();
    vif.a_ready = 1'b0;
    vif.b_valid = 1'b0;
    vif.b_opcode = '0;
    vif.b_dst_id = '0;
    vif.b_txn_id = '0;
    vif.b_addr   = '0;
    vif.b_data   = '0;
  endtask

  // Pull sequence items (B-channel responses) and drive onto the interface.
  task drive_b_channel();
    picolink_txn tx;
    forever begin
      seq_item_port.get_next_item(tx);
      if (tx.channel != PICOLINK_CHAN_B) begin
        `uvm_error(get_type_name(),
                   $sformatf("Driver received non-B transaction: %s",
                             tx.convert2string()))
      end else begin
        drive_b_beat(tx);
      end
      seq_item_port.item_done();
    end
  endtask

  task drive_b_beat(picolink_txn tx);
    @(posedge vif.clk);
    vif.b_valid  <= 1'b1;
    vif.b_opcode <= tx.opcode;
    vif.b_dst_id <= tx.endpoint_id;
    vif.b_txn_id <= tx.txn_id;
    vif.b_addr   <= tx.addr;
    vif.b_data   <= tx.has_data ? tx.data : '0;
    do @(posedge vif.clk); while (!vif.b_ready);
    vif.b_valid  <= 1'b0;
  endtask

  // Basic A-channel sink: always accept requests.
  task accept_a_channel();
    @(posedge vif.clk);
    vif.a_ready <= 1'b1;
  endtask

endclass

`endif // PICOLINK_L2_SLAVE_DRIVER_SV
