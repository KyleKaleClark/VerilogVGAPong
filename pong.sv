module pong(input clk, output logic vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B);

	logic inDisplayArea;
	logic [9:0] counterx;
	logic [8:0] countery;
	logic clk25khz;
	logic [24:0] count; //uselessfeed will remove on doublecheck
	
	pmcntr #(25)(clk, 1'b0, 25'd25000000, count, clk25khz); //take 50Mhz to 25Mhz
	vgaSync vga(clk25khz, vga_h_sync, vga_v_sync; inDisplayArea, counterx, countery);
	
	logic border = (counterx[9:3]==0) || (counterx[9:3]==79) || (countery[8:3]==0) || (countery[8:3]==59);
	logic R = border;
	logic G = border;
	logic B = border;

	always_ff @(posedge clk)
	begin
		vga_R <= R & inDisplayArea;
		vga_G <= G & inDisplayArea;
		vga_B <= B & inDisplayArea;
	end
endmodule

module vgaSync(input clk, output logic vga_h_sync, vga_v_sync);

	logic [9:0] counterx;
	logic [8:0] countery
	logic vga_HS, vga_VS;
	XYSync vga(clk, counterx, countery);

	always_ff @(clk) begin
		vga_HS <= (counterx[9:4]==0);
		vga_VS <= (countery==0);
	end
	assign vga_h_sync = ~vga_HS;
	assign vga_v_sync = ~vga_VS;
endmodule

module XYSync(input clk, output logic [9:0] counterX, output logic [8:0] counterY);
	logic counterXmaxed = (counterX == 767);
	always_ff @ (posedge clk) begin
		if(counterXmaxed)
			counterX <= 0;
			counterY <= counterY + 1;
		else
			counterX <= counterX + 1;
	end
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




















