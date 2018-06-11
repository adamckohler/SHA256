
module sha256_update_variables (
		
			           input  wire init_round, 
                 input wire partial_rounds, 
					   input wire init_digest, 
					   input wire update_digest, 
					   input wire first_block, 

                       input wire [31:0] w_data,
                       input wire [31:0] k_out,
					  
					   input wire [31:0] a_reg,
             input wire [31:0] b_reg, 
					   input wire [31:0] c_reg, 
					   input wire [31:0] d_reg, 
					   input wire [31:0] e_reg, 
					   input wire [31:0] f_reg, 
					   input wire [31:0] g_reg,
             input wire [31:0] h_reg,
             input wire [31:0] H0_0, 
					   input wire [31:0] H0_1,
             input wire [31:0] H0_2, 
					   input wire [31:0] H0_3, 
					   input wire [31:0] H0_4, 
					   input wire [31:0] H0_5, 
					   input wire [31:0] H0_6, 
					   input wire [31:0] H0_7, 
					   input wire [31:0] H0_reg, 
					   input wire [31:0] H1_reg, 
					   input wire [31:0] H2_reg, 
					   input wire [31:0] H3_reg, 
					   input wire [31:0] H4_reg, 
					   input wire [31:0] H5_reg, 
					   input wire [31:0] H6_reg, 
					   input wire [31:0] H7_reg,
                       
                        output  reg[31:0]a_new,
                        output  reg[31:0] b_new,
                        output  reg[31:0]c_new, 
                        output  reg[31:0]d_new, 
                        output  reg[31:0]e_new, 
                        output  reg[31:0]f_new, 
                        output  reg[31:0]g_new, 
                        output  reg[31:0]h_new, 
                        
                        output  reg[31:0]H0_new, 
                        output  reg[31:0]H1_new, 
                        output  reg[31:0]H2_new, 
                        output  reg[31:0]H3_new, 
                        output  reg[31:0]H4_new, 
                        output  reg[31:0]H5_new, 
                        output  reg[31:0]H6_new, 
                        output  reg[31:0]H7_new, 
                        output  reg update_AH, 
                        output  reg update_H
                        );


/*****************************************/


// Intermediate registers.

reg [31 : 0] sum_E;
reg [31 : 0] CH_EFG;
reg [31 : 0] sum_A;
reg [31 : 0] MAJ_ABC;
	
reg [31 : 0] M1;
reg [31 : 0] M2;	
	
reg [31 : 0] Epsilon;
reg [31 : 0] L;
reg [31 : 0] Alpha;

//reg [31 : 0] T1;
//reg [31 : 0] T2;

/*****************************************/



//  Digest update logic 

always @*   
begin 
  
    // initializing H register values

      H0_new = 32'h0;
      H1_new = 32'h0;
      H2_new = 32'h0;
      H3_new = 32'h0;
      H4_new = 32'h0;
      H5_new = 32'h0;
      H6_new = 32'h0;
      H7_new = 32'h0;
      update_H = 0;                             

    
    case({init_digest,update_digest})
      
      2'b10:                                         // When the block = 1 , initial_round =  1, partial rounds = 0.
      begin     
                                       // The H registers are loaded with initial hash values          
           if(first_block)
            begin
                update_H = 1;                  
                H0_new = H0_0;
                H1_new = H0_1;
                H2_new = H0_2;
                H3_new = H0_3;
                H4_new = H0_4;
                H5_new = H0_5;
                H6_new = H0_6;
                H7_new = H0_7;          
            end
          
           else
           begin                                // When the block < N, initial_round =  1, partial rounds = 0 ( 1 < rounds < 64).
                                               // The H registers are loaded with previous hash values          
                update_H = 1;                  
                H0_new = H0_reg;
                H1_new = H1_reg;
                H2_new = H2_reg;
                H3_new = H3_reg;
                H4_new = H4_reg;
                H5_new = H5_reg;
                H6_new = H6_reg;
                H7_new = H7_reg;     
                     
            end
      end                                   // When the initial_round =  0, partial rounds = 1   ( 1 < rounds < 64)
      
      2'b01:                                    // The H registers are loaded with intermediate hash register values after computation.
      begin
                              
            H0_new = H0_reg + a_reg;
            H1_new = H1_reg + b_reg;
            H2_new = H2_reg + c_reg;
            H3_new = H3_reg + d_reg;
            H4_new = H4_reg + e_reg;
            H5_new = H5_reg + f_reg;
            H6_new = H6_reg + g_reg;
            H7_new = H7_reg + h_reg;     
            update_H = 1;                             
      end

      endcase 
