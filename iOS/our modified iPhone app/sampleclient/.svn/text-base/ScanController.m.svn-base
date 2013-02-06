//
//  ViewController.m
//  libtester
//
//  Created by DERIC KRAMER on 2/1/12.
//  Copyright (c) Blueradios, Inc. All rights reserved.
//

#import "ScanController.h"

@implementation ScanController

@synthesize deviceTableView;
@synthesize connectionView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Select Device";    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    _nb = [nBlue shared_nBlue:self];  //Set the nBlueDelegate to this controller everytime this view appears
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch(interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            return NO;
        case UIInterfaceOrientationLandscapeRight:
            return NO;
        default:
            return YES;
    }
}

#pragma mark - Table options

//**********************************************************************************************************************************************************
//Table Options 
//**********************************************************************************************************************************************************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)TableView numberOfRowsInSection:(NSInteger)section {
    return _nb.peripherals.count; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	// Configure the cell.
    
    CBPeripheral *aPeripheral = [_nb.peripherals objectAtIndex:indexPath.row];
    
    cell.textLabel.text = aPeripheral.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"cellSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"cellSegue"]) {
        NSIndexPath *indexPath = [self.deviceTableView indexPathForSelectedRow];
        
        ConnectionController *deviceview = [segue destinationViewController];       
        //Create the GenericDevice and pass it to the next controller
        deviceview.d = [[GenericDevice alloc] initWithPeripheral:[_nb.peripherals objectAtIndex:indexPath.row]];  
        [self.deviceTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return NO;}

#pragma mark - Utility 
- (void) deviceFound:(CBPeripheral*)p {
    if(_nb.peripherals.count > 0)
    {
        [self.deviceTableView reloadData];
    }    
}
- (void) scanComplete {
    [self enableButton:_scanButton];
}
- (void) didConnect:(CBPeripheral*)p error:(NSError*)error {
    if(error == nil) {
        NSLog(@"in didConnect. trying to change notification");
        
        //-- future to do: be able to turn notifications off
        //-- to try + see: discover the characteristics and then turn all of them off. similar to temperatureSensor app
        //[p setNotifyValue:NO forCharacteristic:];
    }
}
- (void) didDisconnect:(CBPeripheral*)p error:(NSError*)error {}
- (void) nBlueReady {}

#pragma mark - UI 

- (void) BLEScanButton:(id)sender {
    NSLog(@"start finding devices\r\n");
    [self disableButton:_scanButton];
    //Scan for BRSP devices for 3 seconds
    [_nb scan_nBlue:3 ServiceFilter:BRServiceAll];
}

- (void) BLEStopScanButton:(id)sender {
    [_nb stopScan_nBlue];
}

- (void)enableButton:(UIButton*)butt {
    butt.enabled = YES;
    butt.alpha = 1.0;
}

- (void)disableButton:(UIButton*)butt {
    butt.enabled = NO;
    butt.alpha = 0.5;   
}

@end
