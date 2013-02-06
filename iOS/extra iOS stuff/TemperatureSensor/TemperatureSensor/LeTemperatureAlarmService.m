


#import "LeTemperatureAlarmService.h"
#import "LeDiscovery.h"


NSString *kTemperatureServiceUUIDString = @"DEADF154-0000-0000-0000-0000DEADF154";
NSString *kCurrentTemperatureCharacteristicUUIDString = @"CCCCFFFF-DEAD-F154-1319-740381000000";
NSString *kMinimumTemperatureCharacteristicUUIDString = @"C0C0C0C0-DEAD-F154-1319-740381000000";
NSString *kMaximumTemperatureCharacteristicUUIDString = @"EDEDEDED-DEAD-F154-1319-740381000000";
NSString *kAlarmCharacteristicUUIDString = @"AAAAAAAA-DEAD-F154-1319-740381000000";
NSString *kOtherUUIDString =  @"1801"; // @"DA2B84F1-6279-48DE-BDC0-AFBEA0226079";//@"1801"; //-- 128-bit UUIDs have to be formatted in this way
NSString *kAnotherUUIDString = @"2A05"; //@"18cda784-4bd3-4370-85bb-bfed91ec86af"; //@"2A04";

NSString *kAlarmServiceEnteredBackgroundNotification = @"kAlarmServiceEnteredBackgroundNotification";
NSString *kAlarmServiceEnteredForegroundNotification = @"kAlarmServiceEnteredForegroundNotification";

@interface LeTemperatureAlarmService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBService			*temperatureAlarmService;
    
    CBCharacteristic    *tempCharacteristic;
    CBCharacteristic	*minTemperatureCharacteristic;
    CBCharacteristic    *maxTemperatureCharacteristic;
    CBCharacteristic    *alarmCharacteristic;
    CBCharacteristic    *kOtherCharacteristic;
    
    CBUUID              *temperatureAlarmUUID;
    CBUUID              *minimumTemperatureUUID;
    CBUUID              *maximumTemperatureUUID;
    CBUUID              *currentTemperatureUUID;
    CBUUID              *otherUUID;
    CBUUID              *anotherUUID;

    id<LeTemperatureAlarmProtocol>	peripheralDelegate;
}
@end



@implementation LeTemperatureAlarmService


@synthesize peripheral = servicePeripheral;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeTemperatureAlarmProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = [peripheral retain];
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
        minimumTemperatureUUID	= [[CBUUID UUIDWithString:kMinimumTemperatureCharacteristicUUIDString] retain];
        maximumTemperatureUUID	= [[CBUUID UUIDWithString:kMaximumTemperatureCharacteristicUUIDString] retain];
        currentTemperatureUUID	= [[CBUUID UUIDWithString:kCurrentTemperatureCharacteristicUUIDString] retain];
        temperatureAlarmUUID	= [[CBUUID UUIDWithString:kAlarmCharacteristicUUIDString] retain];
        otherUUID               = [[CBUUID UUIDWithString:kOtherUUIDString] retain];
        anotherUUID             = [[CBUUID UUIDWithString:kAnotherUUIDString] retain];        
	}
    return self;
}


- (void) dealloc {
	if (servicePeripheral) {
		[servicePeripheral setDelegate:[LeDiscovery sharedInstance]];
		[servicePeripheral release];
		servicePeripheral = nil;
        
        [minimumTemperatureUUID release];
        [maximumTemperatureUUID release];
        [currentTemperatureUUID release];
        [temperatureAlarmUUID release];
        [otherUUID release];
        [anotherUUID release];
    }
    [super dealloc];
}


- (void) reset
{
	if (servicePeripheral) {
		[servicePeripheral release];
		servicePeripheral = nil;
	}
}



