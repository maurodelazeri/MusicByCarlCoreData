//
//  CurrentSongsInfoArchive.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 2/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CurrentSongsInfo.h"

@interface CurrentSongsInfoArchive : NSManagedObject

@property (nonatomic, retain) NSNumber * archivedCurrentSongIndex;
@property (nonatomic, retain) NSData * archivedCurrentSongsList;
@property (nonatomic, retain) NSData * archivedSongsOlderThanFourteenDays;
@property (nonatomic, retain) NSData * archivedSongsOlderThanSevenDays;
@property (nonatomic, retain) NSData * archivedSongsOlderThanThirtyDays;
@property (nonatomic, retain) NSData * archivedSongsOlderThanTwentyOneDays;
@property (nonatomic, retain) NSData * archivedSongsNeverPlayed;

+ (void)archiveCurrentSongsInfo: (CurrentSongsInfo *)currentSongsInfo;
+ (NSMutableDictionary *)unarchiveCurrentSongsInfo;

@end
