#Bluetooth Low-Energy Arduino Shield
*with the nBlue BLE Module, written by Jimmy Chion, IDEO*

##Quick Start

On Arduino side:
Download and install the [Queuelist library for Arduino](http://playground.arduino.cc/Code/QueueList)
(to install, just drag and drop the QueueList folder into /Documents/Arduino/libraries/)

Download and install the BLEcontroller library.

Upload the sketch BLE_tester.ino onto your 3.3V Pro Mini. Open the Serial Monitor, 9600 Baudrate with Carriage Return.

On the iOS side:
go to the nBlue Forum and download the Sample Client (scroll to bottom of this doc to for site and login). Install it onto your BLE-enabled iOS device (much easier said than done).

Opening up Sample Client on your iOS device and scanning for devices should find the advertising BLE shield.
Connect to it, and you will see the blinking light turn solid. In Serial Monitor, you will see it spit out
information that it is now connected. You now have an open serial-like connection between the two.


##About

Bluetooth 4.0 is a great way to get information in and out of the iPhone 4s, iPad 3, and other new Apple products. It provides a quick wireless link for easy prototyping. 

This documentation probably has a missing sections. Please direct ANY AND ALL questions to

* Jimmy Chion <jchion@ideo.com> - firmware design
* Kyle Doerksen <kdoerksen@ideo.com> - hardware design
* Dan Goodwin <dg@ideo.com> - iOS layer (no longer with IDEO)

The product has since evolved from [IDEO Labs post](http://labs.ideo.com/2012/07/02/bluetooth-4-0-as-a-prototyping-tool/)

The shield is designed for Arduino Pro Mini and for Bluetooth 4.0 <-> iOS (bi-directional).


##Limitations

Bluetooth 4.0 (aka Bluetooth Low-Energy aka BLE) operates at the same frequency as classic BT, but has a much slower data rate of 200kb/s. It has a range of about 50-70m outdoors.

With our library, data rate is throttled down for accuracy. From BLE module to Arduino, we are limited by the Software Serial, which is kinda accurate at 19200 baud. (more about why we are using Software Serial instead of the TX/RX on the Arduino in the Hardware section of this doc).


##Pre-setup

The pre-setup was taken care of by IDEO Bay Area for the included boards. This section is for documentation purposes only.

The firmware on the nBlue BLE modules is often out of date and needs a firmware update for it to work with iOS.

To update the firmware, open up nBlueProg.exe and plug the module into an [FTDI usb plug](http://www.sparkfun.com/products/9873). Don't forget the board operates at 3.3V, so the FTDI has to be 3.3V. 

Here's the pin mapping from FTDI to module (or Arduino)
3v3 -- VCC
GND -- GND (both GNDs)
TX -- TX (yes, this is unconventional)
RX -- RX (currently pin 7)

See hardware > test rig for photos of Bay Area's setup

Make sure your Windows machine has [FTDI drivers](http://www.ftdichip.com/Drivers/VCP.htm) installed and recognizes the FTDI USB thing as a COM port. 

See embedded software > firmware update
Open up the nBlueProg.exe and point it to the correct .brx firmware update. You can download the [latest update](http://www.blueradios.com/forum/. (See Online section of this doc for log in info.)


After you have updated the firmware, leave it powered. The green light should be blinking to indicate it is in advertising mode. You can now open up the iPhone app, nBlue Sample Client. Click on Scan, and then the name of the advertising BLE module. The red LED on the module should now be solid.

We're now connected and paired with the module. We need to change the baud rate to 19200 (instead of 115200 default) in order for Software Serial to work. To do this, we click on the rightmost button which should say "Data." Clicking on that changes it to Command mode, which means we can talk to the BLE module through Bluetooth to send it AT commands. If the button now says Command, we are in Command mode.

Typing a simple `AT` should elicit an `OK`.

Type `ATSUART,4,0,0,1`. This changes the baudrate to 19200, 8, n, 1. See the ATSUART under the AT.s command set if you need to change the baudrate to anything else.

From there, we're good to go. At this point, if you open up any Serial Monitor from Arduino and set the baudrate to 19200, with Carriage Return, then you should be able to just type stuff into the Serial Monitor and see it appear on the iPhone app and vise versa. If it looks like gibberish, power cycle the arduino and check that it's `ATSUART?` gets a reply of `4,0,0,1`. Sometimes the changed setting doesn't stick.

Again, we took care of all this for you in the two modules included, but we're describing it here for when you produce your own boards.


##Setup from factory-reset modules

Here's setup for simple serial communication between BLE module and iPhone

Assumptions at this point:
* BLE module's firmware is up to date (1.2.1.3.1.0-S3.brx as of 02.01.13)
* baudrate for SoftwareSerial is correct (19200 for now). In other words, if you ran the command `ATSUART?`, you would get a reply of `4,0,0,1`.

1. get the nBlue Sample Client app loaded onto an iOS device with Bluetooth 4.0. This includes iPhone 4s, iPad 3, and the new MacBook Air and Pros.

2. stack the shield onto a Pro Mini. MAKE SURE IT'S 3.3V AND NOT 5V.

3. Open up nBlue_tester.ino and load it onto the Arduino.

4. Open the Serial Monitor, set baudrate to 9600 with line ending: Carriage Return

5. Open up the iPhone app and connect to the advertising BLE Module

6. Typing something into the Serial Monitor should show up on the iPhone App. Likewise, typing something into the app should show up in the Serial Monitor.



##Hardware

See hardware > schematics_nano_bluetooth4_3.3v for schematics

We're using SoftwareSerial to send data between the Arduino and BLE module. The BLE module then sends the info through Bluetooth to the iOS. The SoftwareSerial's tx/rx are IO pins 6 and 7 on the arduino.

The rest of the hardware is pretty simple. VCC and GND are connected and that's about it.

We've bridged CTS and DTR pins manually, but we'll put that in future versions.


##Arduino Library
To install library, add it to your Arduino's "libraries" folder and then write `#include "BLEcontroller.h"` to your sketch.

see embedded software > libraries

The library packages the AT.s commands into simple Arduino functions. This library still needs a lot of work and could be adapted for each specific application. For example, the RC car we built used a protocol that was modified. At some point, it would be nice to have insertable protocols.

Read through the .h file to get an understanding of the different functions. 


###Arduino Examples

BLE_tester.ino
shows off the possible functions exposed by the BLEcontroller library.

BLE_SerialExample.ino
Allows you to talk to the device without the use of BLEcontroller library. Refer to the AT commandset that nBlue publishes.
You can find that in the forum.

More specific information and comments inside each Arduino sketch.


##iOS 
(hasn't been updated since the IDEO labs post)


here's what Dan wrote:

For software questions (and I expect there to be a lot of them), 
ping Dan <dg@ideo.com>. 

Highlights of contents of iOS > our modified iPhone app:

NativeBridge.js 
is the code where the magic happens in terms of using javascript 
to call iOS code. This code was adopted from [this guy's blog](http://blog.techno-barje.fr/post/2010/10/06/UIWebView-secrets-part3-How-to-properly-call-ObjectiveC-from-Javascript/).

server.js 
is the master node file that returns the right interface, 
as well as doing some sweet real-time message passing with now.js

index.html 
is the first interface we made to steer the car. You can see the jquery+now.js
magic at the top of the file, and the NativeBridge.js code is at the bottom of the file

camera.html
is a quick and dirty copy of index.html, it is virtually identical,
albeit simplified to only send one control signal.

TO DO:

We did not have enough time to create an elegant message passing interface between the JS
and the iOS code. Right now we are running on a very simple protocol, the signals sent to
BT radio are in the form "(a,b,c,d)" where each letter is a number from 0-10. You can 
see how this is handled in the WebBridgeView.m file at the "steerCar" section in the
`- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args`
function


##Online resources

* [nBlue forum](http://www.blueradios.com/forum/)

* nBlue AT.s Command Set
see forum above

* [FTDI drivers](http://www.ftdichip.com/Drivers/VCP.htm)

* [SoftwareSerial](http://arduino.cc/hu/Reference/SoftwareSerial)

* [a look at Apple's CoreBluetooth](http://developer.apple.com/library/ios/#samplecode/TemperatureSensor/Introduction/Intro.html)


