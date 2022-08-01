module pong(input clk, output logic vga_h_sync, vga_v_sync, output logic [3:0] vga_Rarray, vga_Garray, vga_Barray);
	
	logic border, R, G, B, vga_R, vga_B, vga_G;
	logic inDisplayArea;
	logic [9:0] counterx;
	logic [8:0] countery;
	logic clk25khz;
	logic [24:0] count; //uselessfeed will remove on doublecheck
	
	pmcntr #(25) freqdiv(clk, 1'b0, 25'd25000000, count, clk25khz); //take 50Mhz to 25Mhz
	vgaSync vga(clk25khz, vga_h_sync, vga_v_sync, inDisplayArea);
	
	assign border = (counterx[9:3]==0) || (counterx[9:3]==79) || (countery[8:3]==0) || (countery[8:3]==59);
	assign R = border;
	assign G = border;
	assign B = border;

	always_ff @(posedge clk)
	begin
		vga_R <= R & inDisplayArea;
		vga_G <= G & inDisplayArea;
		vga_B <= B & inDisplayArea;
	end
	assign vga_Rarray[0] = vgaR;
	assign vga_Rarray[1] = vgaR;
	assign vga_Rarray[2] = vgaR;
	assign vga_Rarray[3] = vgaR;
	assign vga_Barray[0] = vgaB;
	assign vga_Barray[1] = vgaB;
	assign vga_Barray[2] = vgaB;
	assign vga_Barray[3] = vgaB;
	assign vga_Garray[0] = vgaG;
	assign vga_Garray[1] = vgaG;
	assign vga_Garray[2] = vgaG;
	assign vga_Garray[3] = vgaG;
	
	
endmodule

module vgaSync(input clk, output logic vga_h_sync, vga_v_sync, inDisplayArea);

	logic [9:0] counterx;
	logic [8:0] countery;
	logic vga_HS, vga_VS;
	XYSync vga(clk, counterx, countery, inDisplayArea);

	always_ff @(posedge clk) begin
		vga_HS <= (counterx[9:4]==0);
		vga_VS <= (countery==0);
	end
	assign vga_h_sync = ~vga_HS;
	assign vga_v_sync = ~vga_VS;
	
	
	
endmodule

module XYSync(input clk, output logic [9:0] counterX, output logic [8:0] counterY, output logic inDisplayArea);
	logic counterXmaxed;
	assign counterXmaxed = (counterX == 767);
	always_ff @ (posedge clk) begin
		if(counterXmaxed) begin
			counterX <= 0;
			counterY <= counterY + 9'd1;
			end
		else
			counterX <= counterX + 8'd1;
	end
	
	always_ff @(posedge clk)
		if(inDisplayArea==0)
			inDisplayArea <= (counterXmaxed) && (counterY<480);
		else
			inDisplayArea <= !(counterX==639);
	
endmodule

module pmcntr #(parameter siz=5) (input clk, reset, input [siz-1:0] count_max, output logic [siz-1:0] count, output logic clkout); 
	always_ff @ (posedge clk or posedge reset)  
		if (reset) begin   
			count <= {siz{1'b0}};   
			clkout <= 1'b0;   
		end  
		else if (count<count_max)   
			count <= count + {{(siz-1){1'b0}},1'b1}; 
		else begin   
			count <= {siz{1'b0}};   
			clkout <= ~clkout;  
		end 
endmodule 
