//
//  CarController.m
//  sampleclient
//
//  Created by Mel He on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CarController.h"
#import "SteeringSlider.h"
#import "SpeedSlider.h"
#import "GenericDevice.h"


@interface CarController ()

@end


@implementation CarController


@synthesize stopButton;
@synthesize steering;
@synthesize speed;
@synthesize device = _device;
@synthesize currentSteering;
@synthesize currentSpeed;
@synthesize firstDigit;
@synthesize secondDigit;
@synthesize thirdDigit;
@synthesize lastFirstDigit;
@synthesize lastSecondDigit;
@synthesize lastThirdDigit;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.view.backgroundColor = COLOUR_GRAYSCALE_A(0, 1.0);
    
    /* stop/dismiss button */
    self.stopButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stopButton.png"]];
    self.stopButton.frame = CGRectMake(40/2, 
                                       40/2, 
                                       self.stopButton.image.size.width/2, 
                                       stopButton.image.size.height/2);
    self.stopButton.userInteractionEnabled = YES;
    [self.view addSubview:self.stopButton];
    
    /* sterring slider */
    self.steering = [[SteeringSlider alloc] initWithFrame:CGRectMake(0, 
                                                                     400/2, 
                                                                     600/2, 
                                                                     240/2)];
    [self.view addSubview:self.steering];
    [self.steering addTarget:self action:@selector(steeringDidChangeToPosition:)];
    
    /* speed slider */
    self.speed = [[SpeedSlider alloc] initWithFrame:CGRectMake((960-240)/2, 
                                                               0, 
                                                               240/2, 
                                                               640/2)];
    [self.view addSubview:self.speed];
    [self.speed addTarget:self action:@selector(speedDidChangeToPosition:)];
    
    /* default values */
    self.currentSteering = 0;
    self.currentSpeed = 0;
    firstDigit = 2;
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    self.stopButton = nil;
    self.steering = nil;
    self.speed = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationLandscapeLeft == interfaceOrientation);
}


#pragma mark - action callbacks for slider controls


- (void)steeringDidChangeToPosition:(NSNumber *)controlCode
{
    self.currentSteering = [controlCode floatValue];
    //DLog("steering position: %f", self.currentSteering);
    
    [self updateSteeringInputWithValue:self.currentSteering];
}


- (void)speedDidChangeToPosition:(NSNumber *)controlCode
{
    self.currentSpeed = [controlCode floatValue];
    //DLog("speed position: %f", self.currentSpeed);
    
    [self updateSpeedInputWithValue:self.currentSpeed];
}


#pragma mark - device


- (void)updateSteeringInputWithValue:(CGFloat)steeringInput
{
    NSString *controlCode = @"(000)";
    
    /* [TODO] convert steering [-1, +1] and speed [0, +1] to (###) string and send to device
     * use the following 2 float values:
     * self.currentSteering     [-1, +1]
     * self.currentSpeed        [0, +1]
     */
    
    
    CGFloat steerValue = self.currentSteering;
    
    if(steerValue < 0) {
        firstDigit = 1;
        
        secondDigit = 9;
        //secondDigit = ABS(steerValue)*10;
        //if (secondDigit > 9.0) secondDigit = 9;
        

        
    }
    else if(steerValue == 0) {
        firstDigit = 2;
        secondDigit = 0; //N/A
        
    }
    else if(steerValue > 0) {
        firstDigit = 0;
        secondDigit = 9;

        //secondDigit = steerValue * 10;
        //if (secondDigit > 9.0) secondDigit = 9;

    }
    
    //-- third digit stays the same
    //-- only send if it has changed
    if(floor(firstDigit) != floor(lastFirstDigit) || floor(lastSecondDigit) != floor(secondDigit)) {
        lastFirstDigit = firstDigit;
        lastSecondDigit = secondDigit;
        controlCode = [NSString stringWithFormat:@"(%1.0f%1.0f%1.0f)", firstDigit, secondDigit, thirdDigit];
        
        [self sendToBTDeviceWithControlCode:controlCode];
    }
    
    
    

}


- (void)updateSpeedInputWithValue:(CGFloat)speedInput
{
    NSString *controlCode = @"(000)";
    
    /* [TODO] convert steering [-1, +1] and speed [0, +1] to (###) string and send to device 
     * use the following 2 float falues:
     * self.currentSteering     [-1, +1]
     * self.currentSpeed        [0, +1]
     */
    
    // -- first and second digit (steering) stay the same
    thirdDigit = self.currentSpeed * 10;
    if (thirdDigit > 9.0) thirdDigit = 9;
    
    if ((int)floor(thirdDigit) % 2 == 1 && thirdDigit > 0 && thirdDigit < 9) thirdDigit++;
    
    // -- only send if it has changed
    if(floor(thirdDigit) != floor(lastThirdDigit)) {
        lastThirdDigit = thirdDigit;
        controlCode = [NSString stringWithFormat:@"(%1.0f%1.0f%1.0f)", firstDigit, secondDigit, thirdDigit];
        
        [self sendToBTDeviceWithControlCode:controlCode];
    }   
    
    
}


- (void)sendToBTDeviceWithControlCode:(NSString *)controlCode
{
    DLog("control code: %@", controlCode);
    [self.device writeBrsp:controlCode];
}


#pragma mark - touch handling


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    UIView *touchedView = touch.view;
    if ([touchedView isEqual:self.stopButton]) {
        
        /* stop the car */
        [self speedDidChangeToPosition:[NSNumber numberWithFloat:0.0]];
        
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
}


@end
