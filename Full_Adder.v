module fulladder(
		input wire a,
		input wire b,
		input wire c,
	
		output wire sum,
		output wire carry
		);

	assign sum = a ^ b ^ c;
	assign carry = (a & b) | (c & b) | (a & c);

endmodule
