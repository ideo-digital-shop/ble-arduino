//
//  SteeringSlider.m
//  sampleclient
//
//  Created by Mel He on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SteeringSlider.h"


@implementation SteeringSlider


@synthesize bar;
@synthesize controlTarget;
@synthesize controlAction;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern1.jpg"]];
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [COLOUR_GRAYSCALE_A(60, 1.0) CGColor];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 12;
        
        self.bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width/8, self.bounds.size.height)];
        self.bar.backgroundColor = COLOUR_GRAYSCALE_A(255, 1.0);
        self.bar.userInteractionEnabled = YES;
        [self addSubview:self.bar];
        
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bar.center.y);
        self.bar.center = center;
    }
    return self;
}


- (void)addTarget:(id)target action:(SEL)action
{
    self.controlTarget = target;
    self.controlAction = action;
}


#pragma mark - touch handling


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    CGPoint position;
    if ([touch.view isEqual:self.bar]) {
        position = [touch locationInView:self];
        position.y = self.bar.center.y;
        if (position.x < self.bar.bounds.size.width/2) {
            position.x = self.bar.bounds.size.width/2;
        }
        else if (position.x > self.bounds.size.width - self.bar.bounds.size.width/2) {
            position.x = self.bounds.size.width - self.bar.bounds.size.width/2;
        }
        self.bar.center = position;
        /* generate control code [-1, +1] as CGFloat */
        CGFloat percentage = (position.x-self.bar.bounds.size.width/2)/(self.bounds.size.width-self.bar.bounds.size.width);
        NSNumber *steeringCode = [NSNumber numberWithFloat:-1+(2*percentage)];
        [self.controlTarget performSelector:self.controlAction withObject:steeringCode];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    __block CGPoint center = CGPointMake(self.bounds.size.width/2, self.bar.center.y);
    
    [UIView animateWithDuration:ANIMATION_DURATION_SECONDS 
                          delay:0 
                        options:UIViewAnimationOptionTransitionNone
                     animations:^(){
                         self.bar.center = center;
                     } 
                     completion:^(BOOL finished){
                         /* center the sterring position */
                         [self.controlTarget performSelector:self.controlAction withObject:[NSNumber numberWithFloat:0.0]];
                     }];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self touchesEnded:touches withEvent:event];
}


@end
