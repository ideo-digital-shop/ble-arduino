//
//  MyWebViewController.h
//  BluetoothPlatform
//
//  Created by Daniel Goodwin on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebBridgeView.h"
#import "GenericDevice.h"

@interface MyWebViewController : UIViewController
{
    GenericDevice *_device;   
}



@property (strong, nonatomic) WebBridgeView *webBridgeView;
@property (strong, nonatomic) GenericDevice *device;
@end
