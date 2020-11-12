module ALU ( Ain,Bin,ALUop,out, Z);  input [15:0] Ain,Bin;  input [1:0] ALUop;  output [15:0] out;
  output [2:0]Z;
  
  reg[15:0] out;  reg [2:0] Z;  always @(*) begin
       case(ALUop)
          2'b00:out = Ain + Bin; //adding
          2'b01:out = Ain - Bin; //suntractin
          2'b10:out = Ain & Bin; //and
          2'b11:out = ~Bin;      // not bin
          default:  out = {16{1'bx}};
      endcase

      if(out == 16'b000000000000000)begin //check if out is 0
        Z[0] = 1'b1;              //zeros status 100
     end
      else begin
       Z[0] = 1'b0;
      end
    
      if(out[15]==1'b1)begin
       Z[2] = 1'b1;            // negative status 010
       end
       else begin
       Z[2] = 1'b0;
       end
      
  
       casex({ALUop,Ain[15],Bin[15],out[15]})
       5'b00110:Z[1] = 1'b1;         // adding, result different sign
       5'b00001:Z[1] = 1'b1;         // adding, result different sign
       5'b00111:Z[1] = 1'b0;         // adding, result same sign
       5'b00000:Z[1] = 1'b0;         // adding, result same sign
       5'b0001x:Z[1] = 1'b0;         // adding, input different sign
       5'b0010x:Z[1] = 1'b0;         // adding, input different sign
       5'b0111X:Z[1] = 1'b0;         // sub, same sign input, cannot overflow
       5'b0100X:Z[1] = 1'b0;         // sub, same sign input, cannot overflow
       5'b01011:Z[1] = 1'b1;         // sub, pos - neg, out neg, overflow
       5'b01010:Z[1] = 1'b0;         // sub, pos - neg, out pos, no overflow
       5'b01100:Z[1] = 1'b1;         // sub, neg - pos, out pos, overflow
       5'b01101:Z[1] = 1'b0;         // sub, neg - pos, out neg , no overflow
       5'b1xxxx:Z[1] = 1'b0;         // no overflow with & and inverse operations 
            default:Z[1] = 1'bx;
       endcase  
      endendmodule
