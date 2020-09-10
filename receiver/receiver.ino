
byte bMask  = B00111111;
byte bRead  = B00110000;
byte bClear = B00000000;

String textReceived = "";
byte fromHere = 0;
byte toHere = 0;
byte number = 0;
byte newByte;

void setup()
{
    Serial.begin(115200);
    DDRB = bMask;
    PORTB = bClear;
}

void loop()
{
    if(Serial.available())
    {
        while(Serial.available())
        {
            textReceived += Serial.readString();
        }
        interpret();
    }
}

void interpret()
{
    Serial.println(textReceived);

    if(textReceived.indexOf("setB(") == 0)
    {
        fromHere = textReceived.indexOf("(") + 1;
        toHere = textReceived.indexOf(")");
        number = textReceived.substring(fromHere,toHere).toInt();
        number = (number > 15)? 15 : number;
        PORTB = bClear;

        //this step is needed to set the values
        //for the fpga to read them correctly
        PORTB = number;
        
        //this step triggers the processing within the fpga
        PORTB = number | bRead;
        Serial.println("OK");
    }
    else if(textReceived.indexOf("send(") == 0)
    {
        fromHere = textReceived.indexOf("(") + 1;
        toHere = textReceived.indexOf(")");
        textReceived = textReceived.substring(fromHere,toHere);

        byte newByteArray[textReceived.length() + 1];
        textReceived.getBytes(newByteArray,textReceived.length() + 1);

        for(int i = 0; i < textReceived.length(); i++)
        {
            PORTB = bClear;
            
            newByte = newByteArray[i] >> 4;

            //this step is sets the values of half of the byte
            PORTB = newByte;

            //this step triggers the processing within the fpga
            PORTB = newByte | bRead;

            PORTB = bClear;

            newByte = newByteArray[i] & B00001111;

            //this step is sets the values of the other half of the byte
            PORTB = newByte;
            
            PORTB = newByte | bRead;
        }
        Serial.println("OK");
    }
    else
    {
        Serial.println("Command doesn't match any internal function");
    }
    textReceived = "";
}

