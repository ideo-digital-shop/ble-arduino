//
//  ConnectionController.m
//  sampleclient
//
//  Created by Michael Testa on 3/16/12.
//  Copyright (c) Blueradios, Inc. All rights reserved.
//

#import "ConnectionController.h"

@implementation ConnectionController

@synthesize d = _d;
@synthesize textView;
@synthesize inputText = _inputText;
@synthesize buttonChangeMode;
@synthesize buttonSend100;
@synthesize buttonGetSettings;

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
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _nb = [nBlue shared_nBlue:self];  //Set the nBlueDelegate to this controller everytime this view appears
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
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

#pragma mark - UI
- (IBAction)send100Button:(id)sender {
    DeviceMode lastmode = _d.mode;
    [_d changeBrspMode:DeviceModeData];  //Change BRSP mode to remote_command
    for (int tmp1=1; tmp1 <= 10; tmp1++) {
        [_d writeBrsp:[NSString stringWithFormat:@"%i\r\n", tmp1%10]];  //Write 10 lines of data to the device (Was originally 100)
    }
    [_d changeBrspMode:lastmode];
}

//prints a significant amount of information about the BRSP device
- (IBAction)getSettings:(id)sender {
    [_d writeMultipleCommands];
}

- (IBAction)changeMode:(id)sender {
    NSUInteger iNextMode = !_currentMode+1; //Set mode to opposite of current mode
    [_d changeBrspMode:iNextMode];  //DeviceModeData==1, DeviceModeRemoteCommand=2 
    _currentMode=!_currentMode;
}

- (void)enableButtons {
    [self enableButton:self.buttonChangeMode];
    [self enableButton:self.buttonGetSettings];
    [self enableButton:self.buttonSend100];
}
- (void)disableButtons {
    [self disableButton:self.buttonChangeMode];
    [self disableButton:self.buttonGetSettings];
    [self disableButton:self.buttonSend100];    
}
- (void)enableButton:(UIButton*)butt {
    butt.enabled = YES;
    butt.alpha = 1.0;
}
- (void)disableButton:(UIButton*)butt {
    butt.enabled = NO;
    butt.alpha = 0.5;   
}
#pragma mark - Utilites 

@end
