
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kAntiLostPeripheralUUIDString;
extern NSString *kAntiLostServiceUUIDString;                 // DEADF154-0000-0000-0000-0000DEADF154     Service UUID
extern NSString *kCurrentTemperatureCharacteristicUUIDString;   // CCCCFFFF-DEAD-F154-1319-740381000000     Current Temperature Characteristic
extern NSString *kMinimumTemperatureCharacteristicUUIDString;   // C0C0C0C0-DEAD-F154-1319-740381000000     Minimum Temperature Characteristic
extern NSString *kMaximumTemperatureCharacteristicUUIDString;   // EDEDEDED-DEAD-F154-1319-740381000000     Maximum Temperature Characteristic
extern NSString *kAlarmCharacteristicUUIDString;                // AAAAAAAA-DEAD-F154-1319-740381000000     Alarm Characteristic

extern NSString *kAlarmServiceEnteredBackgroundNotification;
extern NSString *kAlarmServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BLEService;

typedef enum {
    kAlarmHigh  = 0,
    kAlarmLow   = 1,
} AlarmType;

@protocol BLEAlarmProtocol<NSObject>
@optional
- (void) alarmService:(BLEService*)service didSoundAlarmOfType:(AlarmType)alarm;
- (void) alarmServiceDidStopAlarm:(BLEService*)service;
- (void) alarmServiceDidChangeTemperature:(BLEService*)service;
- (void) alarmServiceDidChangeTemperatureBounds:(BLEService*)service;
- (void) alarmServiceDidChangeStatus:(BLEService*)service;
- (void) alarmServiceDidReset;
- (void) alarmService:(BLEService*)service didUpdateRSSI:(NSNumber *)RSSI;
@end


/****************************************************************************/
/*						Temperature Alarm service.                          */
/****************************************************************************/
@interface BLEService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<BLEAlarmProtocol>)controller;
- (void) reset;
- (void) start;

/* Querying Sensor */
@property (readonly) CGFloat temperature;
@property (readonly) CGFloat minimumTemperature;
@property (readonly) CGFloat maximumTemperature;

/* Set the alarm cutoffs */
- (void) writeLowAlarmTemperature:(int)low;
- (void) writeHighAlarmTemperature:(int)high;

- (void)readRSSI;
/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@end
