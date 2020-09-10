
//turning leds on and off using letter interpretation
// result : success
//
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



/*
//turning leds on and off using regs to hold states
// result : success
//
module brainBlock(
	input startFlag,
	input readFlag,
	input [3:0] dataIn,
	output wire led1,
	output wire led2
);
	reg [7:0] sum;
	
	// assigning leds
	assign led1 = ~sum[0];
	assign led2 = ~sum[1];

	initial begin
		// sum will hold our previous state
		sum = 8'd0;
	end
	
    always @(posedge readFlag)
    begin
		sum = sum + dataIn;
		sum = (sum>8'd3)? 8'd0 : sum;
	end
endmodule
*/
/*
	// turning leds on and off using just if cases 
	// result : success
	//
module brainBlock(
    input startFlag,
    input readFlag,
    input [3:0] dataIn,
    output reg led1,
    output reg led2);

    initial begin
		led1 = 1'b1;
		led2 = 1'b1;
    end

    always @(posedge readFlag)
    begin
		if(dataIn == 4'd0)
		begin
			led1 = 1'b1;
			led2 = 1'b1;
		end
		else if(dataIn == 4'd1)
		begin
			led1 = 1'b0;
			led2 = 1'b1;
		end
		else if(dataIn == 4'd2)
		begin
			led1 = 1'b1;
			led2 = 1'b0;
		end
		else if(dataIn > 4'd2)
		begin
			led1 = 1'b0;
			led2 = 1'b0;
		end
	end

endmodule
*/

/*
	//Turning leds on and off using string interpretation #1
	// result: failure
	//
module brainBlock(
input startFlag,
input readFlag,
input [3:0] dataIn,
output reg led1,
output reg led2);
	
function automatic void loadStr2Reg32(string str, ref reg [7:0] charArray [31:0]);
	
	reg [7:0] i;
	reg [7:0] length = str.len();

	for(i = 8'd0; i < 8'd32; i = i + 8'd1)
	begin
		if(i < length)
		begin
			charArray[i] = str.getc(i);
		end
		else 
		begin
			charArray[i] = 8'd0;
		end
	end
endfunction

function automatic reg [7:0] length32(reg [7:0] charArray [31:0]);

	reg [7:0] i;

	for(i = 8'd0; i < 8'd32; i = i + 8'd1)
	begin
		if(charArray[i] == 8'd0)
		begin
			return i;
		end
	end
	return 8'd32;
endfunction

function automatic reg [7:0] indexOf32(string searchStr, reg [7:0] charArray [31:0]);

	reg [7:0] i, j;
	reg [7:0] searchLength = searchStr.len();
	reg [7:0] searchLimit;
	reg [7:0] firstChar;
	reg match;

	if(searchLength > 8'd32)
	begin
		return 8'd255;
	end
	else
	begin
		searchLimit = 8'd32 - searchLength;
		firstChar = searchStr.getc(8'd0);
	end

	for(i = 8'd0; i < searchLimit; i = i + 8'd1)
	begin
		if(charArray[i] == firstChar)
		begin
			match = 1'b1;
			for(j = 8'd0; j < searchLength; j = j + 8'd1)
			begin
				if(charArray[i + j] != searchStr.getc(j))
				begin
					match = 1'b0;
					break;
				end
			end
			if(match)
			begin
				return i;
			end 
		end
	end

	return 8'd255;
endfunction

function automatic void substr32(reg [7:0] startIndex, reg [7:0] endIndex, reg [7:0] charArray [31:0], ref reg [7:0] outCharArray [31:0]);

	reg [7:0] i;
	reg [7:0] j = 8'd0;

	for(i = startIndex; i < endIndex; i = i + 8'd1)
	begin
		if(i > 8'd31 || j > 8'd31)
		begin
			break;
		end
		outCharArray[j] = charArray[i];
		j = j + 8'd1;
	end
endfunction

function automatic reg equal32(string searchStr, reg [7:0] charArray [31:0]);

	reg [7:0] i;
	reg [7:0] length = searchStr.len();

	if(length > 8'd31)
	begin
		return 1'b0;
	end

	for(i = 8'd0; i < length; i = i + 8'd1)
	begin
		if(searchStr.getc(i) != charArray[i])
		begin
			return 1'b0;
		end
	end
	return 1'b1;
endfunction
	
function automatic reg [3:0] cast2reg(input [3:0] wirePack);

    reg [3:0] val;

    if(wirePack[0])
    begin
        val = 4'b0001;
    end
    else
    begin
        val = 4'd0000;
    end
        
    if(wirePack[1])
    begin
        val = val | 4'b0010;
    end

    if(wirePack[2])
    begin
        val = val | 4'b0100;
    end

    if(wirePack[3])
    begin
        val = val | 4'b1000;
    end

    return val;
endfunction

reg bitCounter;
reg [7:0] byteHolder;
reg [7:0] textReceived [31:0];
reg [7:0] textHolder [31:0];
reg [7:0] fromHere;
reg [7:0] toHere;
reg [7:0] lengthReceived;

initial begin
    bitCounter = 1'b0;
    byteHolder = 8'd0;
	loadStr2Reg32("",textReceived);
	lengthReceived = 8'd0;
	led1 = 1'b1;
	led2 = 1'b1;
end

always @(posedge readFlag or negedge startFlag)
begin
	if(readFlag)
	begin
    	bitCounter = ~bitCounter;
		led2 = bitCounter;

    	if(bitCounter) begin
    	    byteHolder[7:4] = cast2reg(dataIn);
    	end
    	else begin
    	    byteHolder[3:0] = cast2reg(dataIn);
    	    textReceived[lengthReceived] = byteHolder;
			lengthReceived = lengthReceived + 8'd1;
    	end
	end
	else
	begin
		if(length32(textReceived) > 8'd0) begin

    		if(indexOf32("setLedOn(",textReceived) == 8'd0) begin

				fromHere = indexOf32("(",textReceived) + 8'd1;
				toHere = indexOf32(")",textReceived);

				substr32(fromHere,toHere,textReceived,textHolder);

				if(equal32("98",textHolder)) begin
					led1 = 1'b0;
				end
        		end
				else if(indexOf32("setLedOff(",textReceived) == 8'd0) begin

				fromHere = indexOf32("(",textReceived) + 8'd1;
				toHere = indexOf32(")",textReceived);

				substr32(fromHere,toHere,textReceived,textHolder);

				if(equal32("98",textHolder)) begin
					led1 = 1'b1;
				end
			end
		end
		loadStr2Reg32("",textReceived);
		lengthReceived = 8'd0;
		bitCounter = 1'b0;
	end
end

endmodule 
 */