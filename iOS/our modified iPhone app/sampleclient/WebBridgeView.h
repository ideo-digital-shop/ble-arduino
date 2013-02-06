//
//  MyWebView.h
//  UIWebView-Call-ObjC
//
//  Created by NativeBridge on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SBJSON.h"
#import "nBlue.h"
#import "BRDevice.h"

@interface WebBridgeView : UIWebView <UIWebViewDelegate, nBlueDelegate> {
    SBJSON *json;       
    int alertCallbackId;    //JS<->ObJC bridge

    BRDevice *_d;      //Bluetooth stuff
    nBlue *_nb;
    NSUInteger _currentMode;
}

@property (strong, nonatomic) BRDevice *d; 
@property (nonatomic) NSUInteger currentMode; 
@property (nonatomic) nBlue *nb; 
//@property (strong, nonatomic) NSString *deviceName;

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args;
- (void)returnResult:(int)callbackId args:(id)firstObj, ...;
- (void) loadInterfaceForDevice: (NSString *) deviceName;
@end
