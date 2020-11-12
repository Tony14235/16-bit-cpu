module regfile(data_in,writenum,write,readnum,clk,data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output [15:0] data_out;

  wire [7:0] registernum;     //which register to store
  wire [7:0] load;            //check write 
  wire [15:0] R0;    //registers
  wire [15:0] R1; 
  wire [15:0] R2; 
  wire [15:0] R3; 
  wire [15:0] R4; 
  wire [15:0] R5; 
  wire [15:0] R6; 
  wire [15:0] R7; 
  wire [7:0] readnum_onehot;  //which register to read     
  
 decoder38 choose(writenum, registernum); //decoder for write 
 assign load = {registernum[7] & write, registernum[6] & write,registernum[5] & write, registernum[4] & write,
          registernum[3] & write,registernum[2] & write,registernum[1] & write, registernum[0] & write};      //check status of write
  register #(16) r0 (load[0],clk,data_in,R0);           
  register #(16) r1 (load[1],clk,data_in,R1);
  register #(16) r2 (load[2],clk,data_in,R2);
  register #(16) r3 (load[3],clk,data_in,R3);
  register #(16) r4 (load[4],clk,data_in,R4);
  register #(16) r5 (load[5],clk,data_in,R5);
  register #(16) r6 (load[6],clk,data_in,R6);
  register #(16) r7 (load[7],clk,data_in,R7);

  decoder38 read(readnum, readnum_onehot);     //decoder for read 001 00000010
  mux8_16 pass(R0,R1,R2,R3,R4,R5,R6,R7,readnum_onehot, data_out); // mux to choose which register to read

endmodule

module decoder38(writenum, out);  //38decoder
    input [2:0] writenum;
    output [7:0] out;
                                                                   
     assign out[0] = ~writenum[0] & ~writenum[1] & ~writenum[2];  
     assign out[1] = writenum[0] & ~writenum[1] & ~writenum[2];
     assign out[2] = ~writenum[0] & writenum[1] & ~writenum[2];
     assign out[3] = writenum[0] & writenum[1] & ~writenum[2];
     assign out[4] = ~writenum[0] & ~writenum[1] & writenum[2];
     assign out[5] = writenum[0] & ~writenum[1] & writenum[2];
     assign out[6] = ~writenum[0] & writenum[1] & writenum[2];
     assign out[7] = writenum[0] & writenum[1] & writenum[2];
endmodule

module register(load, clk, in, out);   
   parameter n =16;
   input [n-1:0] in;
   input clk, load;
   output [n-1:0] out;
   reg [n-1:0] out;
   wire [n-1:0] next_out;
   
   assign next_out = load ? in:out; // if load is true, out = in on posedge clk
 
  always @(posedge clk)begin
     out = next_out; 
   end
endmodule

module mux8_16(r0,r1,r2,r3,r4,r5,r6,r7, read_num, data_out);
    input [15:0] r0,r1,r2,r3,r4,r5,r6,r7;
    input [7:0] read_num;
    output [15:0] data_out;
    reg [15:0] data_out;
    
    always @(*) begin          // case statements for Mux
       case(read_num)
          8'b00000001:data_out = r0; 
          8'b00000010:data_out = r1;
          8'b00000100:data_out = r2; 
          8'b00001000:data_out = r3; 
          8'b00010000:data_out = r4; 
          8'b00100000:data_out = r5; 
          8'b01000000:data_out = r6; 
          8'b10000000:data_out = r7; 
			 default:data_out = {16{1'bx}};
      endcase
     end
endmodule       











