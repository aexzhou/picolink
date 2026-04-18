`ifndef PICOLINK_ENV_SV
`define PICOLINK_ENV_SV

class picolink_env extends uvm_env;

  `uvm_component_utils(picolink_env)

  picolink_l2_agent            l2_agent;
  picolink_scoreboard          sb;
  picolink_virtual_sequencer   v_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    l2_agent = picolink_l2_agent::type_id::create("l2_agent", this);
    sb       = picolink_scoreboard::type_id::create("sb", this);
    v_seqr   = picolink_virtual_sequencer::type_id::create("v_seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    l2_agent.a_ap.connect(sb.a_imp);
    l2_agent.b_ap.connect(sb.b_imp);
    v_seqr.l2_seqr = l2_agent.sequencer;
  endfunction

endclass

`endif // PICOLINK_ENV_SV
