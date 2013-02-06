//
//  ConnectionController.m
//  sampleclient
//
//  Created by Michael Testa on 3/16/12.
//  Copyright (c) Blueradios, Inc. All rights reserved.
//

#import "ConnectionController.h"
#import "MyWebViewController.h"

@implementation ConnectionController
@synthesize activityIndicator = _activityIndicator;
@synthesize btInterfaceView = _btInterfaceView;
@synthesize webBridgeView = _webBridgeView;
@synthesize d = _d;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self disableButtons];
    self.navigationItem.title = _d.cbPeripheral.name;
    
    _d.connController = self; 
    [_d connect:[nBlue shared_nBlue:self]];    //Connect the device and set nBlueDelegate to this controller
    [_inputText setDelegate:self];
    _currentMode=0;
    
    
    self.webBridgeView = [[WebBridgeView alloc] init];
    
    [self.webBridgeView loadInterfaceForDevice:_d.cbPeripheral.name];
    
    

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _nb = [nBlue shared_nBlue:self];  //Set the nBlueDelegate to this controller everytime this view appears
    [self.activityIndicator startAnimating];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setWebBridgeView:nil];
    [self setActivityIndicator:nil];
    [self setBtInterfaceView:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_d disconnect];  //Disconnect device if view is disappearing
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch(interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            return NO;
        case UIInterfaceOrientationLandscapeRight:
            return NO;
        default:
            return YES;
    }
}

#pragma mark - UITextFieldDelegate methods
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [_d writeBrsp:[NSString stringWithFormat:@"%@\r", textField.text]]; //Write whatever user typed in textfield before clicking return key
    textField.text = @"";
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up: NO];
}

- (void) animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = 170; //will only work on iPhone
    const float movementDuration = 0.3f; //
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)getInfo:(id)sender {
    NSLog(@"SERVICES: %@", _d.cbPeripheral.services);
    NSLog(@"NAME: %@:", _d.cbPeripheral.name);
    NSLog(@"UUID: %@:", _d.cbPeripheral.UUID);
}




//This function is called when the genericDevice fully connects
- (void)enableButtons {
 
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    self.view = self.webBridgeView;
        
    //Set the nBlueDelegate to this controller everytime this view appears
    self.webBridgeView.nb = [nBlue shared_nBlue:self.webBridgeView];      
    
    NSLog(@"ViewWillAppear for MyWebViewController.");
    if(self.d)
    {
        NSLog(@"Recognized the device is available!");
        
        //Connect the device and set nBlueDelegate to this controller
        
        //Set the webviews device to the delegate's.
        self.webBridgeView.d = self.d;
        
    }
    else {
        UIAlertView *alertView = 
        [[UIAlertView alloc] initWithTitle:@"Problems." 
                                   message:@"Bluetooth device is not ready to go"
                                  delegate:self
                         cancelButtonTitle:nil 
                         otherButtonTitles:@"Ok", nil];
        [alertView show];   
    }
    
}
- (void)disableButtons {

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyWebViewController *webViewController = [segue destinationViewController];
    webViewController.device = self.d; 
    
}


#pragma mark - Utilites 

@end
