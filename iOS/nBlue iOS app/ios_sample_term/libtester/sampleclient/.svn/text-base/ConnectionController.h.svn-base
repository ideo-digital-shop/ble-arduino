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

@class GenericDevice;

@interface ConnectionController : UIViewController <UITextFieldDelegate, nBlueDelegate> {
    UITextField *_inputText;
    NSUInteger _currentMode;
    GenericDevice *_d;
    nBlue *_nb;
}

@property (strong, nonatomic) GenericDevice *d;                    
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *inputText;

@property (strong, nonatomic) IBOutlet UIButton *buttonChangeMode;
@property (strong, nonatomic) IBOutlet UIButton *buttonGetSettings;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend100;

//ui
- (IBAction)send100Button:(id)sender;
- (IBAction)getSettings:(id)sender;
- (IBAction)changeMode:(id)sender;
- (void)animateTextField:(UITextField*)textField up:(BOOL)up;

- (void)enableButtons;
- (void)disableButtons;
- (void)enableButton:(UIButton*)butt;
- (void)disableButton:(UIButton*)butt;

@end
