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

`ifndef __ur2i_test_reg_block
`define __ur2i_test_reg_block

/**
 * Example of register map, register block and registers declarations
 */
class demo_addr_reg extends uvm_reg;

   rand uvm_reg_field addr;

   virtual function void build();
      addr = uvm_reg_field::type_id::create("addr");
      addr.configure(this, 3, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h01>>0, 1, 1, 1);
      add_hdl_path_slice("addr_reg", 0, 3);
      addr.set_reset(`UVM_REG_DATA_WIDTH'h0>>0, "SOFT");
      uvm_pkg::uvm_resource_db#(bit)::set({"REG::",get_full_name()}, "NORMAL", 1);
      wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
   endfunction

   covergroup wr_cg;
      option.per_instance=1;
      addr : coverpoint addr.value[2:0];
   endgroup

   protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
      super.sample(data, byte_en, is_read, map);
      if(!is_read) wr_cg.sample();
   endfunction

   `uvm_register_cb(demo_addr_reg, uvm_reg_cbs)
   `uvm_set_super_type(demo_addr_reg, uvm_reg)
   `uvm_object_utils(demo_addr_reg)
   function new(input string name="unnamed-demo_addr_reg");
      super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
      wr_cg=new;
   endfunction : new
endclass : demo_addr_reg

class demo_config_reg extends uvm_reg;

   typedef enum logic [1:0] {
      k0='h0, k1='h1, k2='h2, k3='h3
   } framek_enum;

   rand uvm_reg_field destination;
   rand uvm_reg_field frame_kind;
   rand uvm_reg_field rsvd0;

   constraint c1 { frame_kind.value inside {k1, k3}; }
   constraint frame_kind_enum {
      frame_kind.value inside { k0, k1, k2, k3 };
   }
   virtual function void build();
      destination = uvm_reg_field::type_id::create("destination");
      destination.configure(this, 2, 0, "RW", 0, `UVM_REG_DATA_WIDTH'hf0>>0, 1, 1, 1);
      add_hdl_path_slice("dest", 0, 2);
      destination.set_reset(`UVM_REG_DATA_WIDTH'h0>>0, "SOFT");
      frame_kind = uvm_reg_field::type_id::create("frame_kind");
      frame_kind.configure(this, 2, 2, "RW", 0, `UVM_REG_DATA_WIDTH'hf0>>2, 1, 1, 1);
      add_hdl_path_slice("kind", 2, 2);
      frame_kind.set_reset(`UVM_REG_DATA_WIDTH'h0>>2, "SOFT");
      rsvd0 = uvm_reg_field::type_id::create("rsvd0");
      rsvd0.configure(this, 4, 4, "RW", 0, `UVM_REG_DATA_WIDTH'hf0>>4, 1, 1, 1);
      add_hdl_path_slice("rsvd", 4, 4);
      uvm_pkg::uvm_resource_db#(bit)::set({"REG::",get_full_name()}, "NORMAL", 1);
      wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
      rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
   endfunction

   covergroup wr_cg;
      option.per_instance=1;
      destination : coverpoint destination.value[1:0];
      rsvd0 : coverpoint rsvd0.value[3:0];
   endgroup
   covergroup rd_cg;
      option.per_instance=1;
      rsvd0 : coverpoint rsvd0.value[3:0];
   endgroup

   protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
      super.sample(data, byte_en, is_read, map);
      if(!is_read) wr_cg.sample();
      if(is_read) rd_cg.sample();
   endfunction

   `uvm_register_cb(demo_config_reg, uvm_reg_cbs)
   `uvm_set_super_type(demo_config_reg, uvm_reg)
   `uvm_object_utils(demo_config_reg)
   function new(input string name="unnamed-demo_config_reg");
      super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
      wr_cg=new;
      rd_cg=new;
   endfunction : new
endclass : demo_config_reg

class demo_indirect_reg0_t extends uvm_reg;

   rand uvm_reg_field data;

   virtual function void build();
      data = uvm_reg_field::type_id::create("data");
      data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
      uvm_pkg::uvm_resource_db#(bit)::set({"REG::",get_full_name()}, "NORMAL", 1);
      wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
      rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
   endfunction

   covergroup wr_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup
   covergroup rd_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup

   protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
      super.sample(data, byte_en, is_read, map);
      if(!is_read) wr_cg.sample();
      if(is_read) rd_cg.sample();
   endfunction

   `uvm_register_cb(demo_indirect_reg0_t, uvm_reg_cbs)
   `uvm_set_super_type(demo_indirect_reg0_t, uvm_reg)
   `uvm_object_utils(demo_indirect_reg0_t)
   function new(input string name="unnamed-demo_indirect_reg0_t");
      super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
      wr_cg=new;
      rd_cg=new;
   endfunction : new
endclass : demo_indirect_reg0_t

class rw_regs_t extends uvm_reg;

   rand uvm_reg_field data;

   virtual function void build();
      data = uvm_reg_field::type_id::create("data");
      data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h5a>>0, 1, 1, 1);
      wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
      rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
   endfunction

   covergroup wr_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup
   covergroup rd_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup

   protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
      super.sample(data, byte_en, is_read, map);
      if(!is_read) wr_cg.sample();
      if(is_read) rd_cg.sample();
   endfunction

   `uvm_register_cb(rw_regs_t, uvm_reg_cbs)
   `uvm_set_super_type(rw_regs_t, uvm_reg)
   `uvm_object_utils(rw_regs_t)
   function new(input string name="unnamed-rw_regs_t");
      super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
      wr_cg=new;
      rd_cg=new;
   endfunction : new
endclass : rw_regs_t

class ro_regs_t extends uvm_reg;

   rand uvm_reg_field data;

   virtual function void build();
      data = uvm_reg_field::type_id::create("data");
      data.configure(this, 8, 0, "RO", 0, `UVM_REG_DATA_WIDTH'ha5>>0, 1, 1, 1);
      wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
      rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
   endfunction

   covergroup wr_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup
   covergroup rd_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup

   protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
      super.sample(data, byte_en, is_read, map);
      if(!is_read) wr_cg.sample();
      if(is_read) rd_cg.sample();
   endfunction

   `uvm_register_cb(ro_regs_t, uvm_reg_cbs)
   `uvm_set_super_type(ro_regs_t, uvm_reg)
   `uvm_object_utils(ro_regs_t)
   function new(input string name="unnamed-ro_regs_t");
      super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
      wr_cg=new;
      rd_cg=new;
   endfunction : new
endclass : ro_regs_t

class wo_regs_t extends uvm_reg;

   rand uvm_reg_field data;

   virtual function void build();
      data = uvm_reg_field::type_id::create("data");
      data.configure(this, 8, 0, "WO", 0, `UVM_REG_DATA_WIDTH'h55>>0, 1, 1, 1);
      wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
      rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
   endfunction

   covergroup wr_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup
   covergroup rd_cg;
      option.per_instance=1;
      data : coverpoint data.value[7:0];
   endgroup

   protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
      super.sample(data, byte_en, is_read, map);
      if(!is_read) wr_cg.sample();
      if(is_read) rd_cg.sample();
   endfunction

   `uvm_register_cb(wo_regs_t, uvm_reg_cbs)
   `uvm_set_super_type(wo_regs_t, uvm_reg)
   `uvm_object_utils(wo_regs_t)
   function new(input string name="unnamed-wo_regs_t");
      super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
      wr_cg=new;
      rd_cg=new;
   endfunction : new
endclass : wo_regs_t

class reg_block_class extends uvm_reg_block;

   `uvm_object_utils(reg_block_class)

   rand demo_addr_reg addr_reg;
   rand demo_config_reg config_reg;
   rand rw_regs_t rw_reg0;
   rand ro_regs_t ro_reg0;
   rand wo_regs_t wo_reg0;
   rand uvm_reg_map a_map;

   virtual function void build();

      // Now create all registers

      addr_reg = demo_addr_reg::type_id::create("addr_reg", , get_full_name());
      config_reg = demo_config_reg::type_id::create("config_reg", , get_full_name());
      rw_reg0 = rw_regs_t::type_id::create("rw_reg0", , get_full_name());
      ro_reg0 = ro_regs_t::type_id::create("ro_reg0", , get_full_name());
      wo_reg0 = wo_regs_t::type_id::create("wo_reg0", , get_full_name());

      // Now build the registers. Set parent and hdl_paths

      addr_reg.configure(this, null, "");
      addr_reg.build();
      config_reg.configure(this, null, "");
      config_reg.build();
      rw_reg0.configure(this, null, "rw_regs[0]");
      rw_reg0.build();
      ro_reg0.configure(this, null, "ro_regs[0]");
      ro_reg0.build();
      wo_reg0.configure(this, null, "wo_regs[0]");
      wo_reg0.build();
      // Now define address mappings
      a_map = create_map("a_map", 0, 1, UVM_LITTLE_ENDIAN);
      a_map.set_base_addr(`UVM_REG_ADDR_WIDTH'h1500);
      a_map.add_reg(addr_reg, `UVM_REG_ADDR_WIDTH'h00, "RW");
      a_map.add_reg(config_reg, `UVM_REG_ADDR_WIDTH'h04, "RW");
      default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);
      default_map.add_reg(rw_reg0, `UVM_REG_ADDR_WIDTH'h08, "RW");
      default_map.add_reg(ro_reg0, `UVM_REG_ADDR_WIDTH'h0C, "RO");
      default_map.add_reg(wo_reg0, `UVM_REG_ADDR_WIDTH'h10, "WO");

   endfunction

   function new(input string name="unnamed-reg_block_class");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

endclass

class basic_block extends uvm_reg_block;

   `uvm_object_utils(basic_block)

   rand reg_block_class reg_block, reg_block2;

   function void build();

      // Now define address mappings
      default_map = create_map("default_map1", 0, 1, UVM_LITTLE_ENDIAN);
      reg_block = reg_block_class::type_id::create("reg_block1", , get_full_name());
      reg_block.configure(this, "reg_file1");
      reg_block.build();
      default_map.add_submap(reg_block.default_map, `UVM_REG_ADDR_WIDTH'h2000);
      reg_block.lock_model();

      default_map = create_map("default_map2", 0, 1, UVM_LITTLE_ENDIAN);
      reg_block2 = reg_block_class::type_id::create("reg_block2", , get_full_name());
      reg_block2.configure(this, "reg_file2");
      reg_block2.build();
      default_map.add_submap(reg_block2.default_map, `UVM_REG_ADDR_WIDTH'h3000);
      reg_block2.lock_model();

   endfunction

   function new(input string name="basic_block");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

endclass

`endif