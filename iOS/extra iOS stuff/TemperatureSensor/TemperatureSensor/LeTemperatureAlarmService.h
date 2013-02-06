


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kTemperatureServiceUUIDString;                 // DEADF154-0000-0000-0000-0000DEADF154     Service UUID
extern NSString *kCurrentTemperatureCharacteristicUUIDString;   // CCCCFFFF-DEAD-F154-1319-740381000000     Current Temperature Characteristic
extern NSString *kMinimumTemperatureCharacteristicUUIDString;   // C0C0C0C0-DEAD-F154-1319-740381000000     Minimum Temperature Characteristic
extern NSString *kMaximumTemperatureCharacteristicUUIDString;   // EDEDEDED-DEAD-F154-1319-740381000000     Maximum Temperature Characteristic
extern NSString *kAlarmCharacteristicUUIDString;                // AAAAAAAA-DEAD-F154-1319-740381000000     Alarm Characteristic

extern NSString *kOtherUUIDString;   // 2A01


extern NSString *kAlarmServiceEnteredBackgroundNotification;
extern NSString *kAlarmServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LeTemperatureAlarmService;

typedef enum {
    kAlarmHigh  = 0,
    kAlarmLow   = 1,
} AlarmType;

@protocol LeTemperatureAlarmProtocol<NSObject>
- (void) alarmService:(LeTemperatureAlarmService*)service didSoundAlarmOfType:(AlarmType)alarm;
- (void) alarmServiceDidStopAlarm:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidChangeTemperature:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidChangeTemperatureBounds:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidChangeStatus:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidReset;
@end


/****************************************************************************/
/*						Temperature Alarm service.                          */
/****************************************************************************/
@interface LeTemperatureAlarmService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeTemperatureAlarmProtocol>)controller;
- (void) reset;
- (void) start;

/* Querying Sensor */
@property (readonly) CGFloat temperature;
@property (readonly) CGFloat minimumTemperature;
@property (readonly) CGFloat maximumTemperature;

/* Set the alarm cutoffs */
- (void) writeLowAlarmTemperature:(int)low;
- (void) writeHighAlarmTemperature:(int)high;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@end
