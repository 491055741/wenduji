
#import "BLEService.h"
#import "BLEDiscovery.h"


NSString *kAntiLostPeripheralUUIDString = @"5BE97542-E1BD-8A1C-EFC1-2EC0B14A9BB8";

NSString *kAntiLostServiceUUIDString = @"5BE97542-E1BD-8A1C-EFC1-2EC0B14A9BB8";//@"DEADF154-0000-0000-0000-0000DEADF154";
NSString *kCurrentTemperatureCharacteristicUUIDString = @"CCCCFFFF-DEAD-F154-1319-740381000000";
NSString *kMinimumTemperatureCharacteristicUUIDString = @"C0C0C0C0-DEAD-F154-1319-740381000000";
NSString *kMaximumTemperatureCharacteristicUUIDString = @"EDEDEDED-DEAD-F154-1319-740381000000";
NSString *kAlarmCharacteristicUUIDString = @"AAAAAAAA-DEAD-F154-1319-740381000000";

NSString *kAlarmServiceEnteredBackgroundNotification = @"kAlarmServiceEnteredBackgroundNotification";
NSString *kAlarmServiceEnteredForegroundNotification = @"kAlarmServiceEnteredForegroundNotification";

@interface BLEService() <CBPeripheralDelegate> {
 @private
    CBPeripheral		*servicePeripheral;
    CBService			*antiLostService;
    
    CBCharacteristic    *tempCharacteristic;
    CBCharacteristic	*minTemperatureCharacteristic;
    CBCharacteristic    *maxTemperatureCharacteristic;
    CBCharacteristic    *alarmCharacteristic;
        
    CBUUID              *temperatureAlarmUUID;
    CBUUID              *minimumTemperatureUUID;
    CBUUID              *maximumTemperatureUUID;
    CBUUID              *currentTemperatureUUID;

    id<BLEAlarmProtocol>	peripheralDelegate;
}
@end



@implementation BLEService

@synthesize peripheral = servicePeripheral;
#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<BLEAlarmProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
//        minimumTemperatureUUID	= [[CBUUID UUIDWithString:kMinimumTemperatureCharacteristicUUIDString] retain];
//        maximumTemperatureUUID	= [[CBUUID UUIDWithString:kMaximumTemperatureCharacteristicUUIDString] retain];
//        currentTemperatureUUID	= [[CBUUID UUIDWithString:kCurrentTemperatureCharacteristicUUIDString] retain];
//        temperatureAlarmUUID	= [[CBUUID UUIDWithString:kAlarmCharacteristicUUIDString] retain];
	}
    return self;
}



- (void) reset
{
	if (servicePeripheral) {
//		[servicePeripheral release];
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
//	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kAntiLostServiceUUIDString];
//	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID, nil];

//    [servicePeripheral discoverServices:serviceArray];
    [servicePeripheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	NSArray		*uuids	= [NSArray arrayWithObjects:currentTemperatureUUID, // Current Temp
								   minimumTemperatureUUID, // Min Temp
								   maximumTemperatureUUID, // Max Temp
								   temperatureAlarmUUID, // Alarm Characteristic
								   nil];

	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}

	antiLostService = nil;
    
	for (CBService *service in services) {
        NSLog(@"%s %@[%@]", __func__, service, [[service UUID] UUIDString]);
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:kAntiLostServiceUUIDString]]) {
			antiLostService = service;
			break;
		}
	}

	if (antiLostService) {
		[peripheral discoverCharacteristics:uuids forService:antiLostService];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
	
	if (service != antiLostService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
		if ([[characteristic UUID] isEqual:minimumTemperatureUUID]) { // Min Temperature.
            NSLog(@"Discovered Minimum Alarm Characteristic");
			minTemperatureCharacteristic = characteristic;
			[peripheral readValueForCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:maximumTemperatureUUID]) { // Max Temperature.
            NSLog(@"Discovered Maximum Alarm Characteristic");
			maxTemperatureCharacteristic = characteristic;
			[peripheral readValueForCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) { // Alarm
            NSLog(@"Discovered Alarm Characteristic");
			alarmCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
		}
        else if ([[characteristic UUID] isEqual:currentTemperatureUUID]) { // Current Temp
            NSLog(@"Discovered Temperature Characteristic");
			tempCharacteristic = characteristic;
			[peripheral readValueForCharacteristic:tempCharacteristic];
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		} 
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"%s [%@] rssi:%@", __func__, peripheral.name, RSSI);
}

#pragma mark -
#pragma mark Characteristics interaction

- (void)readRSSI
{
    [servicePeripheral readRSSI];
}

/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/
- (void) writeLowAlarmTemperature:(int)low 
{
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
    NSData  *data	= nil;
    int16_t value	= (int16_t)high;

    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
    }

    if (!maxTemperatureCharacteristic) {
        NSLog(@"No valid minTemp characteristic");
        return;
    }

    data = [NSData dataWithBytes:&value length:sizeof (value)];
    [servicePeripheral writeValue:data forCharacteristic:maxTemperatureCharacteristic type:CBCharacteristicWriteWithResponse];
}


/** If we're connected, we don't want to be getting temperature change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kAntiLostServiceUUIDString]]) {
            
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
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kAntiLostServiceUUIDString]]) {
            
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
    uint8_t alarmValue  = 0;
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}

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
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
    /* Upper or lower bounds changed */
    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
    }
}
@end
