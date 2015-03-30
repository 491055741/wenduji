
#import "BLEService.h"
#import "BLEDiscovery.h"


NSString *kThermometerPeripheralUUID      = @"D907702A-E11C-111B-3D20-638806F80F2E";

NSString *kTemperatureServiceUUID         = @"00001C00-D102-11E1-9B23-000EFB0000A6";
NSString *kTemperatureCharacteristicUUID  = @"00001C0F-D102-11E1-9B23-000EFB0000A6";// notify    current temperature
NSString *kPreservedCharacteristicUUID    = @"00001C02-D102-11E1-9B23-000EFB0000A6";// read,write  not used for now

NSString *kDeviceInfoServiceUUID          = @"180A";

NSString *kBatteryServiceUUID             = @"180F";
NSString *kBatteryLevelCharacteristicUUID = @"2A19";// read, notify    current battery level


NSString *kServiceEnteredBackgroundNotification = @"kServiceEnteredBackgroundNotification";
NSString *kServiceEnteredForegroundNotification = @"kServiceEnteredForegroundNotification";

@interface BLEService() <CBPeripheralDelegate>

@property (nonatomic, assign) id<ThermometerProtocol>	peripheralDelegate;

@property (nonatomic, strong) CBService	*tempService;
@property (nonatomic, strong) NSString  *tempServiceUUID;
@property (nonatomic, strong) CBCharacteristic    *currentTemperatureCharacteristic;
@property (nonatomic, strong) CBUUID              *currentTemperatureUUID;

@property (nonatomic, strong) CBService	*batteryService;
@property (nonatomic, strong) NSString  *batteryServiceUUID;
@property (nonatomic, strong) CBCharacteristic    *batteryLevelCharacteristic;
@property (nonatomic, strong) CBUUID              *batteryLevelUUID;

@end



@implementation BLEService

#pragma mark -
#pragma mark Init
- (id)initWithPeripheral:(CBPeripheral *)peripheral controller:(id<ThermometerProtocol>)controller
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        [_peripheral setDelegate:self];
		self.peripheralDelegate     = controller;
        self.currentTemperatureUUID = [CBUUID UUIDWithString:kTemperatureCharacteristicUUID];
        self.batteryLevelUUID       = [CBUUID UUIDWithString:kBatteryLevelCharacteristicUUID];
    }
    return self;
}

- (void)reset
{
    self.peripheral = nil;
}

#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void)start
{
//	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kTemperatureServiceUUID];
//	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID, nil];

//    [servicePeripheral discoverServices:serviceArray];
    [_peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (peripheral != self.peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }

    for (CBService *service in [peripheral services]) {
        NSLog(@"%s %@[%@]", __func__, service, [[service UUID] UUIDString]);
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kTemperatureServiceUUID]]) {
            self.tempService = service;
            [peripheral discoverCharacteristics:@[_currentTemperatureUUID] forService:service];
        } else if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBatteryServiceUUID]]) {
            self.batteryService = service;
            [peripheral discoverCharacteristics:@[_batteryLevelUUID] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (peripheral != _peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }

    if (service != _batteryService && service != _tempService) {
        NSLog(@"Wrong Service.\n");
        return ;
    }

    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }

    NSArray *characteristics = [service characteristics];
    for (CBCharacteristic *characteristic in characteristics) {
        //        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        if ([[characteristic UUID] isEqual:_currentTemperatureUUID]) { // Current Temp
            NSLog(@"Discovered Temperature Characteristic");
            _currentTemperatureCharacteristic = characteristic;
            //			[peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([[characteristic UUID] isEqual:_batteryLevelUUID]) { // battery level
            NSLog(@"Discovered Battery Level Characteristic");
            _batteryLevelCharacteristic = characteristic;
            //			[peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}


#pragma mark -
#pragma mark Characteristics interaction

/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/


/** If we're connected, we don't want to be getting temperature change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    [_peripheral setNotifyValue:NO forCharacteristic:_batteryLevelCharacteristic];
    [_peripheral setNotifyValue:NO forCharacteristic:_currentTemperatureCharacteristic];
}

/** Coming back from the background, we want to register for notifications again for the temperature changes */
- (void)enteredForeground
{
   [_peripheral setNotifyValue:YES forCharacteristic:_batteryLevelCharacteristic];
   [_peripheral setNotifyValue:YES forCharacteristic:_currentTemperatureCharacteristic];
}

- (NSInteger)batteryLevel
{
    NSInteger result = 0;
    if (_batteryLevelCharacteristic) {
        NSString *str = [[NSString alloc] initWithData:_batteryLevelCharacteristic.value encoding:NSUTF8StringEncoding];
        result = [str intValue];
    }
    return result;
}

- (CGFloat)temperature
{
    CGFloat result = 0;
    if (_currentTemperatureCharacteristic) {
        NSString *str = [[NSString alloc] initWithData:_currentTemperatureCharacteristic.value encoding:NSUTF8StringEncoding];
        result = [str floatValue];
    }
    return result;
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* Temperature change */
    if ([[characteristic UUID] isEqual:_batteryLevelCharacteristic]) {
        //        NSLog(@"%s Character[%@] nofify value:[%@]", __FUNCTION__, [characteristic UUID], [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] );
        [self.peripheralDelegate ThermometerDidChangeBatteryLevel:self.batteryLevel];
        return;
    }

    /* Temperature change */
    if ([[characteristic UUID] isEqual:_currentTemperatureUUID]) {
        //        NSLog(@"%s Character[%@] nofify value:[%@]", __FUNCTION__, [characteristic UUID], [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] );
        [self.peripheralDelegate ThermometerDidChangeTemperature:self.temperature];
        return;
    }

}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
//    [peripheral readValueForCharacteristic:characteristic];
//    
//    /* Upper or lower bounds changed */
//    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
//        [peripheralDelegate ThermometerDidChangeTemperatureBounds:self];
//    }
}
@end

