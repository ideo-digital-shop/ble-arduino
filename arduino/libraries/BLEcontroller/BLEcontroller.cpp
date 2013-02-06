//---------- BLEcontroller.cpp ------------------------

/*
 //----------------------------------------------------
 Class for arduino to control the nBlue
 Bluetooth 4.0 Low Energy module
 
 Written by: Jimmy Chion | IDEO | 2012, 2013
 
 IMPORTANT: I/O ports on BT cannot exceed 3.6V. Nominal 3.3V
 MAKE SURE THE ARDUINO UART IS NOT OUTPUTTING MORE THAN 3.3V
 //----------------------------------------------------
 */

#include "Arduino.h"
#include "BLEcontroller.h"
#include <util/delay.h>
#include "QueueList.h"

#if (ARDUINO >= 100) //-- if it's Arduino 1.0 or greater
#include <SoftwareSerial.h>
#else
#include <NewSoftSerial.h>
#endif

//-- constructor, requires passing in a pointer to the Serial object being used
//-----------------------------------------------
#if (ARDUINO >= 100)
BLEcontroller::BLEcontroller(SoftwareSerial *ss) { //-- all new Arduinos should have this and be okay
#else
BLEcontroller::BLEcontroller(NewSoftSerial *ss) {
#endif
    softSerial = ss;
}

//-- initialization method. Needs to be separate from constructor
void BLEcontroller::init(long baudrate){
//-----------------------------------------------
    pinMode(BLE_RX_PIN, INPUT); 	//-- set the softwareSerial pins
  	pinMode(BLE_TX_PIN, OUTPUT);

    softSerial->begin(baudrate);      //-- arduino UART settings. default (9600, 8, N, 1)
    setVerbose(false);				//-- default to not printing everything out
    softSerial->flush(); 				//-- flushes tx buffer
    
    //-- this entire block forces modules out of BRSP, and checks whether it is connected
    softSerial->write(_CARRIAGE_RETURN);
    delay(200);
	softSerial->print("+++");			//-- forces out of BRSP mode. Does nothing if not in BRSP.
	softSerial->write(_CARRIAGE_RETURN);
	readCommandResponse(); 			//-- get rid of the "OK" response
	delay(30);
	bIsInDataMode = false;

   	isConnected(); 					//-- calling this accurately modifies bIsConnected
    
    connectAddr = NULL;
    currentState = START;
}

//-- Run function: Needs to be placed at the top of the loop() in the sketch
//-- It reads the incoming data, passes any events through the state machine
//-- and keeps track of what is being sent through tx
void BLEcontroller::run() {
//-----------------------------------------------
	readRx();
    stateMachine(checkForEvents());
    readTx();
    if ( softSerial->overflow() ) { //-- checks for the overflow flag. rx buffer is only 64 bytes 
        //if(bVerbose) Serial.println("ERROR: rx overflow");
    }
}

//-- Reads the incoming RX from both the module and any connected device
//-- If it's on data mode, then store this information to rxQueue
//-- Otherwise, put it in the rxQueue...
void BLEcontroller::readRx() {
//-----------------------------------------------
	char incomingByte;
	static bool isFirstReturn = true;
	if(softSerial->available() > 0) {
        incomingByte = softSerial->read();
        //Serial.println(softSerial->read());
        if(bIsInDataMode) {
			if (incomingByte == '\r'){ 						//-- when line is done, store in buffer
				rxQueue.push(rxLine);
				if(bVerbose) Serial.println("From the device: " + rxLine);
				rxLine = "";
			}
			else { 
				rxLine += incomingByte; 					//-- otherwise keep appending to line
			}
		}
		else { //-- in command mode, and the incoming info will be events and responses
			if (incomingByte == '\n' && isFirstReturn){ 	
				isFirstReturn = false;
			}
			else if (incomingByte == '\n' && !isFirstReturn) {
				isFirstReturn = true;						//-- when line is done, store in buffer
				//if(bVerbose) Serial.println("BLE says: " + rxLine);
				rxQueue.push(rxLine);
				rxLine = "";
			}
			else if (incomingByte != '\r') { 
				rxLine += incomingByte; 					//-- otherwise keep appending to line
			}
		}
    }
}

//-- Process the events that come in and change relevant variables
int BLEcontroller::checkForEvents() {
//-----------------------------------------------
	if(!rxQueue.isEmpty()){
		String line = rxQueue.pop();
		line.trim();
		if(line.startsWith("ERROR")) {
			// if (bVerbose) {
			// 	Serial.print("error ");
			// 	Serial.println(getCSVofString(line,1));				//-- maybe later, translate error code
			// }
			return ERROR_EVENT;
		}
		else if(line.equals("OK")) {
			//if (bVerbose) Serial.println("ok");
			return OK_EVENT;
		}
		else if(line.startsWith("CONNECT")) {
			bIsInDataMode = true; //-- this should not be here, but sometimes BRSP is not registered here
			bIsConnected = true;
			if (bVerbose) Serial.println("connect event");
			return CONNECT_EVENT;
		}
		else if(line.startsWith("DISCONNECT")) {
			if (bVerbose) Serial.println("disconnect event");
			bIsInDataMode = false;
			bIsConnected = false;
			connectAddr = NULL;
			return DISCONNECT_EVENT;
		}
		else if(line.startsWith("DISCOVERY")) {
			if(getCSVofString(line, 1) == "2") {
				if (bVerbose) {
					Serial.println("discovery event");
					Serial.print("Found address: ");
					Serial.println(getCSVofString(line, 2));
				}
				connectAddr = getCSVofString(line, 2);				//-- store the first address found
				return DISCOVERY_EVENT;
			}
			//-- check that the second csv corresponds to a value that is connectable (2 or 3)
		}
		else if(line.startsWith("BRSP")) {
			if (bVerbose) Serial.println("brsp event");
			//-- check that the third csv is (1 = data mode, 2 = RC mode, 5 = BRSP already initiated)
			bIsInDataMode = true;
			return BRSP_EVENT;
		}
		else if(line.startsWith("DONE")) {
			if(bVerbose) Serial.println("done event");
			return DONE_EVENT;
		}
		else {
			return NO_EVENT;
		}
	}
}

void BLEcontroller::readTx(){
//-----------------------------------------------
	if(!txQueue.isEmpty()) {
		String line = txQueue.peek();
		if(line == "+++") {
			txQueue.pop();
			if(bIsInDataMode) { 
				bIsInDataMode = false;
				if(bVerbose) Serial.println("switched to command mode");
			}
		}
		else if(line == "ATMD") {
			txQueue.pop();
			bIsInDataMode = true;
		}
		else {
			txQueue.pop();
			if(bIsInDataMode && bVerbose) Serial.println("Sent to connected device: " + line);
		}
	}
}

void BLEcontroller::stateMachine(int event){
//-----------------------------------------------
	int nextState = currentState;
	if(currentState == DISCOVERING) {
		if(event == DISCOVERY_EVENT) {
			nextState = CONNECTING;
			String cmd = "ATDMLE,";
			cmd += connectAddr;
			sendCommand(cmd);
		}
	}
	if(currentState == CONNECTING) { //-- sometimes it won't see this
		if(event == BRSP_EVENT) {
			if(bVerbose) Serial.println("switched to data mode");
		}
		//-- check for failure
	}
	currentState = nextState;
}

String BLEcontroller::getCSVofString(String str, int index) {
//-----------------------------------------------
	int currIndex = 0;
	int pos;
	String substring;
	while ( (pos = str.indexOf(',') ) >= 0) {//-- parse it out of the commas  
	    substring = str.substring(0,pos);  
        if (currIndex == index) return substring;
        currIndex++;
        str = str.substring(pos+1);  
    }
    if (currIndex == index) return str;
    else return NULL;
}

void BLEcontroller::initConnection() {
//-----------------------------------------------
	if ( !bIsConnected ) {
		sendCommand("ATDILE");
		currentState = DISCOVERING;
	} else {
		if(bVerbose) Serial.println("already connected");
	}
}

//-----------------------------------------------
bool BLEcontroller::isConnected() {
	//-- ATSLE -> <(0=Not Idle, 1=idle, 2=testing), (0=advertising, 1=advertising), (0=not discovering, discovering)
	//-- (0=not connecting, 1=connecting), (0=not connected, >0, connectied number equal to n active connections)>

	sendCommand("ATSLE?");
    readCommandResponse();
   	if(getCSVofString(parsedCommandResponses[1], 4).toInt() > 0) {
   		bIsConnected = true;
   	} else {
   		bIsConnected = false;
   	}
   	return bIsConnected;
}

//-- returns whether the module is currently advertising
//-----------------------------------------------
bool BLEcontroller::isAdvertising() {
	//-- ATSLE -> <(0=Not Idle, 1=idle, 2=testing), (0=advertising, 1=advertising), (0=not discovering, discovering)
	//-- (0=not connecting, 1=connecting), (0=not connected, >0, connectied number equal to n active connections)>

	sendCommand("ATSLE?");
    readCommandResponse();
   	if(getCSVofString(parsedCommandResponses[1], 1).toInt() == 1)
   		return true;
   	else
   		return false;
}

//-- initiates advertising if by default, it doesnt
void BLEcontroller::startAdvertising() {
//-----------------------------------------------
	sendCommand("ATDSLE");
}

//-- disconnect from connected device
void BLEcontroller::disconnect() {
//-----------------------------------------------
	if( bIsConnected ) {
		sendCommand("ATDH");
	} else {
		if(bVerbose) Serial.println("nothing to disconnect");
	}
}

//-----------------------------------------------
void BLEcontroller::unpair() {
	String cmd = "ATUPLE,";
	cmd += connectAddr;
	sendCommand(cmd);
}


//-- sends a command from the Arduino to the Bluetooth module
void BLEcontroller::sendCommand(String cmd){
//-----------------------------------------------
    //bool wasInDataMode = false;
    if(bIsInDataMode) {
	    softSerial->print("+++");
	    softSerial->write(_CARRIAGE_RETURN);
	    bIsInDataMode = false;
	    readCommandResponse(); //-- get rid of the "OK" response
	    delay(20); //-- blocking but somewhat necessary
	 	//   wasInDataMode = true;
	}

    softSerial->print(cmd); //-- send command
    softSerial->write(_CARRIAGE_RETURN);

    // delay(20); //-- blocking

 	//    if(wasInDataMode){
	//     softSerial->print("ATMD"); //-- default back to sending data
	//     softSerial->write(_CARRIAGE_RETURN); 
	// }
    // --delay needed at baud rate of 19200
    //delay(20); //-- blocking
    
    if(bVerbose) {Serial.print("Sent: "); Serial.println(cmd);}
}


// //-----------------------------------------------
// void BLEcontroller::clearRxQueue() {
// 	while(!rxQueue.isEmpty()) rxQueue.pop();
// }

//-----------------------------------------------
bool BLEcontroller::isRxQueueEmpty() {
	return rxQueue.isEmpty();
}

//-----------------------------------------------
int BLEcontroller::rxQueueAvailable() {
	return rxQueue.count();
}

//-----------------------------------------------
bool BLEcontroller::isInDataMode() {
	return bIsInDataMode;
}

//-----------------------------------------------
void BLEcontroller::setVerbose(bool b) {
	bVerbose = b;
}


//-- places character into the TX line, which will go to module or connected device
void BLEcontroller::send(char msg) {
//-----------------------------------------------
	softSerial->write(msg);
	if(msg == '\r') {
		txQueue.push(txLine);
		txLine = "";
	} else {
		txLine += msg;
	}
}

//-- gets the name of the BT module connected to arduino
String BLEcontroller::getName() {
//------------------------------------------------------------------------
    sendCommand("ATSN?");
    readCommandResponse();
    return parsedCommandResponses[1];
}


//-- returns the signal strength [-127, +20] of connection handle 0 (first conn).
//-- returns NULL if there's no connection.
int BLEcontroller::getSignalStrength() {
//------------------------------------------------------------------------
    if (bIsConnected) {
	    sendCommand("ATRSSI?,0");
	    readCommandResponse();
	    String str = parsedCommandResponses[1];
	    return str.toInt();
	} else {
		if (bVerbose) Serial.println("no connection to get signal strength");
		return NULL; 									//-- means there's no connection
	}
}

//-- get BT device address (the module connected to arduino)
String BLEcontroller::getAddressOfModule(){
//------------------------------------------------------------------------
    sendCommand("ATA?");
    readCommandResponse();
    return parsedCommandResponses[1];
}

// -- reads the response after an AT command is sent
// -- responses come in as "\r\n<RESPONSE>\r\n
// --                       \r\n<MORERESPONSE>\r\n"
// -- parses the responses from that and stores it in a String array
// -- [<response1>, <response2>, <response3>,...]
void BLEcontroller::readCommandResponse(){
//-------------------------------------------------------------------
    int i = 0; 											//-- keep track of where in the string
	int j = 0; 											//-- how many strings there are
    clearResponseBuffer();
    /*--------*/
    delay(20); //-- ugh, sorry to use this. Can't figure out how to not
    /*--------*/
    while (softSerial->available() > 0) {
        char incomingByte = softSerial->read();
        if (incomingByte == '\r') {
            incomingByte = softSerial->read();
        if (incomingByte == '\n') {						//-- then this is the start of information
            incomingByte = softSerial->read();
            while(incomingByte != '\r') {
                responseBuffer[i] = incomingByte;       //-- append incomingByte to buffer
                i++;
                incomingByte = softSerial->read();
            } 											//-- but still haven't read the \n
            softSerial->read(); 							//-- now we have
            String response = String(responseBuffer);
            response.trim();
            parsedCommandResponses[j] = response; 		//-- store each response as a String
            i = 0;
            j++;
            clearResponseBuffer(); 						// -- clear buffer
            }
        }  												//-- and if there are still bytes to read, repeat
    }   
    parsedCommandResponsesLength = j;					//-- store the length of the array
}

//-- helper function to clear the response buffer of chars for incoming responses
void BLEcontroller::clearResponseBuffer(){
//-----------------------------------------------------------------------
    for(int i = 0; i < MAX_RESPONSE_SIZE; i++) {
        responseBuffer[i] = NULL; 
    }
}

//-- resets the BT module
void BLEcontroller::reset(){
//------------------------------------------------------------------------
    sendCommand("ATRST");
}






