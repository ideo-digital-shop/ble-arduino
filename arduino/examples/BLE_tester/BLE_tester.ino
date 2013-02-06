/*
 Written by: Jimmy Chion | IDEO | 2012
 
 example shows getting information from the module on various aspects
 
 Usage:
 After loading the program, (connect and pair the BLE module)
 then open Serial Monitor at 9600
 */

#include "BLEcontroller.h"
#include <SoftwareSerial.h>
#include <QueueList.h>

const long SERIAL_BAUDRATE = 9600;           //-- baudrate between computer <-> arduino (pins 0,1)
const long SOFTWARE_SERIAL_BAUDRATE = 19200; //-- baudrate between arduino <-> BLE module (pins 6,7)

#if (ARDUINO >= 100) //-- Arduino 1.0 or greater
  SoftwareSerial ss = SoftwareSerial(BLE_RX_PIN, BLE_TX_PIN); //-- serial connection to BLE module
#else
  NewSoftSerial ss = NewSoftSerial(BLE_RX_PIN, BLE_TX_PIN);
#endif

BLEcontroller myBLE(&ss); //-- module controller instance



//-------------------------------------------------
void setup() {  
  Serial.begin(SERIAL_BAUDRATE);

  myBLE.init(SOFTWARE_SERIAL_BAUDRATE); //-- about the max baud rate via softwareSerial on 8MHz processor
  myBLE.setVerbose(true);

  Serial.println("-arduino ready- set baud rate to " + String(SERIAL_BAUDRATE) + " and line ending to Carriage Return");
  Serial.println("\n Type '1' to connect to closest device. '2' to disconnect. and '3' to see information about device.");
}


//-------------------------------------------------
void loop() {
  myBLE.run();

  if (Serial.available() > 0){
    char msg = Serial.read();
    
    if(msg == '1') {
      myBLE.initConnection();
    }
    else if(msg == '2') {
      myBLE.disconnect();
    }
    else if(msg == '3') {
      Serial.println("Module name: " + myBLE.getName());
      Serial.println("Module address: " + myBLE.getAddressOfModule());
      Serial.println("Signal strength of connection: " + String(myBLE.getSignalStrength() ) );
      if( myBLE.isConnected() ) {
        Serial.println("Module is connected.");
      } else {
        Serial.println("Module is not connected.");
      }
      if ( myBLE.isAdvertising() ) {
        Serial.println("Module is advertising.");
      } else {
        Serial.println("Module is not advertising");
      }
    }
    else {
      myBLE.send(msg);
    }
  }
}

