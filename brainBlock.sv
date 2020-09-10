

module brainBlock(
	input startFlag,
	input readFlag,
	input [3:0] dataIn,
	output reg led1,
	output reg led2
);

	reg [7:0] charRec;
	reg [7:0] i;

	task automatic interpret(ref reg [7:0] newChar,
							 ref reg ledOut1,
							 ref reg ledOut2);

		string letters = "ABC";

		if(newChar == letters.getc(0))
		begin
			ledOut1 = 1'b0;
			ledOut2 = 1'b1;
		end
		else if(newChar == letters.getc(1))
		begin
			ledOut1 = 1'b1;
			ledOut2 = 1'b0;
		end
		else
		begin
			ledOut1 = 1'b1;
			ledOut2 = 1'b1;
		end
	endtask

	initial begin
		charRec = 8'd0;
		led1 = 1'b1;
		led2 = 1'b1;
	end

	always @(posedge readFlag)
	begin
		charRec = charRec<<4;
		charRec = charRec + dataIn;

		i = i + 8'd1;

		if(i > 8'd1)
		begin
			interpret(charRec,led1,led2);
			i = 8'd0;
			charRec = 8'd0;
		end
	end
endmodule

