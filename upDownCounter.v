// Steven Xiong
// CSC 142
// Project#3

module upDownCounterFSM
(
	input [4:0] reset, preset,
	input clock,
	output reg [2:0] count
);

	parameter	A = 3'b000,
			B = 3'b001,
			C = 3'b010,
			D = 3'b011,
			E = 3'b100,
			F = 3'b101,
			G = 3'b110,
			H = 3'b111;

	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [2:0] parity_bits;
	reg [2:0] next_parity_bits;
	reg [2:0] parity_state;
	wire [2:0] new_current_state;
		
//	parityEncoder parity_mod(next_state, parity_bits);
	errorChecker error_mod (parity_state, current_state, new_current_state);

	initial begin
		current_state = A;
	end

	// Section 1 NEXT STATE GENERATOR (NSG) ////////////////////
	always@(clock)
	begin
	//	$display("NSG");
		casex(current_state)
		A: begin
			next_state = B; end
		B: begin
			next_state = C; end
		C: begin
			next_state = D; end
		D: begin
			next_state = E; end
		E: begin
			next_state = F; end
		F: begin
			next_state = G; end
		G: begin
			next_state = H; end
		H: begin
			next_state = A; end
		endcase
	end	

	//===================== END OF (NSG) ======================//

	// Section 2 OUTPUT GENERATOR (OG) /////////////////////////
	always@(new_current_state)
	begin
	//	$display("OG");
		current_state = new_current_state;
		if(current_state == A) begin
			count = A; end
		else if(current_state == B) begin
			count = B; end
		else if(current_state == C) begin
			count = C; end
		else if(current_state == D) begin
			count = D; end
		else if(current_state == E) begin
			count = E; end
		else if(current_state == F) begin
			count = F; end
		else if(current_state == G) begin
			count = G; end
		else if(current_state == H) begin
			count = H; end
		//current_state = new_current_state;
	end
	//==================== END OF (OG) =======================//

	// Section 3 Flip-Flop & Parity Encoder/////////////////////////////////////
	always@(posedge clock, negedge reset, negedge preset)	
	begin
		
		// PARITY ENCODER	//////////////////////////////////
		parity_bits[0] = next_state[0] ^ next_state[1];
		parity_bits[1] = next_state[0] ^ next_state[2];
		parity_bits[2] = next_state[1] ^ next_state[2];
		//========================= END OF PARITY===========//

		// FF, this is also where faults will happen
		// CODE TO CAUSE ERRORS IN THE BITS TO BE CORRECTED
		if(reset == 5'b11111) begin
			if(preset == 5'b00000) begin
				current_state <= 3'b000; end
		end
		else if(reset == 5'b00000) begin		// PRESET A SPECIFIC BIT TO '1'
			if(preset == 5'b00001) begin	// PRESET FF0 Q0 TO '1'
				$display("Preset q0");
				current_state <= next_state;
				parity_state <= parity_bits;
				current_state[0] <= 1;
			end
			else if(preset == 5'b00010) begin	// PRESET FF1 Q1 TO '1'
				$display("Preset q1");
				current_state <= next_state;
				parity_state <= parity_bits;
				current_state[1] <= 1;
			end
			else if(preset == 5'b00100) begin	// PRESET FF2 Q2 TO '1'
				$display("Preset q2");
				current_state <= next_state;
				parity_state <= parity_bits;
				current_state[2] <= 1;
			end
			else begin
				current_state <= next_state;
				parity_state <= parity_bits;
			end
		end
		else if(preset == 5'b00000) begin	// RESET A SPECIFIC BIT TO '0'
			if(reset == 5'b00001) begin	// RESE
				$display("Reset q0");
				current_state <= next_state;
				parity_state <= parity_bits;
				current_state[0] <= 0;
			end
			else if(reset == 5'b00010) begin	// RESET FF1 Q1 TO '0'
				$display("Reset q1");
				current_state <= next_state;
				parity_state <= parity_bits;
				current_state[1] <= 0;
			end
			else if(reset == 5'b00100) begin	// RESET FF2 Q2 TO '0'
				$display("Reset q2");
				current_state <= next_state;
				parity_state <= parity_bits;
				current_state[2] <= 0;
			end
		end
		//================ END OF FF======================//
		
	end
	
	//=================== END OF (FF) =======================//	
endmodule

module errorChecker
(
	input [2:0] parity_state, current_state,
	output [2:0] new_current_state
);
	wire [2:0] next_parity_bits;
	reg [2:0] error_num;	
	reg [2:0] error_num_copy;
	reg [5:0] whole_parity_copy;
	
	
	xor(next_parity_bits[0], current_state[0], current_state[1]);
	xor(next_parity_bits[1], current_state[0], current_state[2]);
	xor(next_parity_bits[2], current_state[1], current_state[2]);

	always@(error_num or parity_state or current_state) begin

		error_num[0] = parity_state[0] ^ next_parity_bits[0];
		error_num[1] = parity_state[1] ^ next_parity_bits[1];
		error_num[2] = parity_state[2] ^ next_parity_bits[2];
//		$display("ERROR current_State = %d error_num = %d(%b)", current_state, error_num, error_num);
//		$display("ERROR parity_state = %b, next_parity_bits = %b", parity_state, next_parity_bits);			
	
		if(error_num == 0) begin
			$display("NO ERROR");
			whole_parity_copy[2] = current_state[0];
			whole_parity_copy[4] = current_state[1];
			whole_parity_copy[5] = current_state[2];
		end
		else if(error_num > 0)begin
			$display("ERROR DETECTED");
			whole_parity_copy[0] = parity_state[0];
			whole_parity_copy[1] = parity_state[1];
			whole_parity_copy[2] = current_state[0];
			whole_parity_copy[3] = parity_state[2];
			whole_parity_copy[4] = current_state[1];
			whole_parity_copy[5] = current_state[2];
			
			error_num_copy = error_num;
			error_num_copy = error_num_copy - 1;

			$display("Error at bit %d\n[%b] ", error_num, whole_parity_copy);
		
			if(whole_parity_copy[error_num_copy] == 1)begin
				whole_parity_copy[error_num_copy] = 0;
			end
			else begin
				whole_parity_copy[error_num_copy] = 1;
			end	

			$display("Error corrected\n[%b] ", whole_parity_copy);
		end
	end

	or(new_current_state[0], 0, whole_parity_copy[2]);
	or(new_current_state[1], 0, whole_parity_copy[4]);
	or(new_current_state[2], 0, whole_parity_copy[5]);

endmodule


