//
//  CarController.h
//  sampleclient
//
//  Created by Mel He on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "util.h"


@class SteeringSlider;
@class SpeedSlider;
@class GenericDevice;


@interface CarController : UIViewController {

    UIImageView *stopButton;
    SteeringSlider *steering;
    SpeedSlider *speed;
    GenericDevice *_device;
    CGFloat currentSteering;
    CGFloat currentSpeed;
}


@property (nonatomic, retain) UIImageView *stopButton;
@property (nonatomic, retain) SteeringSlider *steering;
@property (nonatomic, retain) SpeedSlider *speed;
@property (strong, nonatomic) GenericDevice *device;
@property (nonatomic, assign) CGFloat currentSteering;
@property (nonatomic, assign) CGFloat currentSpeed;
@property (nonatomic, assign) CGFloat firstDigit;   
@property (nonatomic, assign) CGFloat secondDigit;   
@property (nonatomic, assign) CGFloat thirdDigit;  
@property (nonatomic, assign) CGFloat lastFirstDigit;   
@property (nonatomic, assign) CGFloat lastSecondDigit;   
@property (nonatomic, assign) CGFloat lastThirdDigit;  


- (void)updateSteeringInputWithValue:(CGFloat)steeringInput;
- (void)updateSpeedInputWithValue:(CGFloat)speedInput;
- (void)sendToBTDeviceWithControlCode:(NSString *)controlCode;


@end
