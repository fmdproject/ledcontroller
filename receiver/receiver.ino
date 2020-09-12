
byte bMask  = B00111111;
byte bRead  = B00110000;
byte bClear = B00000000;
byte bOn    = B00100000;

String textReceived = "";
byte fromHere = 0;
byte toHere = 0;
byte number = 0;
byte newByte;
int lengthM1;

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

    if(textReceived.indexOf("turn") == 0)
    {
        byte newByteArray[textReceived.length() + 1];
        textReceived.getBytes(newByteArray,textReceived.length() + 1);

        lengthM1 = textReceived.length() - 1;

        for(int i = 0; i < lengthM1; i++)
        {
            PORTB = bOn;
            
            newByte = bOn | (newByteArray[i] >> 4);

            //this step is sets the values of half of the byte
            PORTB = newByte;

            //this step triggers the processing within the fpga
            PORTB = newByte | bRead;

            PORTB = bOn;

            newByte = bOn | (newByteArray[i] & B00001111);

            //this step is sets the values of the other half of the byte
            PORTB = newByte;
            
            PORTB = newByte | bRead;
        }
        
        PORTB = bOn;
            
        newByte = bOn | (newByteArray[lengthM1] >> 4);

        //this step is sets the values of half of the byte
        PORTB = newByte;

        //this step triggers the processing within the fpga
        PORTB = newByte | bRead;

        PORTB = bClear;

        newByte = newByteArray[lengthM1] & B00001111;

        //this step is sets the values of the other half of the byte
        PORTB = newByte;
            
        PORTB = newByte | bRead;

        PORTB = bClear;

        Serial.println("OK");
    }
    else
    {
        Serial.println("Command doesn't match any internal function");
    }
    textReceived = "";
}

