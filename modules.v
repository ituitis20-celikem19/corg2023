`timescale 1ns / 1ps

// PART 1

module n_bitRegister #(parameter N = 8) (
    input CLK, E, [1:0] FunSel, [N-1:0] I,
    output [N-1:0] Q
);

    reg [N-1:0] Q_temp;
    assign Q = Q_temp;
    always @( posedge CLK ) begin
    if(E) begin
        case (FunSel)
        0: begin
            Q_temp = 0;
        end
        1: begin
            Q_temp = I;
        end
        2: begin
            Q_temp = Q - 1;
        end
        3: begin
            Q_temp = Q + 1;
        end
        default: begin
            Q_temp = Q_temp;
        end
        endcase
    end else begin
    
        Q_temp = Q;
    end
    end
    
endmodule

//PART 2

//Part 2a

module IR (
    input CLK, LH, En, [1:0] FunSel, [7:0] I,
    output [15:0] IRout
);
    reg [15:0] I_temp; //reg
    wire [15:0] IR_Q;
    
    n_bitRegister #(.N(16)) IR(.CLK(CLK),.E(En), .FunSel(FunSel), .I(I_temp), .Q(IR_Q));
    
    assign IRout = IR_Q;

    always @(LH) begin
        case (LH)
            0: begin
                I_temp[7:0] = I;
            end
            1: begin
                I_temp[15:8] = I;
            end
        endcase
    end
    
endmodule

//Part 2b

module RegFile (
    input CLK, [2:0] O1Sel, [2:0] O2Sel, [1:0] FunSel, [3:0] RSel,[3:0] TSel, [7:0] I, 
    output [7:0] O1, [7:0] O2
);
    wire [7:0] R1_Q;
    wire [7:0] R2_Q;
    wire [7:0] R3_Q;
    wire [7:0] R4_Q;
    
    wire [7:0] T1_Q;
    wire [7:0] T2_Q;
    wire [7:0] T3_Q;
    wire [7:0] T4_Q;
    
    n_bitRegister #(.N(8)) R1(.CLK(CLK),.E(~RSel[0]), .FunSel(FunSel), .I(I), .Q(R1_Q));
    n_bitRegister #(.N(8)) R2(.CLK(CLK),.E(~RSel[1]), .FunSel(FunSel), .I(I), .Q(R2_Q));
    n_bitRegister #(.N(8)) R3(.CLK(CLK),.E(~RSel[2]), .FunSel(FunSel), .I(I), .Q(R3_Q));
    n_bitRegister #(.N(8)) R4(.CLK(CLK),.E(~RSel[3]), .FunSel(FunSel), .I(I), .Q(R4_Q));
    
    n_bitRegister #(.N(8)) T1(.CLK(CLK),.E(~TSel[0]), .FunSel(FunSel), .I(I), .Q(T1_Q));
    n_bitRegister #(.N(8)) T2(.CLK(CLK),.E(~TSel[1]), .FunSel(FunSel), .I(I), .Q(T2_Q));
    n_bitRegister #(.N(8)) T3(.CLK(CLK),.E(~TSel[2]), .FunSel(FunSel), .I(I), .Q(T3_Q));
    n_bitRegister #(.N(8)) T4(.CLK(CLK),.E(~TSel[3]), .FunSel(FunSel), .I(I), .Q(T4_Q));

    //wire [3:0] R_En;

    reg [7:0] Out1_temp, Out2_temp;
    assign O1 = Out1_temp;
    assign O2 = Out2_temp;
    
    always@(O1Sel) begin
        case (O1Sel)
        0: begin
            Out1_temp = T1_Q;
        end
        1: begin
            Out1_temp = T2_Q;
        end
        2: begin
            Out1_temp = T3_Q;
        end
        3: begin
            Out1_temp = T4_Q;
        end
        4: begin
            Out1_temp = R1_Q;
        end
        5: begin
            Out1_temp = R2_Q;
        end
        6: begin
            Out1_temp = R3_Q;
        end
        7: begin
            Out1_temp = R4_Q;
        end
        default: begin
            Out1_temp = Out1_temp;
        end
        endcase
    end
    always@(O2Sel) begin
        case (O2Sel)
        0: begin
            Out2_temp = T1_Q;
        end
        1: begin
            Out2_temp = T2_Q;
        end
        2: begin
            Out2_temp = T3_Q;
        end
        3: begin
            Out2_temp = T4_Q;
        end
        4: begin
            Out2_temp = R1_Q;
        end
        5: begin
            Out2_temp = R2_Q;
        end
        6: begin
            Out2_temp = R3_Q;
        end
        7: begin
            Out2_temp = R4_Q;
        end
        default: begin
            Out2_temp = Out2_temp;
        end
        endcase
    end

endmodule


//Part 2c

module ARF (
    input CLK, [1:0] OutASel, [1:0] OutBSel, [1:0] FunSel, [3:0] RegSel, [7:0] I,
    output [7:0] OutA, [7:0] OutB
);

    wire [7:0] PC_Q;
    wire [7:0] AR_Q;
    wire [7:0] SP_Q;
   
    
    n_bitRegister #(.N(8)) PC(.CLK(CLK),.E(~RegSel[2]), .FunSel(FunSel), .I(I), .Q(PC_Q));
    n_bitRegister #(.N(8)) AR(.CLK(CLK),.E(~RegSel[1]), .FunSel(FunSel), .I(I), .Q(AR_Q));
    n_bitRegister #(.N(8)) SP(.CLK(CLK),.E(~RegSel[0]), .FunSel(FunSel), .I(I), .Q(SP_Q));
    


    reg [7:0] OutA_temp, OutB_temp, PC_PREV_Q;
    assign OutA = OutA_temp;
    assign OutB = OutB_temp;

    always@(OutASel) begin
        case (OutASel)
        0: begin
            OutA_temp = AR_Q;
        end
        1: begin
            OutA_temp = SP_Q;
        end
        2: begin
            OutA_temp = PC_PREV_Q;
        end
        3: begin
            OutA_temp = PC_Q;
            PC_PREV_Q = PC_Q;
        end
        default: begin
            OutA_temp = OutA_temp;
            PC_PREV_Q = PC_Q;
        end
        endcase
    end

    always@(OutBSel) begin
        case (OutBSel)
        0: begin
            OutB_temp = AR_Q;
        end
        1: begin
            OutB_temp = SP_Q;
        end
        2: begin
            OutB_temp = PC_PREV_Q;
        end
        3: begin
            OutB_temp = PC_Q;
            PC_PREV_Q = PC_Q;
        end
        default: begin
            OutB_temp = OutB_temp;
            PC_PREV_Q = PC_Q;
        end
        endcase
     end    
endmodule

//PART 3

module ALU (
    input CLK, [3:0] FunSel, input [7:0] A, [7:0] B, 
    output [7:0] OutALU, reg [3:0] OutFlag = 4'b0
);
    
    wire Cin;
    reg [7:0] ALU_result;
    assign Cin = OutFlag[2];
    assign OutALU = ALU_result;
    reg  enable_o;
    
    always @(*) begin 
    case (FunSel)
        4'b0000: begin
            ALU_result <= A;
            enable_o <= 0;
        end
        4'b0001: begin
            ALU_result <= B;
            enable_o <= 0;
        end
        4'b0010: begin
            ALU_result <= ~A;
            enable_o <= 0;
        end
        4'b0011: begin
            ALU_result <= ~B;
            enable_o <= 0;
        end
        4'b0100: begin
            ALU_result <= A + B;
            enable_o <= 1;
        end
        4'b0101: begin
            ALU_result <= A - B;
            enable_o <= 1;
        end
        4'b0110: begin
            if(A > B) begin
            ALU_result <= A;
            end else begin
            ALU_result <= B;
            end
            enable_o <= 1;
        end
        4'b0111: begin
            ALU_result <= A & B;
            enable_o <= 0;
        end
        4'b1000: begin
            ALU_result <= A | B;
            enable_o <= 0;
        end
        4'b1001: begin
            ALU_result <= ~(A & B);
            enable_o <= 0;
        end
        4'b1010: begin
            ALU_result <= A ^ B;
            enable_o <= 0;
        end
        4'b1011: begin
            OutFlag[2] <= A[7];
            ALU_result <= A << 1;
            enable_o <= 0;
        end
        4'b1100: begin
            OutFlag[2] <= A[0];
            ALU_result <= A >> 1;
            enable_o <= 0;
        end
        4'b1101: begin
            ALU_result <= A <<< 1;
            enable_o <= 0;
        end
        4'b1110: begin
            ALU_result <= A >>> 1;
            enable_o <= 1;
        end
        4'b1111: begin
            OutFlag[2] <= A[0];
            ALU_result[0] <= A[1];
            ALU_result[1] <= A[2];
            ALU_result[2] <= A[3];
            ALU_result[3] <= A[4];
            ALU_result[4] <= A[5];
            ALU_result[5] <= A[6];
            ALU_result[6] <= A[7];
            ALU_result[7] <= OutFlag[2];
            //ALU_result = { A[0], A[7:1]};

            enable_o = 0;
        end
    endcase
    end
    
    always @(negedge CLK) begin
        if(ALU_result == 0) begin
            OutFlag[3] = 1;
        end else begin
            OutFlag[3] = 0;
        end

        if(ALU_result[7] == 1) begin
            OutFlag[1] = 1;
        end else begin
            OutFlag[1] = 0;
        end
        
        if((A[7] == ~ALU_result[7]) && (enable_o)) begin
            OutFlag[0] = 1;
        end
    end
            
endmodule

//PART 4

module Memory(
    input wire[7:0] address,
    input wire[7:0] data,
    input wire wr, //Read = 0, Write = 1
    input wire cs, //Chip is enable when cs = 0
    input wire clock,
    output reg[7:0] o // Output
);
    //Declaration o?f the RAM Area
    reg[7:0] RAM_DATA[0:255];
    //Read Ram data from the file
    initial $readmemh("RAM.mem", RAM_DATA);
    //Read the selected data from RAM
    always @(*) begin
        o = ~wr && ~cs ? RAM_DATA[address] : 8'hZ;
    end
    
    //Write the data to RAM
    always @(posedge clock) begin
        if (wr && ~cs) begin
            RAM_DATA[address] <= data; 
        end
    end
endmodule

//PROJECT 2
module control_unit (
input [7:0] ir_15_8,
input [7:0] ir_7_0,
input [3:0] ALU_OutFlag,
input clk,
input reset,
output 
    reg [1:0] RF_O1Sel, 
    reg [1:0] RF_O2Sel, 
    reg [1:0] RF_FunSel,
    reg [3:0] RF_RSel,
    reg [3:0] RF_TSel,
    reg [3:0] ALU_FunSel,
    reg [1:0] ARF_OutASel, 
    reg [1:0] ARF_OutBSel, 
    reg [1:0] ARF_FunSel,
    reg [2:0] ARF_RegSel,
    reg IR_LH,
    reg IR_Enable,
    reg [1:0] IR_Funsel,
    reg Mem_WR,
    reg Mem_CS,
    reg [1:0] MuxASel,
    reg [1:0] MuxBSel,
    reg MuxCSel
);
    reg [3:0] opcode;
    //Instruction type 1, has address reference
    reg AddressMode;
    reg [2:0] RSel;
    //Instruction type 2, no address reference
    reg [3:0] Dstreg;
    reg [7:0] Value;
    reg [3:0] SREG1, SREG2;
    
    reg [2:0] SeqCounter = 0;
    reg [15:0] ProgCounter = 0;
    reg finish = 0;
    
    always @(posedge clk) begin
        if (finish == 1'b1) begin
            SeqCounter <= 0;
        end
        else  begin
        SeqCounter <= SeqCounter + 1;
        ProgCounter <= ProgCounter + 1;
            
        end
    end
    
    always@(*) begin
        if(ProgCounter == 16'hFFFF || reset ==1) begin
            ARF_RegSel <= 3'b000;
            ARF_FunSel <= 2'b11;
            RF_RSel <= 4'b0000;
            RF_FunSel <= 2'b00; //clear
        end
    end

    //Fetch
    always@(*)begin
    if(SeqCounter == 0) begin
        ARF_OutBSel <= 2'b00;
        ARF_RegSel <= 3'b011;
        ARF_FunSel <= 2'b11; //increment 
        Mem_CS <= 0; 
        Mem_WR <= 0;
        IR_Enable <= 1; 
        IR_Funsel <= 2'b01; 
        IR_LH <= 1;
    end

    if(SeqCounter == 1) begin
        ARF_OutBSel <= 2'b00;
        ARF_RegSel <= 3'b011;
        ARF_RegSel <= 3'b011;
        ARF_FunSel <= 2'b11; //increment 
        Mem_CS <= 0;
        Mem_WR <= 0;
        IR_Enable <= 1;
        IR_Funsel <= 2'b01;
        IR_LH <= 0;
    end

    //Decode
    if(SeqCounter == 2) begin
        opcode <= ir_15_8[7:4];
        if((opcode == 4'h00) || (opcode == 4'h01) || (opcode == 4'h02) || (opcode == 4'h0F) ) begin 
            RSel <= ir_15_8[1:0];
            AddressMode <= ir_15_8[2];
        end else begin
            Dstreg <= ir_15_8[3:0];
            SREG2 <= ir_7_0[3:0];
            SREG1 <= ir_7_0[7:4];
        end
        
    end

    //Execute 1
    if(SeqCounter == 3) begin
        case(opcode) 
            4'h00:begin //AND
                ALU_FunSel <= 4'b0111; //A and B
                end
            4'h01:begin //OR
                ALU_FunSel <= 4'b1000; //A or B
                end
            4'h02:begin //NOT
                ALU_FunSel <= 4'b0010; // not A
                end
            4'h03:begin //ADD
                ALU_FunSel <= 4'b0100; //  A + B
                end
            4'h04:begin //SUB
                ALU_FunSel <= 4'b0101; //  A - B
                end
            4'h05:begin //LSR
                ALU_FunSel <= 4'b1100; //  A<<
                end
            4'h06:begin //LSL
                ALU_FunSel <= 4'b1011; //  >>A
                end
            4'h07:begin //INC
                ALU_FunSel <= 4'b0000; //load A
                end
            4'h08:begin //DEC
                ALU_FunSel <= 4'b0000; //load A
                end
            4'h09:begin //BRA
                MuxBSel <= 2'b10;
                ARF_RegSel <= 3'b011; 
                ARF_FunSel <= 2'b01; 
                end
            4'h0A:begin //BNE
                if (ALU_OutFlag[3] == 0) begin
                    MuxBSel <= AddressMode ? 2'b10 : 2'b01;
                    ARF_FunSel <= 2'b01;
                    ARF_RegSel <= 3'b011;
                    end
                end
            4'h0B:begin //MOV
                ALU_FunSel <= 4'b0000;
            end
            4'h0C:begin //LD
                Mem_CS <= 0;
                Mem_WR <= 0;
                if(AddressMode) begin
                    MuxASel <= 2'b01;
                end else begin
                    MuxASel <= 2'b00;
                end
                
                case("`RSel") 
                    2'b00: RF_RSel <= 4'b1000;
                    2'b01: RF_RSel <= 4'b0100;
                    2'b10: RF_RSel <= 4'b0010;
                    2'b11: RF_RSel <= 4'b0001;
                endcase
            end
            4'h0D:begin //ST
                RF_O2Sel <= RSel;
                ALU_FunSel <= 4'b0001; //pass B
                Mem_CS <= 0;
                Mem_WR <= 1;
            end
            4'h0E:begin //PULL
                ARF_OutBSel <= 2'b01;
                Mem_CS <= 0; 
                Mem_WR <= 1;
                MuxASel <= 2'b01;
                case("`RSel") 
                    2'b00: RF_RSel <= 4'b1000;
                    2'b01: RF_RSel <= 4'b0100;
                    2'b10: RF_RSel <= 4'b0010;
                    2'b11: RF_RSel <= 4'b0001; 
                endcase
            end
            4'h0F:begin //PSH
                ARF_RegSel <= 3'b110;
                ARF_FunSel <= 2'b00; //decrement 
                end
        endcase

        if((opcode >= 4'h00 && opcode <= 4'h08)||opcode == 4'h0B) begin 
            if(Dstreg <= 4'b0011) begin 
                MuxASel <= 2'b00;
                RF_FunSel <= 2'b01;
            end else begin
                MuxBSel <= 2'b00;
                ARF_FunSel <= 2'b01;
            end
            
            if( opcode == 4'h07 )begin
                if(SREG1 <= 4'b0011) begin
                    RF_FunSel <= 2'b01; //increment
                end else begin
                    ARF_FunSel <= 2'b01;
                end
            end
            
                
            if(opcode == 4'h08) begin
                if(SREG1 <= 4'b0011) begin
                    RF_FunSel <= 2'b00; //decrement
                end else begin
                    ARF_FunSel <= 2'b00;
                end
            end
            
            case(Dstreg)
            4'b0000:begin
                RF_RSel <= 4'b0111;
                end
            4'b0001:begin
                RF_RSel <= 4'b1011;
                end
            4'b0010:begin
                RF_RSel <= 4'b1101;
                end
            4'b0011:begin
                RF_RSel <= 4'b1110;
                end
            4'b0100:begin
                ARF_RegSel <= 3'b110;
                end
            4'b0101:begin
                ARF_RegSel <= 3'b101;
                end
            4'b0110:begin
                ARF_RegSel <= 3'b011;
                end
            4'b0111:begin
                ARF_RegSel <= 3'b011;
                end
        
            endcase
            
            case(SREG1)
             4'b0000:begin
                RF_RSel <= 4'b0111;
                end
            4'b0001:begin
                RF_RSel <= 4'b1011;
                end
            4'b0010:begin
                RF_RSel <= 4'b1101;
                end
            4'b0011:begin
                RF_RSel <= 4'b1110;
                end
            4'b0100:begin
                ARF_RegSel <= 3'b110;
                end
            4'b0101:begin
                ARF_RegSel <= 3'b101;
                end
            4'b0110:begin
                ARF_RegSel <= 3'b011;
                end
            4'b0111:begin
                ARF_RegSel <= 3'b011;
                end
                    
            endcase

            case (SREG2)
            4'b0000:begin
                RF_RSel <= 4'b0111;
                end
            4'b0001:begin
                RF_RSel <= 4'b1011;
                end
            4'b0010:begin
                RF_RSel <= 4'b1101;
                end
            4'b0011:begin
                RF_RSel <= 4'b1110;
                end
            4'b0100:begin
                ARF_RegSel <= 3'b110;
                end
            4'b0101:begin
                ARF_RegSel <= 3'b101;
                end
            4'b0110:begin
                ARF_RegSel <= 3'b011;
                end
            4'b0111:begin
                ARF_RegSel <= 3'b011;
                end
            endcase

            MuxCSel <= ((SREG2 < 4'b0100) || (SREG1 < 4'b0100)) ? 0:1;
            end 
        end

    //Execute 2
    if(SeqCounter == 4) begin
        case(opcode) 
            4'h0B:begin // PUL
                ARF_RegSel <= 3'b110;
                ARF_FunSel <= 2'b01; //increment 
                end
            4'h0C:begin //PSH
                RF_O2Sel <= RSel;
                ALU_FunSel <= 4'b0001; //pass B
                ARF_OutBSel <= 2'b11;
                Mem_CS <= 0; 
                Mem_WR <= 1;
                end
                
            default: begin
                finish <= 1;
            end
        endcase
    end

    if(SeqCounter == 5) 
        finish <= 1;
    
    end
endmodule


module ALUSystem
( input
    [1:0] RF_O1Sel, 
    [1:0] RF_O2Sel, 
    [1:0] RF_FunSel,
    [3:0] RF_RSel,
    [3:0] RF_TSel,
    [3:0] ALU_FunSel,
    [1:0] ARF_OutASel, 
    [1:0] ARF_OutBSel, 
    [1:0] ARF_FunSel,
    [2:0] ARF_RegSel,
    IR_LH,
    IR_Enable,
    [1:0] IR_Funsel,
    Mem_WR,
    Mem_CS,
    [1:0] MuxASel,
    [1:0] MuxBSel,
    MuxCSel,
    Clock,
    output [15:0] IROut,
    output [3:0] ALUOutFlag
    );
wire [7:0] ALUOut;
wire [7:0] Address;
wire [7:0] MemoryOut;
wire [7:0] ARF_AOut;
reg [7:0] MuxBOut;
wire [7:0] IR_Out_LSB;
Memory Mem(.address(Address), .data(ALUOut), .wr(Mem_WR), .cs(Mem_CS), .clock(Clock), .o(MemoryOut));
//address, data ve output 8 bit gerisi tek bit

ARF arf1(.OutASel(ARF_OutASel), .OutBSel(ARF_OutBSel), .FunSel(ARF_FunSel), .RegSel(ARF_RegSel), .I(MuxBOut) , .OutA(ARF_AOut), .OutB(Address), .CLK(Clock));

always @(*) begin
    case (MuxBSel)
        2'b01: begin
            MuxBOut <= IR_Out_LSB;
        end
        2'b10: begin
            MuxBOut <= MemoryOut;
        end
        2'b11: begin
            MuxBOut <= ALUOut;
        end
    endcase
end



assign IR_Out_LSB = IROut[7:0];

IR ir1(.LH(IR_LH), .En(IR_Enable), .FunSel(IR_Funsel),.I(MemoryOut), .IRout(IROut), .CLK(Clock));

reg [7:0] MuxAOut;

always @(*) begin
    case (MuxASel)
        2'b00: begin
            MuxAOut = IR_Out_LSB;
        end
        2'b01: begin
            MuxAOut = MemoryOut;
        end
        2'b10: begin
            MuxAOut = ARF_AOut;
        end
        2'b11: begin
            MuxAOut = ALUOut;
        end
    endcase
end

wire [7:0] AOut, BOut;
RegFile rf1(.O1Sel(RF_O1Sel), .O2Sel(RF_O2Sel), .FunSel(RF_FunSel), .RSel(RF_RSel), .TSel(RF_TSel),  .I(MuxAOut), .O1(AOut), .O2(BOut),.CLK(Clock));

wire [7:0] MuxCOut;

assign MuxCOut = MuxCSel ? AOut: ARF_AOut;


ALU alu1(.FunSel(ALU_FunSel), .A(MuxCOut), .B(BOut), .OutALU(ALUOut), .OutFlag(ALUOutFlag), .CLK(Clock));

endmodule

module CPUSystem( input Clock, input Reset, input T);
    wire [1:0] RF_O1Sel; 
    wire [1:0] RF_O2Sel;
    wire [1:0] RF_FunSel;
    wire [3:0] RF_RSel;
    wire [3:0] RF_TSel;
    wire [3:0] ALU_FunSel;
    wire [1:0] ARF_OutASel; 
    wire [1:0] ARF_OutBSel; 
    wire [1:0] ARF_FunSel;
    wire [2:0] ARF_RegSel;
    wire IR_LH;
    wire IR_Enable;
    wire [1:0] IR_Funsel;
    wire Mem_WR;
    wire Mem_CS;
    wire [1:0] MuxASel;
    wire [1:0] MuxBSel;
    wire MuxCSel;
    wire [15:0] IROut;
    wire [3:0] ALUOutFlag;
control_unit cpu(
.ir_15_8(IROut[15:8]),
.ir_7_0(IROut[7:0]),
.ALU_OutFlag(ALUOutFlag),
.clk(Clock),
.RF_O1Sel(RF_O1Sel), 
.RF_O2Sel(RF_O2Sel), 
.RF_FunSel(RF_FunSel),
.RF_RSel(RF_RSel),
.RF_TSel(RF_TSel),
.ALU_FunSel(ALU_FunSel),
.ARF_OutASel(ARF_OutASel), 
.ARF_OutBSel(ARF_OutBSel), 
.ARF_FunSel(ARF_FunSel),
.ARF_RegSel(ARF_RegSel),
.IR_LH(IR_LH),
.IR_Enable(IR_Enable),
.IR_Funsel(IR_Funsel),
.Mem_WR(Mem_WR),
.Mem_CS(Mem_CS),
.MuxASel(MuxASel),
.MuxBSel(MuxBSel),
.MuxCSel(MuxCSel),
.reset(reset)
);

ALUSystem ALU
( 
    .RF_O1Sel(RF_O1Sel),
    .RF_O2Sel(RF_O2Sel), 
    .RF_FunSel(RF_FunSel),  
    .RF_RSel(RF_RSel),
    .RF_TSel(RF_TSel),  
    .ALU_FunSel(ALU_FunSel),
    .ALUOutFlag(ALUOutFlag), 
    .ARF_OutASel(ARF_OutASel), 
    .ARF_OutBSel(ARF_OutBSel), 
    .ARF_FunSel(ARF_FunSel),
    .ARF_RegSel(ARF_RegSel),
    .IR_LH(IR_LH),
    .IR_Enable(IR_Enable),
    .IR_Funsel(IR_Funsel),
    .Mem_WR(Mem_WR),
    .Mem_CS(Mem_CS),
    .MuxASel(MuxASel),
    .MuxBSel(MuxBSel),
    .MuxCSel(MuxCSel),
    .Clock(Clock),
    .IROut(IROut)
    );
endmodule
