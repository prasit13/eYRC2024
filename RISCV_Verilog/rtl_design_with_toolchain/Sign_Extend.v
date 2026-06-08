module Sign_Extend (input  [31:7] In,
			input  [2:0] ImmSrc, 
			output reg [31:0] Imm_Ext);


	always @ (*)
		case(ImmSrc)
		// I−type
		3'b000: Imm_Ext = {{20{In[31]}}, In[31:20]};
		
		// S−type (stores)
		3'b001: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]};
		
		// B−type (branches)
		3'b010: Imm_Ext = {{20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0};
		
		// J−type (jal)
		3'b011: Imm_Ext = {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0};
		
		// U-type
		3'b100: Imm_Ext = {In[31:12], 12'b0};
		
		default: Imm_Ext = 32'bx; // undefined
	endcase
endmodule