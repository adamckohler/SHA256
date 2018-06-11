module CSA(x_in, y_in, z_in, s, c);
	input reg [31:0] x_in,y_in,z_in;
	output reg [31:0] s,c;
            
	for (i=0; i < 32; i=i +1) begin
		fulladder inst (x_in[i], y_in[i], z_in[i], s[i], c[i]);
	end	
	
endmodule
