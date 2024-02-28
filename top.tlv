\m5_TLV_version 1d --inlineGen --noDirectiveComments --noline --clkAlways --bestsv: tl-x.org
\m5
   use(m5-1.0)
   

   // #################################################################
   // #                                                               #
   // #  Starting-Point Code for MEST Course Tiny Tapeout Calculator  #
   // #                                                               #
   // #################################################################
   
   // ========
   // Settings
   // ========
   
   //-------------------------------------------------------
   // Build Target Configuration
   //
   // To build within Makerchip for the FPGA or ASIC:
   //   o Use first line of file: \m5_TLV_version 1d --inlineGen --noDirectiveComments --noline --clkAlways --bestsv --debugSigsYosys: tl-x.org
   //   o set(MAKERCHIP, 0)  // (below)
   //   o For ASIC, set my_design (below) to match the configuration of your repositoy:
   //       - tt_um_fpga_hdl_demo for tt_fpga_hdl_demo repo
   //       - tt_um_example for tt06_verilog_template repo
   //   o var(target, FPGA)  // or ASIC (below)
   set(MAKERCHIP, 0)   /// 1 for simulating in Makerchip.
   var(my_design, tt_um_fpga_hdl_demo)   /// The name of your top-level TT module, to match your info.yml.
   var(target, ASIC)  /// FPGA or ASIC
   //-------------------------------------------------------
   
   var(debounce_inputs, 1)         /// 1: Provide synchronization and debouncing on all input signals.
                                   /// 0: Don't provide synchronization and debouncing.
                                   /// m5_neq(m5_MAKERCHIP, 1): Debounce unless in Makerchip.
   
   // ======================
   // Computed From Settings
   // ======================
   
   // If debouncing, a user's module is within a wrapper, so it has a different name.
   var(user_module_name, m5_if(m5_debounce_inputs, my_design, m5_my_design))
   var(debounce_cnt, m5_if_eq(m5_MAKERCHIP, 1, 8'h03, 8'hff))

\SV
   m4_include_lib(https:/['']/raw.githubusercontent.com/efabless/chipcraft---mest-course/main/tlv_lib/calculator_shell_lib.tlv)
   // Include Tiny Tapeout Lab.
   m4_include_lib(https:/['']/raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/35e36bd144fddd75495d4cbc01c4fc50ac5bde6f/tlv_lib/tiny_tapeout_lib.tlv)

   module s7_decode (
       input var  [3:0] in,
       output var [6:0] out
   );
     always_comb
       case (in)
         default: out = 7'b0111111;
         'h1: out = 7'b0000110;
         'h2: out = 7'b1011011;
         'h3: out = 7'b1001111;
         'h4: out = 7'b1100110;
         'h5: out = 7'b1101101;
         'h6: out = 7'b1111101;
         'h7: out = 7'b0000111;
         'h8: out = 7'b1111111;
         'h9: out = 7'b1100111;
         'ha: out = 7'b1110111;
         'hb: out = 7'b1111100;
         'hc: out = 7'b0111001;
         'hd: out = 7'b1011110;
         'he: out = 7'b1111001;
         'hf: out = 7'b1110001;
       endcase
   endmodule

