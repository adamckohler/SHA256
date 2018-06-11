module CSA(x_in, y_in, z_in, s_out, c_out);
	
	input wire [31:0] x_in, 
	input wire [31:0] y_in, 
	input wire [31:0] z_in,
	
	output wire [31:0] s_out,
	output wire [31:0] c_out
	);
            
	for (i=0; i < 32; i=i +1) begin
		fulladder inst (//Inputs to the adder
				.a(x_in[i]), 
				.b(y_in[i]), 
				.c(z_in[i]), 
				
				//Outputs from the adder
				.sum(s_out[i]), 
				.carry(c_out[i])
				);
	end	
endmodule
