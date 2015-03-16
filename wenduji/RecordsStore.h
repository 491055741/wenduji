//
//  RecordsStore.h
//  wenduji
//
//  Created by LiPeng on 3/14/15.
//
//

#import <Foundation/Foundation.h>
#import "Record.h"

@interface RecordsStore : NSObject
@property (nonatomic, strong) NSMutableArray *recordsArray;

+ (id)sharedInstance;

@end
