//
//  SongInternalId.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "SongInternalId.h"
#import "CurrentSongsInfo.h"

@implementation SongInternalId

@dynamic internalID;
@dynamic inCurrentSongsList;
@dynamic inSongsOlderThanFourteenDays;
@dynamic inSongsOlderThanSevenDays;
@dynamic inSongsOlderThanThirtyDays;
@dynamic inSongsOlderThanTwentyOneDays;

+ (SongInternalId *)fetchSongInternalIdObjectWithInternalID: (NSNumber *)songInternalID {
    SongInternalId *returnValue = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *songInternalIdObjects = [databaseInterfacePtr entitiesOfType:@"SongInternalId" withFetchRequestChangeBlock:
                                      ^NSFetchRequest *(NSFetchRequest *inputFetchRequest) {
                                          [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", songInternalID]];
                                          return inputFetchRequest;
                                      }];
    
    if (songInternalIdObjects.count == 1) {
        returnValue = (SongInternalId *)[songInternalIdObjects objectAtIndex:0];
    }
    
    return returnValue;
}

+ (void)createSongInternalIdObjectFromInternalID: (NSNumber *)songInternalID withDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr {
    SongInternalId *songInternalId  = [self fetchSongInternalIdObjectWithInternalID:songInternalID];
    
    if (!songInternalId) {
        songInternalId = (SongInternalId *)[databaseInterfacePtr newManagedObjectOfType:@"SongInternalId"];
        songInternalId.internalID = songInternalID;
    }
}

@end
