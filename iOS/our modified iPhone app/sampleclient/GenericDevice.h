//
//  GenericDevice.h
//  sampleclient
//
//  Created by Michael Testa on 3/16/12.
//  Copyright (c) 2012 BlueRadios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRDevice.h"
#import "ConnectionController.h"

@class ConnectionController;

//This class represents a generic BlueRadios BRSP device
@interface GenericDevice : BRDevice {
    __weak ConnectionController *_connController;
}

@property (nonatomic, weak) ConnectionController *connController;

- (void)writeMultipleCommands;  

@end
