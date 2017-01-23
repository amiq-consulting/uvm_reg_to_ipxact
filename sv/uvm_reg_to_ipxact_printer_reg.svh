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

      UVM_REG_TO_IPXACT_PRINTER_REG_CAST_ERR: assert(aobj.size() > 0  && aobj[0] != null && $cast(register, aobj[0])) else
         `uvm_error("UVM_REG_TO_IPXACT_PRINTER_REG_CAST_ERR", "Illegal parameters received!");
      to_xml_string = indent(xml_element_tag("register", 1), 5);
      to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(element2string("name", register.get_name(), 1), 6));
      to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(element2string("addressOffset", $sformatf("0x%16x", register.get_offset()), 1), 6));
      to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(element2string("size", $sformatf("%2x", register.get_n_bits()), 1), 6));
      if (register.has_reset()) begin
         to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(xml_element_tag("reset", 1), 6));
         to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(element2string("value", $sformatf("0x%16x", register.get_reset()), 1), 7));
         format_mask={"0x",{(register.get_n_bits()/4){"f"}}};
         to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(element2string("mask", format_mask, 1), 7));
         to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(xml_element_tag("reset", 0), 6));
      end
      // get the fields for this register
      register.get_fields(fields);
      if (fields.size() > 0)
         foreach (fields[i])
            to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(m_field_printer.to_xml_string({fields[i]}), 6));
      to_xml_string = $sformatf("%s\n%s", to_xml_string, indent(xml_element_tag("register", 0), 5));

      return to_xml_string;

   endfunction

endclass

`endif