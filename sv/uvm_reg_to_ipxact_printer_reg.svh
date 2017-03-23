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
`ifndef __uvm_reg_to_ipxact_printer_reg
`define __uvm_reg_to_ipxact_printer_reg

/**
 *  Prints XML of a register
 */
class uvm_reg_to_ipxact_printer_reg extends uvm_reg_to_ipxact_printer_base;

	`uvm_object_utils(uvm_reg_to_ipxact_printer_reg)

	// field printer class
	local uvm_reg_to_ipxact_printer_field m_field_printer;

	// constructor
	function new (string name = "uvm_reg_to_ipxact_printer_reg");

		super.new(name);
		// create the field printer object
		m_field_printer = uvm_reg_to_ipxact_printer_field::type_id::create("field_printer");
		// set the parent printer to be the register printer
		m_field_printer.set_parent_printer(this);

	endfunction

	/**
	 * Write details about all the filed present in the received register
	 *
	 * @param aobj - an array of objects which will be used to extract xml elements
	 * @return string - an XML string with elements extracted from the object
	 */
	function string to_xml_string(uvm_object aobj[]);

		// the reset mask format
		string format_mask;
		uvm_reg register;
		uvm_reg_field fields[$];
		string text[$];
		int text_q_size = 0;

		UVM_REG_TO_IPXACT_PRINTER_REG_CAST_ERR: assert(aobj.size() > 0  && aobj[0] != null && $cast(register, aobj[0])) else
			`uvm_error("UVM_REG_TO_IPXACT_PRINTER_REG_CAST_ERR", "Illegal parameters received!");
		text.push_front(indent(xml_element_tag("register", 1), 4));
		text.push_front({"\n", indent(element2string("name", register.get_name(), 1), 5)});
		text.push_front({"\n", indent(element2string("addressOffset", $sformatf("0x%16x", register.get_offset()), 1), 5)});
		text.push_front({"\n", indent(element2string("size", $sformatf("%2x", register.get_n_bits()), 1), 5)});
		if (register.has_reset()) begin
			text.push_front({"\n", indent(xml_element_tag("reset", 1), 5)});
			text.push_front({"\n", indent(element2string("value", $sformatf("0x%16x", register.get_reset()), 1), 6)});
			format_mask={"0x",{(register.get_n_bits()/4){"f"}}};
			text.push_front({"\n", indent(element2string("mask", format_mask, 1), 6)});
			text.push_front({"\n", indent(xml_element_tag("reset", 0), 5)});
		end
		// get the fields for this register
		register.get_fields(fields);
		if (fields.size() > 0)
			foreach (fields[i])
				text.push_front({"\n", indent(m_field_printer.to_xml_string({fields[i]}), 5)});
		text.push_front({"\n", indent(xml_element_tag("register", 0), 4)});
		// concatenate all the text=
		text_q_size = text.size();
		foreach (text[i]) begin
			to_xml_string = {to_xml_string, text[text_q_size - i - 1]};
			text[text_q_size - i - 1] = "";
		end
		fields.delete();
		text.delete();

		return to_xml_string;

	endfunction

endclass

`endif