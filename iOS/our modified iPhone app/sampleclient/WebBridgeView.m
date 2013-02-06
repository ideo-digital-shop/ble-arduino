//
//  WebBridgeView.m
//  UIWebView-Call-ObjC
//
//  Created by NativeBridge on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebBridgeView.h"
//#import "TestDevice.h"

@interface WebBridgeView ()
//@property TestDevice * testDevice;
@end

@implementation WebBridgeView
//@synthesize testDevice;
@synthesize d = _d;
@synthesize nb = _nb;
@synthesize currentMode = _currentMode;
//@synthesize deviceName;

- (id)initWithFrame:(CGRect)frame 
{
  if (self = [super initWithFrame:frame]) {
    
    // Set delegate in order to "shouldStartLoadWithRequest" to be called
    self.delegate = self;
    
    // Set non-opaque in order to make "body{background-color:transparent}" working!
    self.opaque = NO;
    
    // Instanciate JSON parser library
    json = [ SBJSON new ];
    
  }
  return self;
}


//This is a hyper-simplified version of the way the device->ios->web 
//connection should work: 
//The name of the radio is used to determine which page should be loaded
//Eventually this should be handled as an input parameters to the server
//NOT this hardcoded /camera/ or /car/ targets
- (void) loadInterfaceForDevice: (NSString *) deviceName
{
    NSURL *url;
    NSLog(@"Device name is: %@", deviceName);
    if([deviceName isEqualToString:@" IDEO-car"])
        url = [NSURL URLWithString:@"http://smooth-night-7380.herokuapp.com/car/"];
    else
        url = [NSURL URLWithString:@"http://smooth-night-7380.herokuapp.com/camera/"];  
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void) didConnect:(CBPeripheral*)p error:(NSError*)error {
    
    if(error == nil) {
        NSLog(@"in didConnect of webbridgeview. trying to change notification");
        
        //-- future to do: be able to turn notifications off
        //-- to try + see: discover the characteristics and then turn all of them off. similar to temperatureSensor app
        //[p setNotifyValue:NO forCharacteristic:];
    }
}
- (void) didDisconnect:(CBPeripheral*)p error:(NSError*)error {}
- (void) nBlueReady {}



// This selector is called when something is loaded in our webview
// By something I don't mean anything but just "some" :
//  - main html document
//  - sub iframes document
//
// But all images, xmlhttprequest, css, ... files/requests doesn't generate such events :/
- (BOOL)webView:(UIWebView *)webView2 
	      shouldStartLoadWithRequest:(NSURLRequest *)request 
	      navigationType:(UIWebViewNavigationType)navigationType {

	NSString *requestString = [[request URL] absoluteString];
  
  NSLog(@"request : %@",requestString); //Helpful when we need to see how many requests are coming in/out
  
  if ([requestString hasPrefix:@"js-frame:"]) {
    
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    NSString *function = (NSString*)[components objectAtIndex:1];
		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
    NSString *argsAsString = [(NSString*)[components objectAtIndex:3] 
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *args = (NSArray*)[json objectWithString:argsAsString error:nil];
    
    [self handleCall:function callbackId:callbackId args:args];
    
    return NO;
  }
  
  return YES;
}

// Call this function when you have results to send back to javascript callbacks
// callbackId : int comes from handleCall function
// args: list of objects to send to the javascript callback
- (void)returnResult:(int)callbackId args:(id)arg, ...;
{
  if (callbackId==0) return;
  
  va_list argsList;
  NSMutableArray *resultArray = [[NSMutableArray alloc] init];
  
  if(arg != nil){
    [resultArray addObject:arg];
    va_start(argsList, arg);
    while((arg = va_arg(argsList, id)) != nil)
      [resultArray addObject:arg];
    va_end(argsList);
  }

  NSString *resultArrayString = [json stringWithObject:resultArray allowScalar:YES error:nil];
  
  // We need to perform selector with afterDelay 0 in order to avoid weird recursion stop
  // when calling NativeBridge in a recursion more then 200 times :s (fails ont 201th calls!!!)
    
    NSString *output = [NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,resultArrayString];
    

    [self performSelector:@selector(returnResultAfterDelay:) withObject:output afterDelay:0];
}

-(void)returnResultAfterDelay:(NSString*)str {
  // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
  [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}

// Implements all you native function in this one, by matching 'functionName' and parsing 'args'
// Use 'callbackId' with 'returnResult' selector when you get some results to send back to javascript
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
  if ([functionName isEqualToString:@"setBackgroundColor"]) {
    
    if ([args count]!=3) {
      NSLog(@"setBackgroundColor wait exactly 3 arguments!");
      return;
    }
    NSNumber *red = (NSNumber*)[args objectAtIndex:0];
    NSNumber *green = (NSNumber*)[args objectAtIndex:1];
    NSNumber *blue = (NSNumber*)[args objectAtIndex:2];
    NSLog(@"setBackgroundColor(%@,%@,%@)",red,green,blue);
    self.backgroundColor = [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1.0];
    [self returnResult:callbackId args:nil];
    
  } else if ([functionName isEqualToString:@"prompt"]) {
    
    if ([args count]!=1) {
      NSLog(@"prompt wait exactly one argument!");
      return;
    }
        
    NSString *message = (NSString*)[args objectAtIndex:0];
    
    alertCallbackId = callbackId;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
  } 
    
  //For JS->iOS requests for data  
  else if ([functionName isEqualToString:@"readDeviceData"]) {
      
      alertCallbackId = callbackId;
      //NSLog(@"Accelerometer sees: %f",[device getData] );
      //[self returnResult:callbackId args:[NSNumber numberWithFloat:[testDevice getData]],nil];  
  }
  
  //The IDEO Car and Camera demos were done using this steerCar
  //target function. Note that it returns "1.0" everytime, but
  //That could easily be changed into something more meaningful
  else if ([functionName isEqualToString:@"steerCar"]) {
      
      alertCallbackId = callbackId;

      NSString *message = (NSString*)[args objectAtIndex:0];
      NSLog(@"Sending string to Bluetooth: %@", message);
      if(self.d)
          [self.d writeBrsp:message];
      else {
          NSLog(@"_d is null for some reason!?");
      }
      
      [self returnResult:callbackId args:[NSNumber numberWithFloat:1.0],nil];  
  }
    
  
  else {
    NSLog(@"Unimplemented method '%@'",functionName);
  }
    
}

// Just one example with AlertView that show how to return asynchronous results
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (!alertCallbackId) return;
  
  NSLog(@"prompt result : %d",buttonIndex);
  
  BOOL result = buttonIndex==1?YES:NO;
  [self returnResult:alertCallbackId args:[NSNumber numberWithBool:result],nil];
  
  alertCallbackId = 0;
}

@end
