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
`ifndef __uvm_reg_to_ipxact_top_tb
`define __uvm_reg_to_ipxact_top_tb

/**
 * Test module to show the usage of the uvm_reg_to_ipxact application
 */
module uvm_reg_to_ipxact_top;

   `include "uvm_macros.svh"
   import uvm_pkg::*;
   import uvm_reg_to_ipxact_pkg::*;

   // Include the file which contains all the classes
   // OR just import the package containing the register block you want to export to IP-XACT
   `include "demo_test_reg_block.sv"

   initial begin
      // instantiate the top level printer
      uvm_reg_to_ipxact_printer basic_printer;
      // Modify "basic_block" with the register block class you want to export to IP-XACT
      basic_block reg_block;

      // Modify here "basic_block" with the instance name you want for the reg block class and "basic_block" with the initial block class name
      reg_block = basic_block::type_id::create("basic_block");
      reg_block.configure(null, "tb_top.dut");
      reg_block.build();
      reg_block.lock_model();

      // Modify here "basic" into the create function with the instance name you want for the printer class
      basic_printer = uvm_reg_to_ipxact_printer::type_id::create("basic");

      // Modify here the value for the set_use_spirit function if you want to use the spirit standard (value 1) or the ipxact standard (value 0, default)
      basic_printer.set_use_spirit(0);

      // Modify here the parameters with the correct ones accordingly with the description present into the README.txt file
      basic_printer.set_parameters("ipxact.xml", "avendor", "alibrary", "1.4", "all_classes_file", 32, 32, 8);

      // call of the export to ipxact
      basic_printer.export_ipxact(reg_block);

   end

endmodule

`endif