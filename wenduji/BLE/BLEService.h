
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kThermometerPeripheralUUID;

extern NSString *kServiceEnteredBackgroundNotification;
extern NSString *kServiceEnteredForegroundNotification;

extern NSString *kTemperatureServiceUUID;
extern NSString *kTemperatureCharacteristicUUID;
extern NSString *kBatteryLevelServiceUUID;
extern NSString *kBatteryLevelCharacteristicUUID;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BLEService;


@protocol ThermometerProtocol<NSObject>
@optional
- (void)ThermometerDidChangeTemperature:(CGFloat)temperature;
- (void)ThermometerDidChangeBatteryLevel:(NSInteger)batteryLevel;
- (void)ThermometerDidChangeStatus:(BLEService*)service;
- (void)ThermometerDidReset;

@end


@interface BLEService : NSObject

- (id)initWithPeripheral:(CBPeripheral *)peripheral controller:(id<ThermometerProtocol>)controller;
- (void)reset;
- (void)start;

- (void)enteredBackground;
- (void)enteredForeground;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (readonly) CGFloat temperature;
@property (readonly) NSInteger batteryLevel;

@end



