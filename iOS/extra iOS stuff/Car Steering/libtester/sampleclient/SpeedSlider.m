//
//  SpeedSlider.m
//  sampleclient
//
//  Created by Mel He on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpeedSlider.h"


@implementation SpeedSlider


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
        
        self.bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/8)];
        self.bar.backgroundColor = COLOUR_GRAYSCALE_A(255, 1.0);
        self.bar.userInteractionEnabled = YES;
        [self addSubview:self.bar];
        
        CGPoint bottom = CGPointMake(self.bar.center.x, self.bounds.size.height-self.bar.bounds.size.height/2);
        self.bar.center = bottom;
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
        position.x = self.bar.center.x;
        if (position.y < self.bar.bounds.size.height/2) {
            position.y = self.bar.bounds.size.height/2;
        }
        else if (position.y > self.bounds.size.height - self.bar.bounds.size.height/2) {
            position.y = self.bounds.size.height - self.bar.bounds.size.height/2;
        }
        self.bar.center = position;
        /* generate control code [0, +1] as CGFloat */
        CGFloat percentage = (position.y-self.bar.bounds.size.height/2)/(self.bounds.size.height-self.bar.bounds.size.height);
        NSNumber *steeringCode = [NSNumber numberWithFloat:1-percentage];
        [self.controlTarget performSelector:self.controlAction withObject:steeringCode];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    __block CGPoint bottom = CGPointMake(self.bar.center.x, self.bounds.size.height-self.bar.bounds.size.height/2);
    
    [UIView animateWithDuration:ANIMATION_DURATION_SECONDS 
                          delay:0 
                        options:UIViewAnimationOptionTransitionNone
                     animations:^(){
                         self.bar.center = bottom;
                     } 
                     completion:^(BOOL finished){
                         /* stop car */
                         [self.controlTarget performSelector:self.controlAction withObject:[NSNumber numberWithFloat:0.0]];
                     }];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self touchesEnded:touches withEvent:event];
}


@end
