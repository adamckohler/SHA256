module fulladder(a, b, c, sum, carry);
	input a,b,c;
	output sum,carry;

	assign sum = a ^ b ^ cin;
	assign carry = (a & b) | (cin & b) | (a & cin);

endmodule
