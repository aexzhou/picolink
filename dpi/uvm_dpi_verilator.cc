// Verilator-compatible UVM DPI implementation.
// Unity-build file analogous to uvm_dpi.cc in the UVM source,
// but replaces the HDL backend with stubs (Verilator does not support
// VPI-based HDL backdoor access the way commercial simulators do).

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include "uvm_dpi.h"
#include "uvm_common.c"
#include "uvm_regex.cc"
#include "uvm_svcmd_dpi.c"

// HDL backdoor stubs — always return 0 (not found / failure).
int uvm_hdl_check_path(char *path) { return 0; }
int uvm_hdl_deposit(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_force(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_release_and_read(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_release(char *path) { return 0; }
int uvm_hdl_read(char *path, p_vpi_vecval value) { return 0; }

#ifdef __cplusplus
}
#endif
