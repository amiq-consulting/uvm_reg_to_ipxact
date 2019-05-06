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
`ifndef __uvm_reg_to_ipxact_printer_map
`define __uvm_reg_to_ipxact_printer_map

/**
 *  Prints details for a map present into the register block
 */
class uvm_reg_to_ipxact_printer_map extends uvm_reg_to_ipxact_printer_base;

	`uvm_object_utils(uvm_reg_to_ipxact_printer_map)

	// register printer class
	local uvm_reg_to_ipxact_printer_reg reg_printer;

	// constructor
	function new (string name = "uvm_reg_to_ipxact_printer_map");

		super.new(name);
		// create the register printer object
		reg_printer = uvm_reg_to_ipxact_printer_reg::type_id::create("reg_printer");
		// set the parent printer to be the register printer object
		reg_printer.set_parent_printer(this);

	endfunction

	/**
	 * Write details about a map
	 *
	 * @param aobj - the received object contains a map and a register block
	 */
	function string to_xml_string(uvm_object aobj[]);

		uvm_reg_map map;
		uvm_reg_block block;
		uvm_reg regs[$];
		string text[$];
		int text_q_size = 0;
		string result = "";
		
		UVM_REG_TO_IPXACT_PRINTER_MAP_CAST_ERR: assert(aobj.size() == 2 && aobj[0] != null && aobj[1] != null && $cast(map, aobj[0]) && $cast(block, aobj[1])) else
			`uvm_error("UVM_REG_TO_IPXACT_PRINTER_MAP_CAST_ERR", "The received item is empty!");
		text.push_front({"\n", indent(xml_element_tag("memoryMap", 1), 2)});
		text.push_front({"\n", indent(element2string("name", map.get_name(), 1), 3)});
		text.push_front({"\n", indent(xml_element_tag("addressBlock", 1), 3)});
		text.push_front({"\n", indent(element2string("name", block.get_name(), 1), 4)});
		text.push_front({"\n", indent(element2string("baseAddress", $sformatf("0x%16x", map.get_base_addr(UVM_HIER)), 1), 4)});
		// get the registers from the block
		block.get_registers(regs, UVM_HIER);
		text.push_front({"\n", indent(element2string("range", $sformatf("0x%16x", (regs[regs.size() - 1].get_address() + (regs[regs.size() - 1].get_n_bits() / 2)) - map.get_base_addr(UVM_HIER)), 1), 4)});
		text.push_front({"\n", indent(element2string("width", $sformatf("0x%2x", map.get_n_bytes()*8), 1), 4)});
		// for each register display its fields
		foreach (regs[i])
			text.push_front({"\n", reg_printer.to_xml_string({regs[i]})});
		text.push_front({"\n", indent(xml_element_tag("addressBlock", 0), 3)});
		text.push_front({"\n", indent(xml_element_tag("memoryMap", 0), 2)});
		// concatenate all the text
		text_q_size = text.size();
		foreach (text[i]) begin
			result = {result, text[text_q_size - i - 1]};
			text[text_q_size - i - 1] = "";
		end
		regs.delete();
		text.delete();

		return result;

	endfunction

endclass

`endif
