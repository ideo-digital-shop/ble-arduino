//
//  ConnectionController.h
//  sampleclient
//
//  Created by Michael Testa on 3/16/12.
//  Copyright (c) Blueradios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nBlue.h"
#import "GenericDevice.h"
#import "WebBridgeView.h"

@class GenericDevice;

@interface ConnectionController : UIViewController <UITextFieldDelegate, nBlueDelegate> {
    UITextField *_inputText;
    NSUInteger _currentMode;
    GenericDevice *_d;
    nBlue *_nb;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *btInterfaceView;

@property (strong, nonatomic) WebBridgeView *webBridgeView;

@property (strong, nonatomic) GenericDevice *d;                    


//ui
- (void)animateTextField:(UITextField*)textField up:(BOOL)up;

- (void)enableButtons;
- (void)disableButtons;


@end
