//
//  MillisecondTimer.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 2/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MillisecondTimer : NSObject

- (uint64_t)returnMillisecondsSinceStart;
- (float)returnSecondsSinceStart;

@end
