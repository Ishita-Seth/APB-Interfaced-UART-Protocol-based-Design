`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:16:34 08/30/2025 
// Design Name: 
// Module Name:    Transmitter_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision:  
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//strart
module Transmitter_top(
    input PCLK,
    input PRESETn,
    input [7:0] PWDATA,
    input tx_fifo_push,
    input enable,
    input [7:0] LCR,
    output[4:0] tx_fifo_count,
    output reg busy,
    output tx_fifo_empty,
    output tx_fifo_full,
    output TXD
    );
	 
	 reg pop_tx_fifo;  
	 wire [7:0] tx_fifo_out;
	 
	 reg TXD_temp;
	 reg [7:0]tx_buffer;
	 reg [3:0]bit_counter;
	 reg [3:0]tx_state;
	 
	 parameter IDLE = 4'b0000 , START = 4'b0001 , BIT0 = 4'b0010 , BIT1 = 4'b0011 , BIT2 = 4'b0100 , 
	           BIT3 = 4'b0101 , BIT4 = 4'b0110 , BIT5 = 4'b0111 , BIT6 = 4'b1000 , BIT7 = 4'b1001 ,
				  PARITY = 4'b1010 , STOP1 = 4'b1011 , STOP2 = 4'b1100 ;
	 
	 uart_fifo Tx_FIFO( PWDATA,PCLK,PRESETn,tx_fifo_push,pop_tx_fifo,tx_fifo_out,tx_fifo_empty,tx_fifo_full,tx_fifo_count);
	 
	 assign TXD = (LCR[6]) ? 1'b0 : TXD_temp;
	 
	 always@(posedge PCLK)
		begin
			if(!PRESETn)
				begin
					tx_state <= IDLE;
					busy <= 1'b0;
					tx_buffer <= 8'b00;
					bit_counter <= 4'b0;
					pop_tx_fifo <= 1'b0;
				end    
			else
					begin
					case(tx_state)
						IDLE : begin
									if(tx_fifo_empty == 1'b0 && enable)
										begin
										pop_tx_fifo <= 1'b1;
										tx_state <= START;
										busy <= 1'b1;
										end
									else
										tx_state <= IDLE;
								 end
						 START : begin
										pop_tx_fifo <= 1'b0;
										TXD_temp <= 1'b0;
										tx_buffer <= tx_fifo_out; 
										if(bit_counter == 4'hf && enable)
											begin
											tx_state <= BIT0;
											bit_counter <= 4'b0;
											end
										else if(enable)
											bit_counter <= bit_counter + 1'b1;
										TXD_temp <= 1'b0;
						         end
						  BIT0 : begin
									
										if(enable && bit_counter == 4'hf)
											begin
											tx_state <= BIT1;
											bit_counter <= 4'b0;
											end
										else if(enable)
											begin
											bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[0];
									end
						  BIT1 : begin
										
										if(enable && bit_counter == 4'hf)
											begin
											tx_state <= BIT2;
											bit_counter <= 4'b0;
											end
										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[1];
									end
						  BIT2 : begin
						  
										if(enable && bit_counter == 4'hf)
											begin
											tx_state <= BIT3;
											bit_counter <= 4'b0;
											end
										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[2];
									end
						 BIT3 : begin
										
										if(enable && bit_counter == 4'hf)
											begin
											tx_state <= BIT4;
											bit_counter <= 4'b0;
											end
										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[3];
								  end
						BIT4 : begin
										  if(enable && bit_counter == 4'hf && LCR[1:0] != 2'b00)
											begin
											tx_state <= BIT5;
											bit_counter <= 4'b0;
											end
									
										else if(enable && bit_counter == 4'hf && LCR[1:0] == 2'b00 && LCR[3] == 1'b0)
											begin
											tx_state <= STOP1;
											bit_counter <= 4'b0;
											end
										else if(enable && bit_counter == 4'hf && LCR[1:0] == 2'b00 && LCR[3] == 1'b1)
											begin
											tx_state <= PARITY;
											bit_counter <= 4'b0;
											end
										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[4];
								  end
						BIT5 : begin
										if(enable && bit_counter == 4'hf && LCR[1:0] > 2'b01)
											begin
											tx_state <= BIT6;
											bit_counter <= 4'b0;
											end
										
										else if(enable && bit_counter == 4'hf && LCR[1:0] < 2'b10 && LCR[3] == 1'b0)
											begin
											tx_state <= STOP1;
											bit_counter <= 4'b0;
											end
										else if(enable && bit_counter == 4'hf && LCR[1:0] < 2'b10 && LCR[3] == 1'b1)
											begin
											tx_state <= PARITY;
											bit_counter <= 4'b0;
											end

										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[5];
								end
						BIT6 : begin
										 if(enable && bit_counter == 4'hf && LCR[1:0] == 2'b11)
											begin
											tx_state <= BIT7;
											bit_counter <= 4'b0;
											end
										
										else if(enable && bit_counter == 4'hf && LCR[1:0] != 2'b11 && LCR[3] == 1'b0)
											begin
											tx_state <= STOP1;
											bit_counter <= 4'b0;
											end
										else if(enable && bit_counter == 4'hf && LCR[1:0] != 2'b11 && LCR[3] == 1'b1)
											begin
											tx_state <= PARITY;
											bit_counter <= 4'b0;
											end
							
										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[6];
								end
						BIT7 : begin
									
										if(enable && bit_counter == 4'hf && LCR[3] == 1'b1)
											begin
											tx_state <= PARITY;
											bit_counter <= 4'b0;
											end
										else if(enable && bit_counter == 4'hf && LCR[3] == 1'b0)
											begin
											tx_state <= STOP1;
											bit_counter <= 4'b0;
											end
										else if(enable)
											begin
												bit_counter <= bit_counter + 1'b1;
											end
										TXD_temp <= tx_buffer[7];
								 end
						PARITY : begin
										
											if(enable && bit_counter == 4'hf)
												begin
												tx_state <= STOP1;
												bit_counter <= 4'b0;
												end
											else if(enable)
												bit_counter <= bit_counter + 1'b1;
											case(LCR[5:3])
												3'b001 :	TXD_temp <= ^tx_buffer;
												3'b011 : TXD_temp <= ~(^tx_buffer);
										
												3'b101 :	TXD_temp <= 1'b1;
											
												3'b111 :	TXD_temp <= 1'b0;
												default : TXD_temp <= 1'b0;
											endcase
									end
						STOP1 : begin
										TXD_temp <= 1'b1;
										if(bit_counter == 4'hf && enable && LCR[2] == 1'b1)
											begin
											tx_state <= STOP2;
											bit_counter <= 4'b0;
											end
										else if(bit_counter == 4'hf && enable && LCR[2] == 1'b0)
											begin
											tx_state <= IDLE;
											bit_counter <= 4'b0;
											busy <= 1'b0;
									
											end
										else if(enable)
											bit_counter <= bit_counter + 1'b1;
								  end
					 STOP2  : begin
										if(bit_counter == 4'hf && enable)
											begin
											bit_counter <= 4'b0;
											tx_state <= IDLE;
											
											busy <= 1'b0;
											end
										else if(enable)
											bit_counter <= bit_counter + 1'b1;
										TXD_temp <= 1'b1;
								 end
						  endcase
					end	
			end	
	
endmodule