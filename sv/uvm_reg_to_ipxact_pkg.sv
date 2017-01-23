/******************************************************************************
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * PROJECT:     UVM/SystemVerilog Register Model to IP-XACT
 *
 * (C) Copyright 2017 AMIQ Consulting
 *******************************************************************************/
`ifndef __uvm_reg_to_ipxact_pkg
`define __uvm_reg_to_ipxact_pkg

/**
 * This package contains all required classes to export an UVM register model to IP-XACT
 * You can read more about IP-XACT {@link http://accellera.org/downloads/standards/ip-xact here}
 */
package uvm_reg_to_ipxact_pkg;

   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // ur2i base printer
   `include "uvm_reg_to_ipxact_printer_base.svh"
   // uvm_reg_field printer
   `include "uvm_reg_to_ipxact_printer_field.svh"
   // uvm_reg printer
   `include "uvm_reg_to_ipxact_printer_reg.svh"
   // uvm_reg_map printer
   `include "uvm_reg_to_ipxact_printer_map.svh"
   // ur2i application
   `include "uvm_reg_to_ipxact_printer.svh"

endpackage

`endif