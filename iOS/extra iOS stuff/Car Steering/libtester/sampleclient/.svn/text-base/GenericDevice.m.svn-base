//
//  GenericDevice.m
//  sampleclient
//
//  Created by Michael Testa on 3/16/12.
//  Copyright (c) 2012 BlueRadios, Inc. All rights reserved.
//

#import "GenericDevice.h"

//NOTE:  Instead of having this class do everything, we could have eliminated the need for this class altogether
//by setting the BRDevice.deviceDelegate (create that class instead of this one) to the ConnectionController, and placing the BRDeviceDelegate methods in there.

@implementation GenericDevice
@synthesize connController = _connController;

#pragma mark - BRDeviceDelegate methods
-(void) didConnect:(NSError*)error {
    [_connController enableButtons];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
}

-(void) didDisconnect:(NSError*)error {
    [_connController.navigationController popViewControllerAnimated:YES];   
}

-(void) deviceResponse:(NSData *)response {
    NSString *tmp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    _connController.textView.text = [NSString stringWithFormat:@"%@%@", _connController.textView.text, tmp];
    
    CGPoint bottomOffset = CGPointMake(0, [_connController.textView contentSize].height - _connController.textView.frame.size.height);
    
    if (bottomOffset.y > 0)
        [_connController.textView setContentOffset: bottomOffset animated: YES];
}

-(void) modeChanged:(DeviceMode)mode {
    switch (mode) {
        case DeviceModeData:
            [_connController.buttonChangeMode setTitle:[NSString stringWithFormat:@"Data"] forState:UIControlStateNormal];
            break;
        case DeviceModeRemoteCommand:
            [_connController.buttonChangeMode setTitle:[NSString stringWithFormat:@"Command"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

#pragma mark - Custom Actions
- (void)writeMultipleCommands {
    DeviceMode mode = self.mode;
    [self changeBrspMode:DeviceModeRemoteCommand];  //Change BRSP mode to remote_command
    [self writeBrsp:@"atss?,0\r"];
    [self writeBrsp:@"atss?,1\r"];
    [self writeBrsp:@"atv?\r"];
    [self writeBrsp:@"atmt?\r"];
    [self writeBrsp:@"ata?\r"];
    [self writeBrsp:@"ats?\r"];
    [self writeBrsp:@"atlca?\r"];
    [self writeBrsp:@"atsp?\r"];
    [self writeBrsp:@"atscl?\r"];
    [self writeBrsp:@"atsuart?\r"];
    [self writeBrsp:@"atspio?,0\r"];
    [self writeBrsp:@"atspio?,1\r"];
    [self writeBrsp:@"atspio?,7\r"];
    [self writeBrsp:@"atspio?,8\r"];
    [self writeBrsp:@"atspio?,9\r"];
    [self writeBrsp:@"atspio?,10\r"];
    [self writeBrsp:@"atspio?,11\r"];
    [self writeBrsp:@"atspio?,12\r"];
    [self writeBrsp:@"atspio?,13\r"];
    [self writeBrsp:@"atspio?,14\r"];
    [self writeBrsp:@"atsled?,0\r"];
    [self writeBrsp:@"atsled?,1\r"];
    [self writeBrsp:@"atsrm?\r"];
    [self writeBrsp:@"atsn?\r"];
    [self writeBrsp:@"atscod?\r"];
    [self writeBrsp:@"atscp?\r"];
    [self writeBrsp:@"atsdm?\r"];
    [self writeBrsp:@"atsto?\r"];
    [self writeBrsp:@"atspl?\r"];
    [self writeBrsp:@"atsaa?\r"];
    [self writeBrsp:@"atrssi?\r"];
    [self writeBrsp:@"atsbrsp?\r"];
    [self writeBrsp:@"atsesc?\r"];
    [self changeBrspMode:mode]; //Change mode back to what it was before
}

@end
