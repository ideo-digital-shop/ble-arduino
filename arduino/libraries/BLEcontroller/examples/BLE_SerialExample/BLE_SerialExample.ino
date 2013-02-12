  /*
   Written by: Jimmy Chion | IDEO | 2012
   dependencies: SoftwareSerial (included in Arduino 1.0+)
   
   Use this code to talk to the BT module in command mode
   via the Serial Monitor (Tools -> Serial Monitor).
   
   This requies that the module's UART settings have been
   changed to 19200. AT Command: ATSUART,4,0,0,1. You can
   pair the phone with the device and go into command mode
   to change uart settings.
  
   After loading this program, open Serial Monitor, 
   change the baudrate in the lower right to 9600, Newline
   and then feel free to send whatever AT commands
   you'd like. For example typing "AT" and sending it
   should get a response of "OK"
   
   *This program can run independent of the BLEcontroller class*
   
   If the module is paired with the device, then you will see
   what you type into the Serial Monitor appear on the iPhone
   in the nBlue Sample Client app.
   
   Likewise, anything you type in the app, you should see in
   the Serial Monitor
   
   TROUBLESHOOTING
   - if it's paired but not trasnmitting characters, try power
   cycling the arduino.
   - for some reason, it only works with Serial at 9600
   */


  #include <SoftwareSerial.h>
     
  #define RX 7                           //-- software serial pin for rx
  #define TX 6                           //-- software serial pin for tx
  #define SERIAL_BAUDRATE 9600           //-- baudrate between computer <-> arduino
  #define SOFTWARE_SERIAL_BAUDRATE 19200 //-- baudrate between arduino <-> BLE module
  
  SoftwareSerial mySerial(RX, TX);       //-- non inverted
  
  
  void setup()  
  {
    pinMode(RX, INPUT);
    pinMode(TX, OUTPUT);
  
    //-- data rate for the Serial port (computer <-> arduino)
    Serial.begin(SERIAL_BAUDRATE);
    Serial.print("-arduino ready- set baud rate to: ");
    Serial.print(SERIAL_BAUDRATE);
    Serial.print(" and line ending to Carriage Return");
  
    //-- set the data rate for the SoftwareSerial port
    mySerial.begin(SOFTWARE_SERIAL_BAUDRATE);
  }
  
  void loop() { //-- run over and over
    //-- take input coming into the arduino and print it through my computer
    if (mySerial.available() > 0){
      Serial.write(mySerial.read());
    }
    
    //-- take input coming fromt my computer and send it through bluetooth
    if (Serial.available() > 0){
      mySerial.write(Serial.read());
    }
  }
