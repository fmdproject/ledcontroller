

module brainBlock(
	input startFlag,
	input readFlag,
	input [3:0] dataIn,
	output reg led1,
	output reg led2
);

	reg [7:0] byteBuffer [31:0];
	reg [7:0] newByte;
	reg [7:0] bitCount;
	reg [7:0] byteCount;


	function automatic void clearBuffer32(ref reg [7:0] buff [31:0]);

		for(reg [7:0] i = 8'd0; i < 8'd32; i = i + 8'd1)
		begin
			buff[i] = 8'd0;
		end
	endfunction

	function automatic reg [7:0] indexOf32(reg [7:0] buff [31:0],string searchStr);

		if(searchStr.len() < 8'd33)
		begin
			reg [7:0] indexFound;
			reg [7:0] strLength = searchStr.len();
			reg [7:0] searchLimit = 8'd33 - strLength;
			reg [7:0] j;
			reg found;

			for(indexFound = 8'd0; indexFound < searchLimit; indexFound += 8'd1)
			begin
				if(buff[indexFound] == searchStr.getc(8'd0))
				begin
					found = 1'b1;

					for(j = 8'd0; j < strLength; j += 8'd1)
					begin
						if(buff[indexFound + j] != searchStr.getc(j))
						begin
							found = 1'b0;
							break;
						end
					end

					if(found)
					begin
						return indexFound;
					end
				end
			end

			return 8'd255;
		end
		else
		begin
			return 8'd255;
		end
	endfunction

	initial begin
		clearBuffer32(byteBuffer);
		bitCount = 8'd0;
		byteCount = 8'd0;
		newByte = 8'd0;
		led1 = 1'b1;
		led2 = 1'b1;
	end

	always @(posedge readFlag)
	begin

		newByte = newByte << 4;
		newByte = newByte + dataIn;
		
		bitCount += 8'd4;
		
		if(bitCount > 8'd4)
		begin
			bitCount = 8'd0;

			byteBuffer[byteCount] = newByte;
			
			byteCount += 8'd1;
			byteCount = (byteCount > 8'd31)? 8'd31 : byteCount;

			//start flag shuts down on the last byte 
			//signaling to the fpga that after getting the last byte
			//the interpretation of the hole buffer should begin
			if(~startFlag)
			begin

				if(indexOf32(byteBuffer,"turnOn(") == 8'd0)
				begin
					if(indexOf32(byteBuffer,"98") != 8'd255)
					begin
						led1 = 1'b0;
					end
					else if(indexOf32(byteBuffer,"87") != 8'd255)
					begin
						led2 = 1'b0;
					end
				end
				else if(indexOf32(byteBuffer,"turnOff(") == 8'd0)
				begin
					if(indexOf32(byteBuffer,"98") != 8'd255)
					begin
						led1 = 1'b1;
					end
					else if(indexOf32(byteBuffer,"87") != 8'd255)
					begin
						led2 = 1'b1;
					end
				end

				byteCount = 8'd0;
				clearBuffer32(byteBuffer);
			end
		end
	end
endmodule

