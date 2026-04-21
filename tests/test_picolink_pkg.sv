// Basic unit test for picolink_pkg using uvm_unit.
//
// Exercises the L2 slave UVC end-to-end at the signal level:
//   * Drive A-channel stimulus directly on the interface (playing the core)
//     and check that the monitor publishes a matching transaction.
//   * Push a B-channel transaction through the sequencer/driver and check
//     that it appears on the interface wires.

// Instantiate the clock, reset, and interface inside uvm_unit's run module.
`define UNIT_TEST_RUN_MODULE_BODY                                      \
    picolink_l2_slave_if picolink_vif();                               \
    initial begin                                                      \
        picolink_vif.clk = 0;                                          \
        forever #5 picolink_vif.clk = ~picolink_vif.clk;              \
    end

`include "uvm_unit.svh"
`include "picolink_defines.sv"
`include "picolink_l2_slave_if.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"
import picolink_pkg::*;


// -----------------------------------------------------------------------------
// Sequence that sends one GrantE response.
// -----------------------------------------------------------------------------
class grant_e_seq extends picolink_sequence_base;
  `uvm_object_utils(grant_e_seq)

  bit [`PICOLINK_ID_WIDTH-1:0]     core_id = 0;
  bit [`PICOLINK_TXN_ID_WIDTH-1:0] tid     = 0;
  bit [`PICOLINK_ADDR_WIDTH-1:0]   a       = 0;
  bit [`PICOLINK_DATA_WIDTH-1:0]   d       = 0;

  function new(string name = "grant_e_seq");
    super.new(name);
  endfunction

  virtual task body();
    send_grant_e(core_id, tid, a, d);
  endtask
endclass


// -----------------------------------------------------------------------------
// Fixture: brings up an active l2 agent driving a real interface.
// -----------------------------------------------------------------------------
class picolink_fixture extends uvm_unit_pkg::uvm_unit_fixture;
  `uvm_component_utils(picolink_fixture)

  picolink_l2_agent    agent;
  virtual picolink_l2_slave_if vif;

  // Analysis FIFOs snoop the monitor so tests can pop observed txns.
  uvm_tlm_analysis_fifo #(picolink_txn) a_fifo;
  uvm_tlm_analysis_fifo #(picolink_txn) b_fifo;

  function new(string name = "picolink_fixture", uvm_component parent = null);
    super.new(name, parent);
    a_fifo = new("a_fifo", this);
    b_fifo = new("b_fifo", this);
    vif = unit_test_run_module.picolink_vif;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(virtual picolink_l2_slave_if)::set(
        this, "*", "vif", unit_test_run_module.picolink_vif);
    agent = picolink_l2_agent::type_id::create("agent", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.a_ap.connect(a_fifo.analysis_export);
    agent.b_ap.connect(b_fifo.analysis_export);
  endfunction

  // Helper: release reset.
  virtual task release_reset();
    vif.rst_n = 1'b0;
    repeat (2) @(posedge vif.clk);
    vif.rst_n = 1'b1;
    @(posedge vif.clk);
  endtask

  // Helper: drive one A-channel beat directly onto the interface.
  virtual task drive_a_beat(bit [3:0]                       op,
                            bit [`PICOLINK_ID_WIDTH-1:0]    src,
                            bit [`PICOLINK_TXN_ID_WIDTH-1:0] tid,
                            bit [`PICOLINK_ADDR_WIDTH-1:0]  addr);
    @(posedge vif.clk);
    vif.a_valid  <= 1'b1;
    vif.a_opcode <= op;
    vif.a_src_id <= src;
    vif.a_txn_id <= tid;
    vif.a_addr   <= addr;
    vif.a_data   <= '0;
    do @(posedge vif.clk); while (!vif.a_ready);
    vif.a_valid  <= 1'b0;
  endtask

  // Helper: always-ready on B (simulate a core that accepts responses).
  virtual task accept_b_always();
    vif.b_ready <= 1'b1;
  endtask
endclass


// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
`RUN_PHASE_TEST_F(picolink_fixture, fixture_builds_cleanly)
  `ASSERT_NOT_NULL(agent)
  `ASSERT_NOT_NULL(agent.sequencer)
  `ASSERT_NOT_NULL(agent.driver)
  `ASSERT_NOT_NULL(agent.monitor)
  `ASSERT_STR_EQ(agent.get_type_name(), "picolink_l2_agent")
`END_RUN_PHASE_TEST


`RUN_PHASE_TEST_F(picolink_fixture, monitor_captures_read_shared_on_a_channel)
  picolink_txn obs;
  release_reset();
  accept_b_always();

  drive_a_beat(.op(PICOLINK_A_READ_SHARED),
               .src(4'h3),
               .tid(4'h7),
               .addr('hDEAD));

  // Give the monitor one cycle to publish.
  @(posedge vif.clk);

  `ASSERT_TRUE(a_fifo.try_get(obs))
  `ASSERT_NOT_NULL(obs)
  `ASSERT_EQ(obs.channel,     PICOLINK_CHAN_A)
  `ASSERT_EQ(obs.opcode,      PICOLINK_A_READ_SHARED)
  `ASSERT_EQ(obs.endpoint_id, 4'h3)
  `ASSERT_EQ(obs.txn_id,      4'h7)
  `ASSERT_EQ(obs.addr,        'hDEAD)
  `ASSERT_FALSE(obs.has_data)
`END_RUN_PHASE_TEST


`RUN_PHASE_TEST_F(picolink_fixture, driver_sends_grant_e_on_b_channel)
  grant_e_seq   seq;
  picolink_txn  obs;
  release_reset();
  accept_b_always();

  seq = grant_e_seq::type_id::create("seq");
  seq.core_id = 4'h2;
  seq.tid     = 4'h5;
  seq.a       = 'hBEEF;
  seq.d       = 'hCAFE;
  seq.start(agent.sequencer);

  // Let the driver + monitor see the beat.
  repeat (2) @(posedge vif.clk);

  `ASSERT_TRUE(b_fifo.try_get(obs))
  `ASSERT_NOT_NULL(obs)
  `ASSERT_EQ(obs.channel,     PICOLINK_CHAN_B)
  `ASSERT_EQ(obs.opcode,      PICOLINK_B_GRANT_E)
  `ASSERT_EQ(obs.endpoint_id, 4'h2)
  `ASSERT_EQ(obs.txn_id,      4'h5)
  `ASSERT_EQ(obs.addr,        'hBEEF)
  `ASSERT_EQ(obs.data,        'hCAFE)
  `ASSERT_TRUE(obs.has_data)
`END_RUN_PHASE_TEST
