module receiver
(
    input                clk,
    input                rst,
    input                rx,
    output logic         [7:0] data,
    output done
);
parameter baud_rate = 9600;
parameter clk_freq  = 50_000_000;
logic [$clog2(clk_freq/baud_rate)-1:0] counter;
logic [7:0] temp;
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
        temp       <= '0;
        bitcounter <= '0;
        if (rx == 0) begin
           next_state  <= START;
         end
      end

      START:  begin
           counter <= counter + 1'b1;
        if (counter == ((clk_freq/baud_rate)/2))  begin
          next_state  <= BITS;
          counter     <= '0;
        end
      end

      BITS: begin
        counter <= counter + 1'b1;
        if (counter == (clk_freq/baud_rate))  begin
          bitcounter <= bitcounter + 1'b1;
          counter <= '0;
          temp    <= {rx,temp[7:1]};
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

  //  assign data = (state==STOP)? temp:0;//+проверка на stop state
assign done = (state == STOP);

always_ff @(posedge clk)
  if(rst)
    data <= '0;
  else if (done) 
    data <= temp;

endmodule
