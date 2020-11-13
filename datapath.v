module datapath(mdata,sximm8,pc,datapath_out,vsel,asel,bsel,loada,loadb,loadc,loads,ALUop,shift,writenum,write,readnum,clk,Z_out,sximm5);
      input [15:0] mdata,sximm8,sximm5;
      input [15:0] pc;
      input asel,bsel,loada,loadb,loadc,loads,clk,write;
      input [3:0]vsel;
      input [1:0] ALUop,shift;
      input [2:0] writenum,readnum;
      output [15:0] datapath_out;
      output [2:0]Z_out;
      
      
      wire [15:0] data_in;
      wire [15:0] data_out;
      wire [15:0] aout;
      wire [15:0] in;
      wire [15:0] sout;
      wire [15:0] zeros = 16'b0000000000000000;
      wire [15:0] Ain;
      wire [15:0] Bin;
      wire [15:0] out;
      wire [2:0]Z;

      //mux4_16 com9 (mdata,sximm8,{8'b0,pc},datapath_out,vsel,data_in);         //component 9 chooses between old value and new value
      mux4_16 com9 (mdata,sximm8,{7'b0000000,pc[8:0]},datapath_out,vsel,data_in);         //component 9 chooses between old value and new value
      regfile REGFILE (data_in,writenum,write,readnum,clk,data_out);// Registerfile
      register A (loada, clk, data_out, aout);                      //register A
      register B (loadb, clk, data_out, in);                        //Register B
      shifter U1(in,shift,sout);                                    // shifter connecting B and componnet 7
      mux2_16 com6 (zeros,aout,asel,Ain);                          // Component 6, left mux
      mux2_16 com7 (sximm5,sout,bsel,Bin);                       // component 7, right mux
      ALU U2 ( Ain,Bin,ALUop, out, Z);                             // ALU
      register C (loadc, clk, out, datapath_out);                  // Register C
      register #(3) status (loads, clk, Z , Z_out);                //output register that captures status

endmodule

module mux2_16(datapath_in,cout,vsel,data_in);                  //2 element, 16 bit mux
    input [15:0] datapath_in,cout;
    input  vsel;
    output [15:0] data_in;
    reg [15:0] data_in;
    
    always @(*) begin
       case(vsel)
          1'b1:data_in = datapath_in;                // base on select, choose data input.
          1'b0:data_in = cout; 
          default: data_in = {16{1'bx}};
      endcase
     end
endmodule   

module mux4_16(mdata,sximm8,pc,cout,vsel,data_in);                  //4 element, 16 bit mux
    input [15:0] mdata,sximm8,pc,cout;
    input  [3:0]vsel;
    output [15:0] data_in;
    reg [15:0] data_in;
    
    always @(*) begin
       case(vsel)
          4'b0001:data_in = mdata;                // base on select, choose data input.
          4'b0010:data_in = sximm8;
          4'b0100:data_in = pc;
          4'b1000:data_in = cout;
          default: data_in = {16{1'bx}};
      endcase
     end
endmodule   