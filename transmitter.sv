module transmitter
(
    input             clk,
    input             rst, valid,
    input       [7:0] rx,
    output            tx
);
parameter baud_rate = 9600;
parameter clk_freq  = 50_000_000;
logic [$clog2(clk_freq/baud_rate)-1:0] counter;
logic [7:0] temp;
logic temptx;
logic [7:0] bitcounter;
enum logic [1:0]
  {
     IDLE    = 2'b00,
     START   = 2'b01,
     BITS    = 2'b10,
     STOP    = 2'b11
  }
  state, next_state;

 always_ff @(posedge clk) begin
    case (state)
      IDLE: begin
        counter    <= '0;
        bitcounter <= '0;
        temptx     <= '1;
        if(valid) 
          next_state <= START;
       end
      

      START:  begin
           counter <= counter + 1'b1;
        if (counter == ((clk_freq/baud_rate)))  begin
          next_state  <= BITS;
          temptx      <= '0;
          temp        <= rx;
          counter     <= '0;
        end
      end

      BITS: begin
        counter <= counter + 1'b1;
        if (counter == (clk_freq/baud_rate))  begin
          bitcounter <= bitcounter + 1'b1;
          counter <= '0;
          temptx <= temp[bitcounter];
        end
        if (bitcounter==8) begin
          next_state  <= STOP;
        end
      end
      STOP: begin
           counter <= counter + 1'b1;
        if (counter == ((clk_freq/baud_rate)))  begin
          next_state  <= IDLE;
          counter     <= '0;
          temptx      <= '1;
        end
      end
    endcase
  end

// State update
always_ff @ (posedge clk)
    if (rst) 
      state <= IDLE;
    else
      state <= next_state;

   assign tx = temptx;
endmodule
