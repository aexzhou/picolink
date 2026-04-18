`ifndef PICOLINK_VIRTUAL_SEQUENCER_SV
`define PICOLINK_VIRTUAL_SEQUENCER_SV

class picolink_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(picolink_virtual_sequencer)

  picolink_sequencer l2_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif // PICOLINK_VIRTUAL_SEQUENCER_SV
