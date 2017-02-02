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
`ifndef __uvm_reg_to_ipxact_printer
`define __uvm_reg_to_ipxact_printer

/**
 *  Main uvm_reg_to_ipxact application class
 */
class uvm_reg_to_ipxact_printer extends uvm_reg_to_ipxact_printer_base;

   `uvm_object_utils(uvm_reg_to_ipxact_printer)

   // register block to be exported
   local uvm_reg_block reg_block;
   // registers found in a register block
   local uvm_reg regs[$];
   // maps found in a register block
   local uvm_reg_map maps[$];
   // map printer class
   uvm_reg_to_ipxact_printer_map map_printer;
   // IP-XACT XML file name
   local string ipxact_file_name = "ipxact.xml";
   // class that contains all the classes (register map class, register memory class and all other registers classes)
   local string ipxact_name = "all_classes_file";
   // vendor name
   local string vendor = "avendor";
   // version number
   local string version = "1.4";
   // library name
   local string library_name = "alibrary";
   // UVM Reg Model DATA_BUS_WIDTH, eventually taken from `DATA_BUS_WIDTH
   local int data_bw = -1;
   // UVM Reg Model ADDRESS_BUS_WIDTH, eventually taken from `ADDRESS_BUS_WIDTH
   local int address_bw = -1;
   // Address bus granularity, to be used together with register bit width or data bus bit width
   // address_unit_bw =8 and register bit width == 32 => increment address by 4 from one reg to the next
   // address_unit_bw =16 and register bit width == 32 => increment address by 2 from one reg to the next
   // address_unit_bw =32 and register bit width == 32 => increment address by 1 from one reg to the next
   local int address_unit_bw = -1;

   // constructor
   function new (string name = "uvm_reg_to_ipxact_printer");
      super.new(name);
   endfunction

   /**
    * Set some of the XML parameters for the project
    *
    * @param file_name - the name of the XML file that will be created
    * @param avendor - vendor name
    * @param alibrary - library name
    * @param aversion - the standard version
    * @param aname - the name of the file that contains all the classes (register map class, register memory class and all other registers classes)
    * @param adbw - the width of the register data
    * @param aabw - the width of the address bus
    * @param aaubw - the width of the address unit bus
    */
   function void set_parameters( string file_name = "ipxact.xml", string avendor = "avendor", string alibrary = "alibrary", string aversion = "1.4", string aname = "all_classes_file", int adbw = 32, int aabw = 32, int aaubw = 8);

      ipxact_file_name = file_name;
      vendor = avendor;
      library_name = alibrary;
      ipxact_name = aname;
      version = aversion;
      data_bw = adbw;
      address_bw = aabw;
      address_unit_bw = aaubw;

      return;

   endfunction

   /**
    * Export the details from the register model to the IP-XACT XML file. This is the entry point of the uvm_reg_to_ipxact application
    *
    * @param reg_map - the register map class
    * @param reg_block_name - the name of the register block variable present in the reg_map class
    * @param class_name - the name of the file that contains all the classes (register map class, register memory class and all other registers classes)
    */
   function void export_ipxact (uvm_reg_block areg_blk = null);

      uvm_reg_to_ipxact_PRINTER_PARAMS_NOT_SET_ERR: assert (!(ipxact_file_name == "" || ipxact_name == "" || vendor == "" || version == "" || library_name == "" || data_bw == -1 || address_bw == -1 || address_unit_bw == -1))
      else
         `uvm_error("uvm_reg_to_ipxact_PRINTER_PARAMS_NOT_SET_ERR", "One or more of parameters{ipxact_file_name, ipxact_name, vendor, version, library, data_bw, address_bw, address_unit_bw} was not set. Please call the set_parameters function before calling the export_ipxact function!");
      uvm_reg_to_ipxact_PRINTER_REG_BLK_ERR: assert (areg_blk != null)
      else
         `uvm_error("uvm_reg_to_ipxact_PRINTER_REG_BLK_ERR", "The received register block is empty!");
      // save the received basic register block in this class register block global variable
      reg_block = areg_blk;
      // open the IP-XACT XML file
      open_file(ipxact_file_name);
      // write the details in the IP-XACT XML file
      write_ipxact();
      // close the IP-XACT XML file
      close_file();

      return;

   endfunction

   /**
    * Write in the IP-XACT XML file
    */
   function void write_ipxact();

      // counters
      int i = 0, j = 0;
      // store all the register model details in this string in order to write it to the IP-XACT XML file in the end
      string buffer = "";
      // for the basic register block obtain all its register blocks
      uvm_reg_block reg_blocks[$];
      // create the map printer object
      map_printer = uvm_reg_to_ipxact_printer_map::type_id::create("map_to_print");
      // set the parent printer to be the map printer object
      map_printer.set_parent_printer(this);
      // begin to store in string buffer
      buffer = {buffer, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"};
      buffer = {buffer, get_ipxact_header()};
      set_level(get_level() + 1);
      buffer = {buffer, indent(element2string("vendor", vendor, 1), 1), "\n"};
      buffer = {buffer, indent(element2string("library", library_name, 1), 1), "\n"};
      buffer = {buffer, indent(element2string("name", ipxact_name, 1), 1), "\n"};
      buffer = {buffer, indent(element2string("version", version, 1), 1), "\n"};
      buffer = {buffer, indent(xml_element_tag("memoryMaps", 1), 2), "\n"};
      // obtain all register blocks for the basic register block
      reg_block.get_blocks(reg_blocks, UVM_HIER);
      if (reg_blocks.size() > 0) begin
         foreach (reg_blocks[i]) begin
            // for each register block obtain all its maps
            reg_blocks[i].get_maps(maps);
            if (maps.size() > 0) begin
               // for each map store its details in the string buffer
               foreach (maps[j]) begin
                  if (i < reg_blocks.size() - 1)
                     buffer = {buffer, indent(map_printer.to_xml_string({maps[j], reg_blocks[i]}), 1), "\n"};
                  else
                     buffer = {buffer, indent(map_printer.to_xml_string({maps[j], reg_blocks[i]}), 1)};
               end
            end
            else
               `uvm_error("UVM_REG_TO_IPXACT_PRINTER", "No register maps are available! maps.size() is 0!")
            maps.delete();
         end
      end
      else
         `uvm_error("UVM_REG_TO_IPXACT_PRINTER", "No register blocks found! reg_blocks.size is 0.")
      buffer = {buffer, "\n", indent(xml_element_tag("memoryMaps", 0), 2), "\n"};
      set_level(0);
      buffer = {buffer, indent(xml_element_tag("component", 0), 0)};
      // write the string buffer in the IP-XACT XML file
      write2file(buffer);

      return;

   endfunction

   /**
    * Return a string containing only the XML header
    */
   function string get_ipxact_header();

      if (use_spirit) begin
         return "<spirit:component\n\
   xmlns:spirit=\"http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4\"\n\
   xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n\
   xsi:schemaLocation=\"XMLSchema/SPIRIT/VendorExtensions.xsd http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4 http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4/index.xsd\">\n";
      end else begin
         return "<ipxact:component\n\
   xmlns:spirit=\"http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4\"\n\
   xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n\
   xmlns:ipxact=\"http://www.accellera.org/XMLSchema/IPXACT/1685-2014\"\n\
   xsi:schemaLocation=\"http://www.accellera.org/XMLSchema/IPXACT/1685-2014/ http://www.accellera.org/XMLSchema/IPXACT/1685-2014/index.xsd\">\n";
      end

   endfunction

endclass

`endif