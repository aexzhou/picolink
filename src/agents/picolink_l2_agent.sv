`ifndef PICOLINK_L2_AGENT_SV
`define PICOLINK_L2_AGENT_SV

typedef uvm_sequencer #(picolink_txn) picolink_sequencer;

class picolink_l2_agent extends uvm_agent;

  `uvm_component_utils(picolink_l2_agent)

  picolink_sequencer           sequencer;
  picolink_l2_slave_driver     driver;
  picolink_l2_slave_monitor    monitor;

  uvm_analysis_port #(picolink_txn) a_ap;
  uvm_analysis_port #(picolink_txn) b_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    a_ap = new("a_ap", this);
    b_ap = new("b_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = picolink_l2_slave_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sequencer = picolink_sequencer::type_id::create("sequencer", this);
      driver    = picolink_l2_slave_driver::type_id::create("driver", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    monitor.a_ap.connect(a_ap);
    monitor.b_ap.connect(b_ap);
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass

`endif // PICOLINK_L2_AGENT_SV