\TLV calc()
   
   |calc
      @0
         $reset = *reset;
         $value[3:0] = *ui_in[3:0];
         $op[2:0] = *ui_in[6:4];
         
         $val1[7:0] = $reset ? 0 : >>2$out;
         $val2[7:0] = $value;
         //$cnt[31:0] = $reset ? 0 : >>1$cnt + 1;
         $valid[1:0] = ( (>>1$valid + 1) & $equals_in & (! >>1$equals_in)) ;
         $valid_or_reset = $valid | *reset;
         
         $equals_in = *ui_in[7];
         
      //?$valid
      //   @0
         $sum[7:0]  = $val1[7:0] + $val2[7:0];
         $diff[7:0] = $val1[7:0] - $val2[7:0];
         $prod[7:0] = $val1[7:0] * $val2[7:0];
         $quot[7:0] = $val1[7:0] / $val2[7:0];
         $op_code[2:0] = $op;
         
      //@1
      @1
         $out[7:0] = 
            $reset == 1
               ? 8'h0 :
                  ! $valid
               ? $RETAIN :
                  $op_code == 3'h0 
               ? $sum :
                  $op_code == 3'h1 
               ? $diff :
                  $op_code == 3'h2
               ? $prod:
                  $op_code == 3'h3
               ? $quot:
                  $op_code == 3'h4
               ? >>2$mem:
                  $RETAIN;
         
         $mem[7:0] =
            $reset ?
               8'h0 :
            $op ==3'h5 & $valid ?
               >>1$out :
               $RETAIN;
         
      @2      
         $digits[3:0] = >>1$out;
         *uo_out = 
            $digits == 4'h0 ?
               7'b0111111 :
            $digits == 4'h1 ?
               7'b0000110 :
            $digits == 4'h2 ?
               7'b1011011 :
            $digits == 4'h3 ?
               7'b1001111 :
            $digits == 4'h4 ?
               7'b1100110 :
            $digits == 4'h5 ?
               7'b1101101 :
            $digits == 4'h6 ?
               7'b1111101 :
            $digits == 4'h7 ?
               7'b0000111 :
            $digits == 4'h8 ?
               7'b1111111 :
            $digits == 4'h9 ?
               7'b1100111 :
            $digits == 4'ha ?
               7'b1110111 :
            $digits == 4'hb ?
               7'b1111100 :
            $digits == 4'hc ?
               7'b0111001 :
            $digits == 4'hd ?
               7'b1011110 :
            $digits == 4'he ?
               7'b1111001 :
            $digits == 4'hf ?
               7'b1110001 :
            7'b0;

               
               

   // ==================
   // |                |
   // | YOUR CODE HERE |
   // |                |
   // ==================
   
   // Note that pipesignals assigned here can be found under /fpga_pins/fpga.
   
   

   m5+cal_viz(@2, /fpga)
   
   // Connect Tiny Tapeout outputs. Note that uio_ outputs are not available in the Tiny-Tapeout-3-based FPGA boards.
   //*uo_out = 8'b0;
   m5_if_neq(m5_target, FPGA, ['*uio_out = 8'b0;'])
   m5_if_neq(m5_target, FPGA, ['*uio_oe = 8'b0;'])
   
\SV

// ================================================
// A simple Makerchip Verilog test bench driving random stimulus.
// Modify the module contents to your needs.
// ================================================

module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);
   // Tiny tapeout I/O signals.
   logic [7:0] ui_in, uo_out;
   m5_if_neq(m5_target, FPGA, ['logic [7:0]uio_in,  uio_out, uio_oe;'])
   logic [31:0] r;
   always @(posedge clk) r <= m5_if(m5_MAKERCHIP, ['$urandom()'], ['0']);
   assign ui_in = r[7:0];
   m5_if_neq(m5_target, FPGA, ['assign uio_in = 8'b0;'])
   logic ena = 1'b0;
   logic rst_n = ! reset;
   
   // Instantiate the Tiny Tapeout module.
   m5_user_module_name tt(.*);
   
   assign passed = top.cyc_cnt > 60;
   assign failed = 1'b0;
endmodule


// Provide a wrapper module to debounce input signals if requested.
m5_if(m5_debounce_inputs, ['m5_tt_top(m5_my_design)'])
\SV



// =======================
// The Tiny Tapeout module
// =======================

module m5_user_module_name (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    m5_if_eq(m5_target, FPGA, ['/']['*'])   // The FPGA is based on TinyTapeout 3 which has no bidirectional I/Os (vs. TT6 for the ASIC).
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    m5_if_eq(m5_target, FPGA, ['*']['/'])
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
   wire reset = ! rst_n;
   
\TLV
   /* verilator lint_off UNOPTFLAT */
   // Connect Tiny Tapeout I/Os to Virtual FPGA Lab.
   m5+tt_connections()
   
   // Instantiate the Virtual FPGA Lab.
   m5+board(/top, /fpga, 7, $, , calc)
   // Label the switch inputs [0..7] (1..8 on the physical switch panel) (top-to-bottom).
   m5+tt_input_labels_viz(['"Value[0]", "Value[1]", "Value[2]", "Value[3]", "Op[0]", "Op[1]", "Op[2]", "="'])

\SV
endmodule

