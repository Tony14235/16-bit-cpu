module cpu(clk,reset,mdata,in,out,N,V,Z,mem_addr,mem_cmd,halt);
    input clk, reset;
    input [15:0] in;
    input [15:0] mdata; //read_data from dout
    output [15:0] out;
    output N, V, Z;
    output [8:0]mem_addr;
    output [2:0]mem_cmd;
    output halt;

    wire [15:0] instruction;//wire connecting decoder and register of instruction
    wire [2:0]  nsel;      //mux switch for rn,rd,rm
    wire [2:0]  opcode;    //operation code
    wire [1:0]  op;        //opcode
    wire [1:0]  ALUop;     //ALUop
    wire [15:0] sximm8; // immediate value
    wire [1:0]  shift_in; // shift to FSM to datapath
    wire [2:0]  reg_num; // register to read and write
    wire [10:0] data_path_control; //control signals for datapath
    wire [5:0]  mem_control; // control signals for mem
    wire [15:0] sximm5;   //unknow usage
    wire [8:0] next_addr; //address out of PC +1
    wire [8:0] PC; //address out of PC
    wire [8:0] next_pc;  // wire connecting addr_mux and PC
    wire [8:0] DA;//output of Data address register 
    wire [8:0] return_addr; // always = PC + 1;
    wire [8:0] temp_addr; //always = PC + 1;
    wire s_sel;
    wire [3:0] state;
    wire [8:0] Rd;
     