#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) start
{
    NSLog(@"In function: start");

	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kTemperatureServiceUUIDString];
	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID, nil];

    [servicePeripheral discoverServices:nil]; //--replaced serviceArray;
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	NSArray		*uuids	= [NSArray arrayWithObjects:currentTemperatureUUID, // Current Temp
								   minimumTemperatureUUID, // Min Temp
								   maximumTemperatureUUID, // Max Temp
								   temperatureAlarmUUID, // Alarm Characteristic
                                    nil];
    
    NSLog(@"In function: didDiscoverServices");
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}
    
    //-- if it gets to here, services have been found, and merged to the peripherals included services.

	services = [peripheral services]; //--load the services that have been discovered already on the peripheral
	if (!services || ![services count]) {
        NSLog(@"returned from didDiscoverServices");
		return ;
	}

	temperatureAlarmService = nil;
    
    //-- look through those services to try to find one that matches the UUID of TemperatureAlarmService
    
	for (CBService *service in services) {
        //NSLog(@"Service: %@\n", service.peripheral.services);
        NSLog(@"service found (UUID): %@", service.UUID);
        
        [peripheral discoverIncludedServices:nil forService:service]; //--look for any subservices
        [peripheral discoverCharacteristics:nil forService:service]; //-- replaced uuids with nil
        /*
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kOtherUUIDString]]) {
			temperatureAlarmService = service;
			break;
		}
         */
	}
    /*
	if (temperatureAlarmService) {
        NSLog(@"Found a service UUID that matches %@", kOtherUUIDString);
		
        [peripheral discoverIncludedServices:nil forService:temperatureAlarmService]; //--look for any subservices
        [peripheral discoverCharacteristics:nil forService:temperatureAlarmService]; //-- replaced uuids with nil
        
    }*/
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
{
    NSLog(@"In function: didDiscoverIncludedServicesForService");

    NSArray *includedServs = [service includedServices];
    CBService *includedServ;
    
    if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}

    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
    //NSLog(@"included services: %@", service.includedServices);

    
    for (includedServ in includedServs) {
        NSLog(@"included service: %@", includedServ.UUID);
    }
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    
    
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
    NSLog(@"In function: didDiscoverCharacteristicsForServices");
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
	/*
	if (service != temperatureAlarmService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    */
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
	for (characteristic in characteristics) {
         NSLog(@"characteristic found: %@", [characteristic UUID]);
        
        
		if ([[characteristic UUID] isEqual:minimumTemperatureUUID]) { // Min Temperature.
            NSLog(@"Discovered Minimum Alarm Characteristic");
			minTemperatureCharacteristic = [characteristic retain];
			[peripheral readValueForCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:maximumTemperatureUUID]) { // Max Temperature.
            NSLog(@"Discovered Maximum Alarm Characteristic");
			maxTemperatureCharacteristic = [characteristic retain];
			[peripheral readValueForCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) { // Alarm
            NSLog(@"Discovered Alarm Characteristic");
			alarmCharacteristic = [characteristic retain];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:currentTemperatureUUID]) { // Current Temp
            NSLog(@"Discovered Temperature Characteristic");
			tempCharacteristic = [characteristic retain];
			[peripheral readValueForCharacteristic:tempCharacteristic];
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		} 
        else if ([[characteristic UUID] isEqual:anotherUUID]) { // other UUID
            NSLog(@"matches %@", kAnotherUUIDString);
			tempCharacteristic = [characteristic retain];
			[peripheral readValueForCharacteristic:tempCharacteristic]; //-- reads tempCharacteristic. callback is didUpdateValueForCharacteristic
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		} 
        else {
            [peripheral readValueForCharacteristic:characteristic]; //-- reads tempCharacteristic. callback funciton is didUpdateValueForCharacteristic
        }
        
        
	}
}



#pragma mark -
#pragma mark Characteristics interaction
/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/
- (void) writeLowAlarmTemperature:(int)low 
{
    NSLog(@"In function: writeLowAlarmTemp");

    NSData  *data	= nil;
    int16_t value	= (int16_t)low;
    
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
		return ;
    }

    if (!minTemperatureCharacteristic) {
        NSLog(@"No valid minTemp characteristic");
        return;
    }
    
    data = [NSData dataWithBytes:&value length:sizeof (value)];
    [servicePeripheral writeValue:data forCharacteristic:minTemperatureCharacteristic type:CBCharacteristicWriteWithResponse];
}


- (void) writeHighAlarmTemperature:(int)high
{
    NSLog(@"In function: writeHighAlarmTemp");

    NSData  *data	= nil;
    int16_t value	= (int16_t)high;

    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
    }

    if (!tempCharacteristic) {
        NSLog(@"No valid temp characteristic");
        return;
    }

    data = [NSData dataWithBytes:&value length:sizeof (value)];
    [servicePeripheral writeValue:data forCharacteristic:tempCharacteristic type:CBCharacteristicWriteWithResponse];
    
}


/** If we're connected, we don't want to be getting temperature change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kTemperatureServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:kCurrentTemperatureCharacteristicUUIDString]] ) {
                    
                    // And STOP getting notifications from it
                    [servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

/** Coming back from the background, we want to register for notifications again for the temperature changes */
- (void)enteredForeground
{
    
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kTemperatureServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:kCurrentTemperatureCharacteristicUUIDString]] ) {
                    
                    // And START getting notifications from it
                    [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (CGFloat) minimumTemperature
{
    NSLog(@"In function: minimumTemperature");

    CGFloat result  = NAN;
    int16_t value	= 0;
	
    if (minTemperatureCharacteristic) {
        [[minTemperatureCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}


- (CGFloat) maximumTemperature
{
    NSLog(@"In function: maximumTemperature");

    CGFloat result  = NAN;
    int16_t	value	= 0;
    
    if (maxTemperatureCharacteristic) {
        [[maxTemperatureCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}


- (CGFloat) temperature
{
    NSLog(@"In function: temperature");

    CGFloat result  = NAN;
    int16_t	value	= 0;

	if (tempCharacteristic) {
        [[tempCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}


- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"In function: didUpdateValueForCharacteristic");
    
    uint8_t alarmValue  = 0;
    uint8_t tempValue = 0;
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;         
	}
    
    [[characteristic value] getBytes:&tempValue length:sizeof (tempValue)];

    NSLog(@"characteristic value: %@", [characteristic value]);

    /* Temperature change */
    if ([[characteristic UUID] isEqual:currentTemperatureUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperature:self];
        return;
    }
    
    /* Alarm change */
    if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) {

        /* get the value for the alarm */
        [[alarmCharacteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];

        NSLog(@"alarm!  0x%x", alarmValue);
        if (alarmValue & 0x01) {
            /* Alarm is firing */
            if (alarmValue & 0x02) {
                [peripheralDelegate alarmService:self didSoundAlarmOfType:kAlarmLow];
			} else {
                [peripheralDelegate alarmService:self didSoundAlarmOfType:kAlarmHigh];
			}
        } else {
            [peripheralDelegate alarmServiceDidStopAlarm:self];
        }

        return;
    }

    /* Upper or lower bounds changed */
    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"In function: didWriteValueForCharacteristic");

    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
    /* Upper or lower bounds changed */
    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
    }
}
@end
