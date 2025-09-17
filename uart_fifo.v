`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:26:09 08/29/2025 
// Design Name: 
// Module Name:    uart_fifo 
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

module uart_fifo(
    input [7:0] data_in,
    input clk_in,
    input rstn,
    input push,
    input pop,
    output reg [7:0] data_out,
    output fifo_empty,
    output fifo_full,
    output reg [4:0] count
    );
	 
	 reg [7:0]data_fifo[15:0];
	 
	 reg [3:0]ip_count,op_count;
	 
	 integer k;
	
	always@(posedge clk_in)
	begin
		if(!rstn)
		begin
			for(k=0;k<16;k=k+1)
				begin
					data_fifo[k] <= 0;
					ip_count <= 4'b0;
					op_count <= 4'b0;
 					count <= 5'b0;
					data_out <= 8'b00;
				end	
		end
			else
			begin
				case({push,pop})
					2'b00 : begin
									ip_count <= ip_count;
									op_count <= op_count;
									count <= count;
							  end
					2'b10 : begin
										op_count <= op_count;
								if(count <= 5'd15)
									begin
										ip_count <= ip_count + 1'b1;
										count <= count + 5'd1;
										data_fifo[ip_count] <= data_in;
									end
								else
									begin
										ip_count <= ip_count;
										count <= count;
									end
							  end
					2'b01 : begin
									ip_count <= ip_count;
										if(count > 5'd0)
											begin
												data_out <= data_fifo[op_count];
												op_count <= op_count + 1'b1;
												count <= count - 5'd1;
											end
										else
											begin
												op_count <= op_count;
												count <= count;
											end
								end
					2'b11 : begin
					               data_out <= data_fifo[op_count];
										data_fifo[ip_count] <= data_in;
										ip_count <= ip_count + 1'b1;
										op_count <= op_count + 1'b1;
							  end	
				endcase
			end
	end	
	
	assign fifo_full = (count == 5'd16) ? 1'b1 : 1'b0;
		
	assign fifo_empty = (count == 5'b0) ? 1'b1 : 1'b0;
	

endmodule