/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

 // comentariu block se face cu /* */

module instr_register (tb_ifc instrRegIf);
 
timeunit 1ns/1ns;
import instr_register_pkg::*;
  instruction_t  iw_reg [0:31];  // an array of instruction_word structures
  rezultat_t     rez;

  // write to the register
  always@(posedge instrRegIf.clk, negedge instrRegIf.cb_dut.reset_n)   // write into register
    if (!instrRegIf.cb_dut.reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (instrRegIf.cb_dut.load_en) begin
      case(instrRegIf.cb_dut.opcode)
      PASSA: rez =instrRegIf.cb_dut.operand_a;
      PASSB: rez =instrRegIf.cb_dut.operand_b;
      ADD:   rez =instrRegIf.cb_dut.operand_a+instrRegIf.cb_dut.operand_b;
      SUB:   rez =instrRegIf.cb_dut.operand_a-instrRegIf.cb_dut.operand_b;
      MULT:  rez =instrRegIf.cb_dut.operand_a*instrRegIf.cb_dut.operand_b;
      DIV:   rez =instrRegIf.cb_dut.operand_a/instrRegIf.cb_dut.operand_b;
      MOD:   rez =instrRegIf.cb_dut.operand_a%instrRegIf.cb_dut.operand_b;
      endcase

      iw_reg[instrRegIf.cb_dut.write_pointer] = '{instrRegIf.cb_dut.opcode,instrRegIf.cb_dut.operand_a,instrRegIf.cb_dut.operand_b, rez};
    end

  // read from the register
  always@(posedge instrRegIf.clk, negedge instrRegIf.cb_dut.reset_n) begin
   instrRegIf.cb_dut.instruction_word <= iw_reg[instrRegIf.cb_dut.read_pointer];  // continuously read from register
  end
// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force instrRegIf.cb_dut.operand_b = instrRegIf.cb_dut.operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule : instr_register
