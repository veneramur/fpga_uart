module segments (
	input 	 	 clk,
	input			 rst,
	input  [7:0] data,
	output [7:0] seg_data,
	output [3:0] seg_digit
);
	logic [3:0] mux_data;
	logic [7:0] demux_data;
	logic [$clog2(50_000_000/100)-1:0]  counter;
	always_ff @(posedge clk) begin
		if (rst) begin
			seg_digit <= 4'b1110;
		end
		else if (counter==0)
			seg_digit <= {seg_digit[2:0],seg_digit[3]};
	end
	
	always_comb begin
		case(seg_digit)
			4'b1110: mux_data = data[3:0];
			4'b1101: mux_data = data[7:4];
			default: mux_data = 4'hf;
		endcase
	end
	
	always_comb begin
		case(mux_data)
		  'h0: demux_data = 'b11111100;  // a b c d e f g h
        'h1: demux_data = 'b01100000;
        'h2: demux_data = 'b11011010;  //   --a--
        'h3: demux_data = 'b11110010;  //  |   |
        'h4: demux_data = 'b01100110;  //  f   b
        'h5: demux_data = 'b10110110;  //  |   |
        'h6: demux_data = 'b10111110;  //   --g--
        'h7: demux_data = 'b11100000;  //  |   |
        'h8: demux_data = 'b11111110;  //  e   c
        'h9: demux_data = 'b11100110;  //  |   |
        'ha: demux_data = 'b11101110;  //   --d--  h
        'hb: demux_data = 'b00111110;
        'hc: demux_data = 'b10011100;
        'hd: demux_data = 'b01111010;
        'he: demux_data = 'b10011110;
        'hf: demux_data = 'b10001110;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if(rst) counter <= '0;
		else counter <= counter+1'b1;
	end
	assign seg_data = ~demux_data;
endmodule