register #(16) IR (mem_control[3], clk, in, instruction );//output to the instruction decoder, pass by value when load and posedge clk
decoder ID (instruction, nsel, opcode,op,sximm8,shift_in,reg_num,sximm5,ALUop);// take in instruction and nsel, outputs the rest to datapath and statemachine
state_machine SM (reset,clk,opcode,op,nsel,data_path_control,mem_control,mem_cmd,halt,state); //state machine,reset on 1, doesnot operate until s is 1 & posedge clk, w indicates waiting state, output control to datapath. 
datapath DP(mdata,sximm8,{7'b0000000,return_addr},out,data_path_control[10:7],data_path_control[3],data_path_control[2],data_path_control[5],data_path_control[4],
                      data_path_control[1],data_path_control[0],ALUop,shift_in,reg_num,data_path_control[6],reg_num,clk,{N,V,Z},sximm5);//recives control signals from statemachine and takes in data from decoder
mux2_9 reset_mux (9'b000000000,next_addr,mem_control[0],next_pc); // Mux that takes reset_pc as select and passes data to PC
addr_adder U1 (mem_control[5],state,out[8:0],PC,next_addr,sximm8,instruction,N,V,Z,temp_addr,s_sel);// add 1 or 1  & sximm8 to the curr_addr,which would be next_addr
register #(9) counter (mem_control[1],clk,next_pc,PC);//PC register that takes load_pc as load, output to addr_mux;
mux2_9 addr_mux (PC, DA, mem_control[2], mem_addr);// mux that takes addr_sel as select and passes requested mem_addr to memory
register #(9) data_address (mem_control[4],clk,out[8:0],DA);//data_adress register that takes load_addr as load, output to addr_mux
register #(9) sreg (s_sel, clk, temp_addr, return_addr);  //register for regulating pc data 


endmodule


`define RST 4'b0000 //reset_pc = 1, load_pc = 1;
`define IF1 4'b0001 //addr_sel = 1, memem_cmd = MREAD(010);  MNONE = (001); MWRITE = (100);
`define IF2 4'b0010  //addr_sel = 1, load_ir =1, memem_cmd = MREAD(010);
`define PC  4'b0100   //load_pc = 1;
`define Sa 4'b1000 //decode state
`define Sb 4'b1001 //below states have various meaning depending on the operation
`define Sc 4'b1010
`define Sd 4'b1011
`define Se 4'b1100
`define Sf 4'b1101
`define Sg 4'b1111

module state_machine(reset,clk,opcode,op,nsel,data_path_control,mem_control,mem_cmd,halt,state);
   input reset,clk;
   input [2:0] opcode;
   input [1:0] op;
   output [10:0]data_path_control; 
   output [2:0] nsel; // 
   output [5:0] mem_control;
   output [2:0] mem_cmd;
   output halt;
   output [3:0]state;

   reg [26:0] next;//pc_sel[26]+load_addr[25]+load_ir[24]+memem_cmd{23:21}+addr_sel[20]+load_pc[19]+reset_pc[18]+state[17:14]+vsel[13:10]+nsel[9:7]+write[6]+loada[5]+loadb[4]+asel[3]+bsel[2]+loadc[1]+loads[0]
   reg [3:0] state;
   reg [10:0] data_path_control;//vsel[10:7]+write[6]+loada[5]+loadb[4]++asel[3]+bsel[2]+loadc[1]+loads[0]
   reg [2:0] nsel;
   reg [5:0] mem_control;// pc_sel[5] + load_addr[4]+load_ir[3]+addr_sel[2]+load_pc[1]+reset_pc[0]
   reg [2:0] mem_cmd; 
   reg halt;

   always@(posedge clk)begin   //changes when clk is posedge
         
         casex({state,opcode,op,reset})
           {4'bxxxx,6'bxxxxx1}:next = {9'b000001011,`RST,14'b00000000000000};         //when reset is enabled;reset_pc =1, loac_pc = 1; go to rst;memem_cmd = MNONE;
           
           {`RST,6'bxxxxx0}:next = {9'b000010100,`IF1,14'b00000000000000};         //reset_pc =0, loac_pc = 0;addr_sel = 1; memem_cmd = MREAD;
           {`IF1,6'bxxxxx0}:next = {9'b001010100,`IF2,14'b00000000000000};         // reset_pc still 0; load_pc  =0;memem_cmd = MREAD; addr_sel =1;load_ir = 1;
           {`IF2,6'bxxxxx0}:next = {9'b000001010,`PC,14'b00000000000000};         // reset_pc still 0; load_pc  =1;memem_cmd = MNONE;addr_sel =0;load_ir = 0;
           {`PC,6'bxxxxx0}:next = {9'b000001000,`Sa,14'b00000000000000};         // reset_pc still 0; load_pc  =0;memem_cmd = MNONE;addr_sel =0;load_ir = 0;
        
   
           {`Sa,6'b111xx0}:next = {9'b000001000,`Sa,14'b00000000000000};          //HALT


           {`Sa,6'b010110}:next = {9'b000001000,`Sb,14'b01001001000000};          //BL,vsel PC,nsel rn,write 1
           {`Sb,6'b010110}:next = {9'b000010100,`IF1,14'b01001000000000};          //back to IF1


           {`Sa,6'b010100}:next = {9'b000001000,`Sb,14'b01001001000000};          //BLX,vsel PC,nsel rn,write 1
           {`Sb,6'b010100}:next = {9'b000001000,`Sc,14'b01000100011000};          //BLX,vsel PC,nsel rd,write 0,loadb =1;asel = 1; bsel = 0;loadc = 0;
           {`Sc,6'b010100}:next = {9'b000001000,`Sd,14'b01000100001010};          //BLX,vsel PC,nsel rd,write 0,loadb =0;asel = 1; bsel = 0;loadc = 1;
           {`Sd,6'b010100}:next = {9'b100001010,`Se,14'b01000100001010};          //BLX,vsel PC,nsel rd,write 0,loadb =0;asel = 1; bsel = 0;loadc = 1;
           {`Se,6'b010100}:next = {9'b000010100,`IF1,14'b01001000000000};          //back to IF1

           
           {`Sa,6'b010000}:next = {9'b000001000,`Sb,14'b01000100011000};          //BX,vsel PC,nsel rd,write 0,loadb =1;asel = 1; bsel = 0;loadc = 0;
           {`Sb,6'b010000}:next = {9'b000001000,`Sc,14'b01000100001010};          //BX,vsel PC,nsel rd,write 0,loadb =0;asel = 1; bsel = 0;loadc = 1;
           {`Sc,6'b010000}:next = {9'b100001010,`Sd,14'b01000100001010};          //BX,vsel PC,nsel rd,write 0,loadb =0;asel = 1; bsel = 0;loadc = 1;
           {`Sd,6'b010000}:next = {9'b000010100,`IF1,14'b01001000000000};         //Back to IF1


           {`Sa,6'b001000}:next = {9'b000010100,`IF1,14'b00000000000000};          //Branch instructions


           {`Sa,6'b100000}:next = {9'b000001000,`Sb,14'b00101000100110};          //STR Rd Rn #5,im8,nsel rn,loada =1,loadb =0,asel =0,bsel =1,loadc =1;  Get Ain(Rn)
           {`Sb,6'b100000}:next = {9'b000001000,`Sc,14'b00101000000110};          //STR Rd Rn #5,im8,nsel rn,loada = 0,loadb =0,asel =0,bsel =1,loadc =1; Get Bin(sximm5)
           {`Sc,6'b100000}:next = {9'b010001100,`Sd,14'b00100100011010};          //STR Rd Rn #5,im8,nsel rd;loada =0,loadb =1,asel =1,bsel =0,loadc =1,load_addr =1;addr_sel =1;Get Bin(Rd)
           {`Sd,6'b100000}:next = {9'b000001100,`Se,14'b00100100001010};          //STR Rd Rn #5,im8,nsel rd;loada =0,loadb =0,asel =1,bsel =0,loadc =1,load_addr =1;addr_sel =1;Get Bin(Rd)
           {`Se,6'b100000}:next = {9'b000100000,`Sf,14'b00100100000000};          //memem_cmd = MWRITE
           {`Sf,6'b100000}:next = {9'b000100000,`Sg,14'b00100100000000};          //memem_cmd = MWRITE
           {`Sg,6'b100000}:next = {9'b000010100,`IF1,14'b00100100000000};         //back to IF1
 
          
           {`Sa,6'b011000}:next = {9'b000001000,`Sb,14'b00011000100110};          //LDR Rd Rn #5,mdata,nsel rn,loada =1,loadb =0,asel =0,bsel =1,loadc =1;  Get Ain
           {`Sb,6'b011000}:next = {9'b000001000,`Sc,14'b00011000000110};          //LDR Rd Rn #5,mdata,nsel rn,loada = 0,loadb =0,asel =0,bsel =1,loadc =1; Get Bin
           {`Sc,6'b011000}:next = {9'b010001000,`Sd,14'b00010100000000};          //LDR Rd Rn #5 load_addr =1;memem_cmd = MNONE,addr_sel =0; datapath_out
           {`Sd,6'b011000}:next = {9'b000010000,`Se,14'b00010100000000};          //go through data_address register
           {`Se,6'b011000}:next = {9'b000010000,`Sf,14'b00010101000000};          //waiting to retrive memory, retireved on `Sf
           {`Sf,6'b011000}:next = {9'b000001000,`Sg,14'b00010100000000};          //writing unitl cycle `Sg
           {`Sg,6'b011000}:next = {9'b000010100,`IF1,14'b00010100000000};         //back to IF1
                     
           
           {`Sa,6'b110100}:next = {9'b000001000,`Sb,14'b00101001000000};         // MOV,IM8.vsel sximm8 nsel rn, s is 1, go from a to b           
           {`Sb,6'b110100}:next = {9'b000010100,`IF1,14'b00101000000000};         //MOV, IM8 vsel sximm8 nsel rn, s is x, go from b to a,disable write
          
           {`Sa,6'b110000}:next = {9'b000001000,`Sb,14'b10000010010010};         //mov,old data, reading rm, write is disabled., Rm to bin
           {`Sb,6'b110000}:next = {9'b000001000,`Sc,14'b10000010001010};         //asel= 1; loadc = 1;
           {`Sc,6'b110000}:next = {9'b000001000,`Sd,14'b10000101000010};         //mov,old data, write rd,write in enabled.
           {`Sd,6'b110000}:next = {9'b000010100,`IF1,14'b10000100000000};         //mov,old data, write is diasabled.

           {`Sa,6'b101000}:next = {9'b000001000,`Sb,14'b10000010011100};       //ADD rd,rn,rm, read rm, and shift. rm ,loadb  = 1;
           {`Sb,6'b101000}:next = {9'b000001000,`Sc,14'b10001000101100};       //ADD rd,rn,rm, read rn, and shift. rn ,loada  = 1;
           {`Sc,6'b101000}:next = {9'b000001000,`Sd,14'b10000100000010};       //ADD rd,rn,rm, nsel rd, and shift. rm+rn in datapathout;
           {`Sd,6'b101000}:next = {9'b000001000,`Se,14'b10000101000010};       //ADD rd,rn,rm, write rd, and shift. rd ,write  = 1;
           {`Se,6'b101000}:next = {9'b000010100,`IF1,14'b10000100000000};       //ADD rd,rn,rm, nsel rn, and shift.


           {`Sa,6'b101010}:next = {9'b000001000,`Sb,14'b10000010011100};       //CMP rn,rm  read rm, and shift. rm ,loadb  = 1;
           {`Sb,6'b101010}:next = {9'b000001000,`Sc,14'b10001000101100};       //CMP rn,rm  read rn, and shift. rn ,loada  = 1;         
           {`Sc,6'b101010}:next = {9'b000001000,`Sd,14'b10001000000001};       //CMP rn,rm  nsel rn, and shift. loads = 1;
           {`Sd,6'b101010}:next = {9'b000010100,`IF1,14'b10001000000000};       //CMP rn,rm  nsel rn, and shift;

           {`Sa,6'b101100}:next = {9'b000001000,`Sb,14'b10000010011100};       //AND rd,rn,rm, read rm, and shift. rm ,loadb  = 1;
           {`Sb,6'b101100}:next = {9'b000001000,`Sc,14'b10001000101100};       //AND rd,rn,rm, read rn, and shift. rn ,loada  = 1;
           {`Sc,6'b101100}:next = {9'b000001000,`Sd,14'b10000100000010};       //AND rd,rn,rm, nsel rd, and shift. rm&rn in datapathout;
           {`Sd,6'b101100}:next = {9'b000001000,`Se,14'b10000101000010};       //AND rd,rn,rm, write rd, and shift. rd ,write  = 1;
           {`Se,6'b101100}:next = {9'b000010100,`IF1,14'b10000100000000};       //AND rd,rn,rm, nsel rn, and shift.;
                                
           {`Sa,6'b101110}:next = {9'b000001000,`Sb,14'b10000010011100};       //MVN rd,rm  read rm, and shift. rm ,loadb  = 1;        
           {`Sb,6'b101110}:next = {9'b000001000,`Sc,14'b10000100001010};       //MVN rd,rm  nsel rd, and shift. loads = 1; ~rm in datapathout;
           {`Sc,6'b101110}:next = {9'b000001000,`Sd,14'b10000101000010};       //MVN rd,rm  write rd, and shift; rd, write = 1;
           {`Sd,6'b101110}:next = {9'b000010100,`IF1,14'b10000100000000};       //MVN rd,rm  nsel rd, and shift; 
           default:next = {27{1'bx}};
       endcase 
      
       halt = next[17]&~next[16]&~next[15]&~next[14]&opcode[2]&opcode[1]&opcode[0];
       state = next[17:14]; //first four bits of next;
       nsel = next[9:7];                          //assign nsel back to decoder
       data_path_control = {next[13:10],next[6:0]};  // signal meaning defined above with reg statement
       mem_control = {next[26:24],next[20:18]}; //signals in charge of reading and writing memory
       mem_cmd = next[23:21];// output memem_cmd to memory block
      end
endmodule

module decoder (instruction, nsel, opcode, op,sximm8,shift_in,reg_num,sximm5,ALUop);
    input [15:0]instruction;  //machine code in
    input [2:0]nsel;          //recieve from statemachine
    output [2:0] opcode;      
    output [1:0] op;
    output [1:0] ALUop;
    output [15:0]sximm8;     //immediate value
    output [1:0] shift_in;   // shift
    output [2:0] reg_num;    // readnum and writenum
    output [15:0] sximm5;   //unknow usage
    
    reg [2:0] rn,rd,rm;     // registers
    reg [15:0]sximm8;
    reg [1:0] shift_in;
    reg [2:0] opcode;
    reg [1:0] op;
    reg [2:0] reg_num;
    reg [1:0] ALUop;  
    reg [15:0]sximm5; 
 
  always @ (*)begin
      opcode = instruction[15:13]; //extract opcode
      op = instruction[12:11];    //extract op, used with MOV
      ALUop = instruction[12:11];  //extract ALUop, used with ALU
      rn = instruction[10:8];     //rn
      rd = instruction[7:5];      //rd
      rm = instruction[2:0];      //rm

       casex(instruction[15:11])
          5'b101xx:ALUop = instruction[12:11];  //ALU for ALU
          5'b110xx:ALUop = instruction[12:11];  //ALU for MOV
          5'b100xx:ALUop = instruction[12:11];  //ALU for STR
          5'b011xx:ALUop = instruction[12:11];  //ALU for LDR
          5'b001xx:ALUop = 2'b00; //ALU for B
          5'b010xx:ALUop = 2'b00; //ALU for BL,BLX,Bx
          default:ALUop = 2'b00;
      endcase
        casex(instruction[15:11])
          5'b101xx:shift_in = instruction[4:3];  //shift for alu
          5'b110xx:shift_in = instruction[4:3];  //shift for MOV,MOv is enabled for sximm8, but it doesnt matter
          5'b100xx:shift_in = 2'b00;
          5'b011xx:shift_in = 2'b00;
          5'b001xx:shift_in = 2'b00; //Branch instructions have 2'b00;
          5'b010xx:shift_in = 2'b00; //BL,BLX,Bx
          default:shift_in = 2'b00;
      endcase
      
	case(instruction[7])
          1'b0:sximm8 = {8'b00000000,instruction[7:0]};
          1'b1:sximm8 = {8'b11111111,instruction[7:0]};
          default: sximm8 = {8'bxxxxxxxx,instruction[7:0]};
      endcase
        case(instruction[4])
          1'b0:sximm5 = {11'b00000000000,instruction[4:0]};
          1'b1:sximm5 = {11'b11111111111,instruction[4:0]};
          default: sximm5 = {11'bxxxxxxxxxxx,instruction[4:0]};
      endcase
    
    end
    
  always @(nsel,rd,rn,rm) begin               //changes when ever nsel is changed(from statemachine)
     case(nsel)
          3'b100:reg_num = rn;                // base on select, choose data input.
          3'b010:reg_num = rd;
          3'b001:reg_num = rm;
          default: reg_num = {3{1'bx}};
      endcase
   end
endmodule

module mux2_9(addr_zero,next_addr,reset_pc,next_pc);                  //2 element, 9 bit mux
    input [8:0] addr_zero,next_addr ;
    input  reset_pc;
    output [8:0] next_pc;
    reg [8:0] next_pc;
    
    always @(*) begin
       case(reset_pc)
          1'b1:next_pc = addr_zero;                // base on select, choose data input.
          1'b0:next_pc = next_addr; 
          default: next_pc = {9{1'bx}};
      endcase
     end
endmodule   

module addr_adder (control,state,sout,curr_addr,next_addr,sximm8,instruction,N,V,Z,temp_addr,s_sel);
input [8:0] sout,curr_addr; 
input  N,V,Z;
input control; 
input [15:0] instruction; //cond = instruction[10:8]
input [3:0] state; 
input  [15:0]sximm8; 
output [8:0] next_addr;
output [8:0] temp_addr; 
output s_sel;

reg  [8:0] next_addr, temp_addr;
reg [8:0] eq,ne,lt,le;
reg s_sel;
wire [8:0] Rd;

assign Rd = control?sout[8:0]:curr_addr;   //Tristate buffer


always @(*) begin
  eq = {9{Z}};
  ne = {9{~Z}};
  lt = ~{9{N===V}};
le = {9{(lt||eq)}};
  

       casex(instruction[15:8])
          {3'b110,5'bxxxxx}:next_addr = curr_addr + 1'b1; // no branch instruction,MOV 
          {3'b101,5'bxxxxx}:next_addr = curr_addr + 1'b1; // no branch instruction,ALU 
          {3'b011,5'bxxxxx}:next_addr = curr_addr + 1'b1; // no branch instruction,LDR 
          {3'b100,5'bxxxxx}:next_addr = curr_addr + 1'b1; // no branch instruction,STR 
          {3'b111,5'bxxxxx}:next_addr = curr_addr + 1'b1; // no branch instruction,HALT 
          {3'b010,5'b11111}:next_addr = curr_addr + 1'b1 + sximm8[8:0]; // BL, PC + 1+ sximm8 
          {3'b010,5'b00000}:next_addr = Rd; // Bx, PC = Rd 
          {3'b010,5'b10111}:next_addr = Rd; // BLx, PC = Rd
          {3'b001,5'b00000}:next_addr = (curr_addr + 1'b1) + sximm8[8:0] ;   //B, always PC +1 +sximm8. 
          {3'b001,5'b00001}:next_addr = (curr_addr + 1'b1) + (sximm8[8:0]&eq);   //BEQ, Z =1, PC +1 +sximm8,else PC +1;    
          {3'b001,5'b00010}:next_addr = (curr_addr + 1'b1) + (sximm8[8:0]&ne) ;   //BNE, Z =0, PC +1 +sximm8,else PC +1; 
          {3'b001,5'b00011}:next_addr = (curr_addr + 1'b1) + (sximm8[8:0]&lt) ;   //BLT, N !=V, PC +1 +sximm8,else PC +1; 
          {3'b001,5'b00100}:next_addr = (curr_addr + 1'b1) + (sximm8[8:0]&le) ;   //BLE, Z =1 or N!=V, PC +1 +sximm8,else PC +1;        
          default: next_addr = {9{1'bx}};
      endcase

  temp_addr = curr_addr + 1'b1; //always +1
  s_sel = ~instruction[15]&instruction[14]&~instruction[13]&instruction[12]&~state[3]&state[2]&~state[1]&~state[0]; //0101,0100state, only BL and BLX
  
     end
endmodule 


