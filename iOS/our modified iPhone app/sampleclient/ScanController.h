//
//  ViewController.h
//  libtester
//
//  Created by DERIC KRAMER on 2/1/12.
//  Copyright (c) Blueradios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nBlue.h"
#import "ConnectionController.h"

@interface ScanController : UIViewController <UITableViewDelegate, UITableViewDataSource, nBlueDelegate > {
    nBlue *_nb;                  
    IBOutlet UITableView *deviceTableView;
    IBOutlet UIButton *_scanButton;
}

@property (strong, nonatomic) ConnectionController *connectionView;
@property (strong, nonatomic) UITableView* deviceTableView;

//UI Elements
- (IBAction)BLEScanButton:(id)sender;
- (IBAction)BLEStopScanButton:(id)sender;
- (void)enableButton:(UIButton*)butt;
- (void)disableButton:(UIButton*)butt;
@end
