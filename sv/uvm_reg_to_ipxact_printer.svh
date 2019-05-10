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
	 * @param indent - use indentation for the XML file: 1 use (default value) and 0 do not use
	 */
	function void set_parameters (string file_name = "ipxact.xml", string avendor = "avendor", string alibrary = "alibrary", string aversion = "1.4", string aname = "all_classes_file", bit indent = 1);

		ipxact_file_name = file_name;
		vendor = avendor;
		library_name = alibrary;
		ipxact_name = aname;
		version = aversion;
		set_en_indent(indent);

		return;

	endfunction

	/**
	 * Export the details from the register model to the IP-XACT XML file. This is the entry point of the uvm_reg_to_ipxact application
	 *
	 * @param areg_blk - the main register block
	 */
	function void export_ipxact (uvm_reg_block areg_blk = null);

	        // store all the register model details in this string in order to write it to the IP-XACT XML file in the end
		string buffer = "";

                uvm_reg_to_ipxact_PRINTER_PARAMS_NOT_SET_ERR: assert (!(ipxact_file_name == "" || ipxact_name == "" || vendor == "" || version == "" || library_name == ""))
		else
			`uvm_error("uvm_reg_to_ipxact_PRINTER_PARAMS_NOT_SET_ERR", "One or more of parameters{ipxact_file_name, ipxact_name, vendor, version, library} was not set. Please call the set_parameters function before calling the export_ipxact function!");
		uvm_reg_to_ipxact_PRINTER_REG_BLK_ERR: assert (areg_blk != null)
		else
			`uvm_error("uvm_reg_to_ipxact_PRINTER_REG_BLK_ERR", "The received register block is empty!");
		// open the IP-XACT XML file
		open_file(ipxact_file_name);
		// get the register block details in the IP-XACT XML format
		buffer = to_xml_string({areg_blk});
                // write the string buffer in the IP-XACT XML file
                write2file(buffer);
                // close the IP-XACT XML file
		close_file();

		return;

	endfunction

        /**
	 * Write details about all the filed present in the received register block
	 *
	 * @param aobj - an array of objects which will be used to extract xml elements
	 * @return string - an XML string with elements extracted from the object
	 */	
        function string to_xml_string(uvm_object aobj[]);

		// counters
		int i = 0, j = 0;
		// store all the register model details in this string in order to write it to the IP-XACT XML file in the end
		string result= "";
                // register block to be exported
	        uvm_reg_block reg_block;
                // for the basic register block obtain all its register blocks
                uvm_reg_block reg_blocks[$];

                UVM_REG_TO_IPXACT_PRINTER_REG_BLOCK_CAST_ERR: assert(aobj.size() > 0  && aobj[0] != null && $cast(reg_block, aobj[0])) else
			`uvm_error("UVM_REG_TO_IPXACT_PRINTER_REG_BLOCK_CAST_ERR", "Illegal parameters received!");
		// create the map printer object
		map_printer = uvm_reg_to_ipxact_printer_map::type_id::create("map_to_print");
		// set the parent printer to be the map printer object
		map_printer.set_parent_printer(this);
		// begin to store in string result
		result = {result, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"};
		result = {result, get_ipxact_header()};
		set_level(get_level() + 1);
		result = {result, indent(element2string("vendor", vendor, 1), 1), "\n"};
		result = {result, indent(element2string("library", library_name, 1), 1), "\n"};
		result = {result, indent(element2string("name", ipxact_name, 1), 1), "\n"};
		result = {result, indent(element2string("version", version, 1), 1), "\n"};
		result = {result, indent(xml_element_tag("memoryMaps", 1), 1)};
		// obtain all register blocks for the basic register block
		reg_block.get_blocks(reg_blocks, UVM_HIER);
		if (reg_blocks.size() > 0) begin
			foreach (reg_blocks[i]) begin
				// for each register block obtain all its maps
				reg_blocks[i].get_maps(maps);
				if (maps.size() > 0) begin
					// for each map store its details in the string result
					foreach (maps[j]) begin
						result = {result, map_printer.to_xml_string({maps[j], reg_blocks[i]})};
						result = {result, get_all_submaps(maps[j], reg_blocks[i])};
					end
				end
				else
					`uvm_error("UVM_REG_TO_IPXACT_PRINTER", "No register maps are available! maps.size() is 0!")
			end
		end
		else
			`uvm_error("UVM_REG_TO_IPXACT_PRINTER", "No register blocks found! reg_blocks.size is 0.")
		result = {result, "\n", indent(xml_element_tag("memoryMaps", 0), 1), "\n"};
		set_level(0);
		result = {result, indent(xml_element_tag("component", 0), 0)};

		return result;

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
   xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n\
   xmlns:ipxact=\"http://www.accellera.org/XMLSchema/IPXACT/1685-2014\"\n\
   xsi:schemaLocation=\"http://www.accellera.org/XMLSchema/IPXACT/1685-2014/ http://www.accellera.org/XMLSchema/IPXACT/1685-2014/index.xsd\">\n";
		end

	endfunction

	function string get_all_submaps(uvm_reg_map map, uvm_reg_block block);

		uvm_reg_map submaps[$], aux;
		string a = "";

		map.get_submaps(submaps, UVM_HIER);
		if (submaps.size() == 0) begin
			return get_all_submaps;
		end
		else
			foreach (submaps[i])
			begin
				aux = submaps[i].get_parent_map();
				get_all_submaps = {get_all_submaps, "\n", indent($sformatf("<!-- %s is a submap of the map %s -->", submaps[i].get_name(), aux.get_name()),2)};
				get_all_submaps = {get_all_submaps, indent(map_printer.to_xml_string({submaps[i], block}), 1)};
				// find all the submaps for the map received recursively
				a = get_all_submaps(submaps[i], block);
				submaps[i] = null;
			end
		submaps.delete();

		return get_all_submaps;

	endfunction

endclass

`endif
