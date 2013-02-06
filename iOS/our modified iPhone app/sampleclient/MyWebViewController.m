//
//  MyWebViewController.m
//  BluetoothPlatform
//
//  Created by Daniel Goodwin on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyWebViewController.h"
#import "WebBridgeView.h"
#import "AppDelegate.h"
#import "GenericDevice.h"
@interface MyWebViewController ()

@end

@implementation MyWebViewController
@synthesize webBridgeView;
@synthesize device = _device;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webBridgeView = [[WebBridgeView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = webBridgeView;
}

- (void) viewWillAppear:(BOOL)animated
{
    //Set the nBlueDelegate to this controller everytime this view appears
    webBridgeView.nb = [nBlue shared_nBlue:webBridgeView];      
    
    NSLog(@"ViewWillAppear for MyWebViewController.");
    if(self.device)
    {
        NSLog(@"Recognized the device is available!");

        //Connect the device and set nBlueDelegate to this controller
    
        //Set the webviews device to the delegate's.
        webBridgeView.d = self.device;
    }
    
    else {
        UIAlertView *alertView = 
        [[UIAlertView alloc] initWithTitle:@"Problems." 
                                   message:@"Bluetooth device is not ready to go"
                                  delegate:self
                         cancelButtonTitle:nil 
                         otherButtonTitles:@"Ok", nil];
        [alertView show];   
    }
    
    [super viewWillAppear:animated];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