end 

inout wire [31:0] sum_out;
inout wire [31:0] carry_out;
inout wire [31:0] sum_temp;
inout wire [31:0] carry_temp;
	
/*******************************************************************
  
  // M1_logic and M2_logic
  
  *******************************************************************/
  
  always @*     
    begin : m1_logic
	    
	    CSA inst_m2(w_data, k_out, h_reg, sum_out, carry_out);
	    
	    M2 = sum_out + carry_out;
	    sum_temp = sum_out;
	    carry_temp = carry_out;
	    
	    
	    CSA inst_m1(d_reg, sum_temp, carry_temp, sum_out, Carry_out);
	    
	    M1 = sum_out + carry_out;
	    
    end // m_logic

/*******************************************************************
  
  // Epsilon_logic and L_logic
  
  *******************************************************************/
  
  always @*     
    begin : Epsilon_logic
      

      sum_E = {e_reg[5  : 0], e_reg[31 :  6]} ^
             {e_reg[10 : 0], e_reg[31 : 11]} ^
             {e_reg[24 : 0], e_reg[31 : 25]};

      CH_EFG = (e_reg & f_reg) ^ ((~e_reg) & g_reg);

	    CSA inst_epsilon(sum_E, CH_EFG, M1, sum_out, carry_out);
	    
	    Epsilon = sum_out + carry_out
	    
	    CSA inst_L(sum_E, CH_EFG, M2, sum_out, carry_out);
	    
	    L = sum_out + carry_out
	    
    end // l_logic

/*******************************************************************
  
  // Alpha_logic
  
  *******************************************************************/
  
  always @*     
    begin : Alpha_logic
      

      sum_A = {a_reg[1  : 0], a_reg[31 :  2]} ^
             {a_reg[12 : 0], a_reg[31 : 13]} ^
             {a_reg[21 : 0], a_reg[31 : 22]};

      MAJ_ABC = (a_reg & b_reg) ^ (a_reg & c_reg) ^ (b_reg & c_reg);

	    CSA inst_alpha(sum_A, MAJ_ABC, L, sum_out, carry_out);
	    
	    Alpha = sum_out + carry_out
	    
    end // l_logic

/******************************************************************************/

// A-H update logic

always @*  
begin
  
  // initializing A-H register values
      a_new  = 32'h0;
      b_new  = 32'h0;
      c_new  = 32'h0;
      d_new  = 32'h0;
      e_new  = 32'h0;
      f_new  = 32'h0;
      g_new  = 32'h0;
      h_new  = 32'h0;
      update_AH = 0;

    case({init_round,partial_rounds})   
      
    2'b10:                                        // When the round = 1 , initial_round =  1, partial rounds = 0
        begin
          update_AH = 1;
          if (first_block)                        // If its the first block, then update A-H registers with initial hash values.
            begin
                a_new  = H0_0;
                b_new  = H0_1;
                c_new  = H0_2;
                d_new  = H0_3;
                e_new  = H0_4;
                f_new  = H0_5;
                g_new  = H0_6;
                h_new  = H0_7;
            end
          else                                    // If round = 64 and block =< N, then update A-H registers with intermediate H register values
            begin 
                a_new  = H0_reg;
                b_new  = H1_reg;
                c_new  = H2_reg;
                d_new  = H3_reg;
                e_new  = H4_reg;
                f_new  = H5_reg;
                g_new  = H6_reg;
                h_new  = H7_reg;
            end
        end

     2'b01:                                     // When the 1 < round < 63 , initial_round =  0, partial rounds = 1                 
        begin
          a_new  = Alpha;
          b_new  = a_reg;
          c_new  = b_reg;
          d_new  = c_reg;
          e_new  = Epsilon;
          f_new  = e_reg;
          g_new  = f_reg;
          h_new  = g_reg;
          update_AH = 1;                        // Flag to update A-H registers 
        end
		
    endcase
end


endmodule
