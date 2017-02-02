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
`ifndef __uvm_reg_to_ipxact_printer_base
`define __uvm_reg_to_ipxact_printer_base

/**
 *  Base printer class from which all the other classes inherit.
 */
class uvm_reg_to_ipxact_printer_base extends uvm_object;

   `uvm_object_utils(uvm_reg_to_ipxact_printer_base)
   
   // use the spirit standard or the ipxact standard
   static bit use_spirit = 0;
   
   // base printer class
   local uvm_reg_to_ipxact_printer_base p_printer;
   
   // IP-XACT XML file id
   local int m_fd = 0;
   
   // text level in the IP-XACT XML file
   local int m_level = 0;
   
   // text left indent space in the IP-XACT XML file
   local string m_indent_space = "";
   
   // enables XML indentation. by default is on
   local bit m_en_indent = 1;
   
   // constructor
   function new (string name = "uvm_reg_to_ipxact_printer_base");
      super.new(name);
   endfunction

   /**
    * Sets the parent printer and initializes the file descriptor and indentation level relative to parent
    *
    * @param p_printer - the object that prints the data
    */
   function void set_parent_printer(uvm_reg_to_ipxact_printer_base p_printer);

      this.p_printer = p_printer;
      this.set_en_indent(p_printer.get_en_indent());
      if (p_printer != null) begin
         this.set_fd(p_printer.get_fd());
         this.set_level(p_printer.get_level()+1);
      end

   endfunction

   /**
    * Open the XML file for write
    *
    * @param file_name - the name of the XML file
    */
   function void open_file(string file_name = "ipxact.xml");

      m_fd = $fopen(file_name, "w");
      UVM_REG_TO_IPXACT_FILE_OPEN_ERROR: assert (m_fd)
      else `uvm_fatal("UVM_REG_TO_IPXACT_FILE_OPEN_ERROR", "Fail to create the IP-XACT file!")

   endfunction

   /**
    * Close the XML file
    */
   function void close_file();

      $fflush(m_fd);
      $fclose(m_fd);

   endfunction

   /**
    * Set the file id
    * @param an_fd - sets the file descriptor
    */
   function void set_fd(int an_fd = 0);
      m_fd = an_fd;
   endfunction

   /**
    * Get the file id of the XML file
    * @return m_fd - returns the file descriptor
    */
   function int get_fd();
      return m_fd;
   endfunction

   /**
    * Write a string in the XML file
    *
    * @param text - the text to be written in XML file
    */
   function void write2file(string text = "");
      $fdisplay(m_fd, $sformatf("%s%s", m_indent_space, text));
   endfunction

   /**
    * Creates a string which contains the tag and its details and returns it
    *
    * @param elem_name - tag name
    * @param content - tag content
    * @param on_same_line - the text will be printed on the same line
    * @return - the tag
    */
   function string element2string(string elem_name = "", string content = "", bit on_same_line = 0);

      if (on_same_line)
         return $sformatf("<%s:%s>%s</%s:%s>", use_spirit ? "spirit" : "ipxact", elem_name, content, use_spirit ? "spirit" : "ipxact", elem_name);

      return $sformatf("<%s:%s>\n%s\n%s</%s:%s>", use_spirit ? "spirit" : "ipxact", elem_name, content, indent("", get_level()), use_spirit? "spirit" : "ipxact", elem_name);

   endfunction

   /**
    * Creates a string that contains only the tag
    *
    * @param elem_name - taq name
    * @param sne - the tag is an opening one (value 1) or a closing one (value 0)
    * @return tag - returns the tag
    */
   function string xml_element_tag(string elem_name = "", bit sne = 0);
      return {sne ? "<" : "</", use_spirit ? "spirit:" : "ipxact:", elem_name, ">"};
   endfunction

   /**
    * Set the text indentation level in the XML file
    *
    * @param a_level - the text level in the XML file
    */
   function void set_level(int a_level = 0);

      m_level = a_level;
      m_indent_space = {(m_level*3){" "}};

   endfunction

   /**
    * Get the text indentation level in the XML file
    * @return m_level
    */
   function int get_level();
      return m_level;
   endfunction
   
   /* Get m_en_indent
    * @return - enable indent flag
    */
   function bit get_en_indent();
      return m_en_indent;
   endfunction

   /* Set m_en_indent
    * @param m_en_indent - sets the enable indent flag
    */
   function void set_en_indent(bit m_en_indent);
      this.m_en_indent = m_en_indent;
   endfunction


   /**
    * Indent to the right the text by a specified level
    *
    * @param text - the text
    * @param level - the indentation level
    * @return string - the indented string
    */
   function string indent(string text = "", int level = 0);
      if (m_en_indent)
         return $sformatf("%s%s", {(level){m_indent_space}}, text);
      else 
         return text;
   endfunction

   /**
    * Set if SPIRIT or IP-XACT standard will be used
    *
    * @param en_spirit - use the spirit standard (value 1) or the ipxact standrad (value 0)
    */
   static function void set_use_spirit(bit en_spirit = 0);
      use_spirit = en_spirit;
   endfunction

   /**
    * Creates a string that contains all details about a received object
    *
    * @param aobj - an array of objects which will be used to extract xml elements
    * @return string - an XML string with elements extracted from the object
    */
   virtual function string to_xml_string(uvm_object aobj[]);
   endfunction

endclass

`endif