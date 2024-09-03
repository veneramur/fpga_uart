module top(
	input 		 clk,
	input 		 reset,
	input 		 uart_rx,
	output 		 uart_tx,
	output [7:0] seg_data,
	output [3:0] seg_digit
	
);
logic [7:0] rx_data;
logic valid;
receiver 	rx (.clk(clk), .rst(~reset), .rx(uart_rx), .data(rx_data), .done(valid)); 
transmitter tx (.clk(clk), .rst(~reset), .rx(rx_data), .tx(uart_tx), .valid(valid)); 
segments segments (.clk(clk), .rst(~reset), .data(rx_data), .seg_data(seg_data), .seg_digit(seg_digit));
endmodule