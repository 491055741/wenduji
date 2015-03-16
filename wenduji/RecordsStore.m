//
//  RecordsStore.m
//  wenduji
//
//  Created by LiPeng on 3/14/15.
//
//

#import "RecordsStore.h"



@interface RecordsStore()


@end

@implementation RecordsStore

+ (id)sharedInstance
{
    static RecordsStore *this = nil;
    if (this == nil) {
        this = [[RecordsStore alloc] init];
    }
    return this;
}

- (id)init
{
    if (self = [super init]) {
        [self loadRecords];
    }
    return self;
}

- (void)loadRecords
{
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[VideoThumbImageView cacheFilePath]]) {
//        videoThumbCacheDict = [NSMutableDictionary dictionaryWithContentsOfFile:[VideoThumbImageView cacheFilePath]];
//    } else {
//        videoThumbCacheDict = [NSMutableDictionary dictionaryWithCapacity:4];
//    }
    self.recordsArray = [NSMutableArray arrayWithObjects:
                         [Record recordWithDate:[NSDate dateWithTimeIntervalSinceNow:-3600] temperature:[NSNumber numberWithFloat:37.2]],
                         [Record recordWithDate:[NSDate dateWithTimeIntervalSinceNow:-1800] temperature:[NSNumber numberWithFloat:37.1]],
                         [Record recordWithDate:[NSDate date] temperature:[NSNumber numberWithFloat:37.0]],
                          nil];
}

@end
