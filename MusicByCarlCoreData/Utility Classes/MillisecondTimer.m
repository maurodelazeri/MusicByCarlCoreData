//
//  MillisecondTimer.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 2/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#include <mach/mach_time.h>

#import "MillisecondTimer.h"

@implementation MillisecondTimer
{
    uint64_t startTime;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        startTime = [MillisecondTimer getTickCount];
    }
    
    return self;
}

+ (uint64_t) getTickCount
{
    static mach_timebase_info_data_t sTimebaseInfo;
    
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Convert the mach time to milliseconds
    uint64_t millis = ((machTime * sTimebaseInfo.numer) / 1000000) / sTimebaseInfo.denom;
    
    return millis;
}

- (uint64_t)returnMillisecondsSinceStart
{
    uint64_t currentTime = [MillisecondTimer getTickCount];
    
    return currentTime - startTime;
}

- (float)returnSecondsSinceStart
{
    uint64_t currentTime = [MillisecondTimer getTickCount];
    
    return (currentTime - startTime) / 1000.0f;
}

@end
