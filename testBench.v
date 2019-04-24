// Steven Xiong
// CSC142
// project#3

`include "upDownCounter.v"

module testBench();
	
	reg [4:0] reset, preset;
	reg clock;
	wire [2:0] count;
	
	upDownCounterFSM upDown_mod(reset, preset, clock, count);
	
	always@(count) begin
		$display("[COUNT] = %d(%b)\n", count, count);
	end


	initial begin
		$display("\n     Steven Xiong     \n");
		clock = 0;reset = 5'b00000;
		#5 clock = 1;	// count == 0
		#5 clock = 0;
//		$display("upcoming ERROR\n");
		#5 clock = 1; reset = 5'b00001; preset = 5'b00000;
		#5 clock = 0; reset = 5'b00000;
		
		#5 clock = 1; preset = 5'b00010;
		#5 clock = 0; preset = 5'b00000;
		
		#5 clock = 1;
		#5 clock = 0;
		
		#5 clock = 1; reset = 5'b00100; 
		#5 clock = 0; reset = 5'b00000;

		#5 clock = 1;
		#5 clock = 0;
		
	end

endmodule
