//
//  SongInternalId.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DatabaseInterface.h"

@class CurrentSongsInfo;

@interface SongInternalId : NSManagedObject

@property (nonatomic, retain) NSNumber * internalID;
@property (nonatomic, retain) CurrentSongsInfo *inCurrentSongsList;
@property (nonatomic, retain) CurrentSongsInfo *inSongsOlderThanFourteenDays;
@property (nonatomic, retain) CurrentSongsInfo *inSongsOlderThanSevenDays;
@property (nonatomic, retain) CurrentSongsInfo *inSongsOlderThanThirtyDays;
@property (nonatomic, retain) CurrentSongsInfo *inSongsOlderThanTwentyOneDays;

+ (SongInternalId *)fetchSongInternalIdObjectWithInternalID: (NSNumber *)songInternalID;
+ (void)createSongInternalIdObjectFromInternalID: (NSNumber *)songInternalID withDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr;

@end
