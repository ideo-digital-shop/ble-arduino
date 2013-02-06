//------- BLEcontroller.h----------------------------
/*
  nBlue library for nBlue Bluetooth 4.0 Low-Energy
  Bluetooth module. Designed to abstract the AT.s Command 
  layer away and give the Arduino some funcitons to use
  to send, receive, and config the BLE module

  Written by: Jimmy Chion | IDEO | 2012
 */
//----------------------------------------------------
#pragma once

#include "Arduino.h"
#include "BLEcontroller.h"
#include <QueueList.h>


#if (ARDUINO >= 100) //-- if it's Arduino 1.0 or greater
    #include "Arduino.h"
    #include <SoftwareSerial.h>
#else
    #include "WProgram.h"
    #include <NewSoftSerial.h>
#endif


//-- CONSTANTS
#define _CARRIAGE_RETURN 0x0D
const int BLE_RX_PIN        =  7; //-- specific to Sparkfun bluetooth low-energy shield
const int BLE_TX_PIN        =  6; //-- specific to Sparkfun bluetooth low-energy shield

const int MAX_RESPONSE_SIZE = 30; //-- rx buffer is 64 bytes
const int MAX_N_RESPONSES   = 10;

const int N_EVENTS          = 13;

//-- EVENTS
enum EVENT_t {
    OK_EVENT,
    ERROR_EVENT,
    RESET_EVENT,
    DONE_EVENT,
    CONNECT_EVENT,
    DISCONNECT_EVENT,
    DISCOVERY_EVENT,
    PAIR_REQ_EVENT,
    PAIRED_EVENT,
    PAIR_FAIL_EVENT,
    PASSKEY_REQ,
    PASSKEY_DISPLAY,
    BRSP_EVENT,
    NO_EVENT
};

//-- states for connecting
enum STATE_t {
    START,
    DISCOVERING,
    CONNECTING
};

//-- DECLARATIONS
class BLEcontroller {
    public:
    //-----------------------------------------------------------------------  
    
    //-- constructor
    #if (ARDUINO >= 100)
      BLEcontroller(SoftwareSerial *);
    #else
      BLEcontroller(NewSoftSerial *);
    #endif

    void  init(long baudrate);              //-- place this in setup() function
    void  setVerbose(bool b);               //-- default false. set verbosity to monitor in Serial Monitor

    void  run();                            //-- place this in loop()

    void  startAdvertising();               //-- module should default to advertising, but just in case
    bool  isAdvertising();                  //-- returns if module is advertising

    void  initConnection();                 //-- begins connection with first device it finds
    bool  isConnected();                    //-- returns if connected to a device
    bool  isInDataMode();                   //-- return if connected and in data mode (BRSP)
    void  disconnect();                     //-- begins disconnection with connected device
    
    void  send(char msg);                   //-- sends a character through software serial (either to the module or to the connected device)

    // //-- pairing stuff
    // void acceptPairingRequest();
    // bool isPaired();
    void  unpair();

    // void  printQueueToSerial();
    void  clearRxQueue();
    bool  isRxQueueEmpty();
    int   rxQueueAvailable();

    // //-- other settings
    void reset();
    // void sleep();
    // void wakeFromSleep();

    //-- getting information about the module
    // void setName(String name);           //-- sets the name of the BLE module
    String  getName();                      //-- gets the name of the BLE module
    String  getAddressOfModule();           //-- returns the address of the BLE module
    int     getSignalStrength();            //-- returns signal strength of first connection. [-127, +20]
    String  getConnectionStatus();          //-- needs work. returns kind of connection and if paired

  
    private:
    //-----------------------------------------------------------------------
    //-- interfacing Arduino to bluetooth module
    void    sendCommand(String);              //-- send a string as a command to the BLE module
    void    readCommandResponse();            //-- read the subsequent response and store it

    //-- private functions
    void    readRx();
    void    readTx();
    int     checkForEvents();
    void    stateMachine(int event);
    String  getCSVofString(String str, int index);
    void    clearResponseBuffer();

    QueueList <String>  rxQueue;               //-- the receive buffer
    QueueList <String>  txQueue;               //-- whatever you send out
    String              rxLine;                //-- buffer of chars for each line
    String              txLine;                //-- buffer of chars for each line

    //int rxBufferSize;

    bool                bVerbose;
    int                 currentState;

    bool                bIsInDataMode;
    bool                bIsConnected;
    String              connectAddr; //-- at some point, make this an array


    //-- AT command responses are separated by lines, this is the parsed array
    //-- to get the individual comma separated values, use getCSVofString()
    String parsedCommandResponses[MAX_N_RESPONSES];
    int parsedCommandResponsesLength; //-- its length
    char responseBuffer[MAX_RESPONSE_SIZE];


    //-- for some reason, the only place this can go is at the end
    #if ARDUINO >= 100
    SoftwareSerial *softSerial;
    #else
    NewSoftSerial *softSerial;
    #endif  
    

};

