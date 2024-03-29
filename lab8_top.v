module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
input [3:0] KEY;
input [9:0] SW;
input CLOCK_50;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

wire [15:0] dout; // mem out to read data
wire [15:0] read_data; //wire carrying data read from mem to IR,also mdata
wire [15:0] write_data;//wire for the output of cpu, also datapath_out and din
wire N,V,Z; // status outputs
wire [2:0] mem_cmd; // MEM_CMD from cpu
wire [8:0] mem_addr;//mem_addr from cpu, 8th bit has speical usage, read_address
wire write; //wire going into write port of memory block


cpu CPU (CLOCK_50,~KEY[1],read_data,read_data,write_data,N,V,Z,mem_addr,mem_cmd,LEDR[8]);//cpu module, outputs datapath_out,N,V,Z,mem_addr,mem_cmd
RAM #(.data_width(16), .addr_width(8),.filename("lab8fig2.txt")) MEM (CLOCK_50,mem_addr[7:0],mem_addr[7:0],write,write_data,dout);//Memory module;
mem_manage Manager (mem_cmd,mem_addr[8],dout,read_data,write); //equality comparator in conjuction with a tristate buffer
mapping_io IO (CLOCK_50,9'h140,9'h100,SW[7:0],mem_cmd,mem_addr,read_data,write_data,LEDR[7:0]);//io for  top module




endmodule


module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule


module EqComp(a, b, eq) ; // equality comparator
  parameter k=8;
  input  [k-1:0] a,b;
  output eq;
  wire   eq;

  assign eq = (a==b) ;
endmodule

module mem_manage (mem_cmd,mem_addr,dout,read_data,write);//dout is an input, module includes 3 eqality comparator and a tri_state buffer
    input [2:0] mem_cmd;
    input mem_addr;//1 bit, the remaining 8 bit went into memory as input.
    input [15:0]dout; 
    output [15:0]read_data;
    output write;

    wire b,c;// carrying true and false for comparators
    wire msel;
    reg a;

always @(mem_addr)begin
    case(mem_addr)
        1'b0:a = 1'b1;
        1'b1:a = 1'b0;
         default:a = 1'b1;
    endcase
end

    EqComp #(3) COMP2 (mem_cmd,3'b010,b); //MREAD encoding 010
    
    EqComp #(3) COMP3 (mem_cmd,3'b100,c); //MWRITE encoding 100
    assign msel = a & b ;
    assign write = a & c;
    assign read_data = msel ? dout : {16{1'bZ}};
endmodule

module mapping_io (clk,address_1,address_2,SW,mem_cmd,mem_addr,read_data,write_data,LEDR);//io for  top module
  input clk;
  input[7:0] SW;
  input[2:0] mem_cmd;
  input[8:0] mem_addr; 
  input[8:0] address_1,address_2;
  input [15:0] write_data;
  
  output [15:0] read_data;
  output [7:0] LEDR; 
  reg  [7:0] LEDR; 
  

  wire a,b,c,d,LEDR_load,SWsel;
  
  EqComp #(3) COMP4 (mem_cmd,3'b010,a); //MREAD encoding 010
  EqComp #(3) COMP6 (mem_cmd,3'b100,c); //MWRITE encoding 100
  EqComp #(9) COMP5 (mem_addr,address_1,b); //compare address
  EqComp #(9) COMP7 (mem_addr,address_2,d); //compare address
  assign SWsel = a&b;
  assign LEDR_load = c&d;
  assign read_data = SWsel?{8'h00,SW[7:0]} :{16{1'bZ}};

  always @(posedge clk ) begin
    
   LEDR = LEDR_load?write_data[7:0]:LEDR;
  end




endmodule