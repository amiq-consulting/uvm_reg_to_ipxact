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
`ifndef __uvm_reg_to_ipxact_printer_field
`define __uvm_reg_to_ipxact_printer_field

/**
 *  Prints XML of a field
 */
class uvm_reg_to_ipxact_printer_field extends uvm_reg_to_ipxact_printer_base;

	`uvm_object_utils(uvm_reg_to_ipxact_printer_field)

	// constructor
	function new (string name = "uvm_reg_to_ipxact_printer_field");
		super.new(name);
	endfunction

	/**
	 * Write details about the received filed
	 *
	 * @param aobj - an array of objects which will be used to extract xml elements
	 * @return string - an XML string with elements extracted from the object
	 */
	virtual function string to_xml_string(uvm_object aobj[]);

		uvm_reg_field field;
		// variable used as auxiliary
		int nr = 0;
		// field access type
		string access = "", text[$];
		int text_q_size = 0;
		string result = "";
		
		UVM_REG_TO_IPXACT_PRINTER_FIELD_CAST_ERR: assert(aobj.size() > 0  && aobj[0] != null && $cast(field, aobj[0])) else
			`uvm_error("UVM_REG_TO_IPXACT_PRINTER_FIELD_CAST_ERR", "Received item is empty!");
		text.push_front(indent(xml_element_tag("field", 1), 0));
		text.push_front({"\n", indent(element2string("name", field.get_name(), 1), 7)});
		nr = field.get_lsb_pos();
		if (nr < 10)
			text.push_front({"\n", indent(element2string("bitOffset", $sformatf("%1d", nr), 1), 7)});
		else
			text.push_front({"\n", indent(element2string("bitOffset", $sformatf("%2d", nr), 1), 7)});
		nr = field.get_n_bits();
		if (nr < 10)
			text.push_front({"\n", indent(element2string("bitWidth", $sformatf("%1d", nr), 1), 7)});
		else
			text.push_front({"\n", indent(element2string("bitWidth", $sformatf("%2d", nr), 1), 7)});
		access = field.get_access();
		case (access)
			"RW"    : access = "read-write";
			"WO"    : access = "write-only";
			"RO"    : access = "read-only";
			"RC"    : access = "read-clears-all";
			"RS"    : access = "read-sets-all";
			default : access = "no-access";
		endcase
		text.push_front({"\n", indent(element2string("access", $sformatf("%s", access), 1), 7)});
		access = "";
		text.push_front({"\n", indent(xml_element_tag("field", 0), 5)});
		text_q_size = text.size();
		foreach (text[i]) begin
			result = {result, text[text_q_size - i - 1]};
			text[text_q_size - i - 1] = "";
		end
		text.delete();

		return result;

	endfunction

endclass

`endif
