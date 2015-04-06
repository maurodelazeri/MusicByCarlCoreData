//
//  CurrentSongsInfoArchive.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 2/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

#import "CurrentSongsInfoArchive.h"
#import "DatabaseInterface.h"
#import "Logger.h"

@implementation CurrentSongsInfoArchive

@dynamic archivedCurrentSongIndex;
@dynamic archivedCurrentSongsList;
@dynamic archivedSongsOlderThanFourteenDays;
@dynamic archivedSongsOlderThanSevenDays;
@dynamic archivedSongsOlderThanThirtyDays;
@dynamic archivedSongsOlderThanTwentyOneDays;
@dynamic archivedSongsNeverPlayed;

- (NSString *)description {
    NSString *returnValue = [NSString stringWithFormat:@"\narchivedCurrentSongIndex = %ld", (long)[self.archivedCurrentSongIndex integerValue]];
    NSMutableArray *archivedCurrentSongsList = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedCurrentSongsList];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedCurrentSongsList.count = %lu", (unsigned long)archivedCurrentSongsList.count];
    NSMutableArray *archivedSongsNeverPlayed = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedSongsNeverPlayed];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedSongsNeverPlayed.count = %lu", (unsigned long)archivedSongsNeverPlayed.count];
    NSMutableArray *archivedSongsOlderThanThirtyDays = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedSongsOlderThanThirtyDays];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedSongsOlderThanThirtyDays.count = %lu", (unsigned long)archivedSongsOlderThanThirtyDays.count];
    NSMutableArray *archivedSongsOlderThanTwentyOneDays = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedSongsOlderThanTwentyOneDays];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedSongsOlderThanTwentyOneDays.count = %lu", (unsigned long)archivedSongsOlderThanTwentyOneDays.count];
    NSMutableArray *archivedSongsOlderThanFourteenDays = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedSongsOlderThanFourteenDays];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedSongsOlderThanFourteenDays.count = %lu", (unsigned long)archivedSongsOlderThanFourteenDays.count];
    NSMutableArray *archivedSongsOlderThanSevenDays = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedSongsOlderThanSevenDays];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedSongsOlderThanSevenDays.count = %lu", (unsigned long)archivedSongsOlderThanSevenDays.count];
    
    return returnValue;
}

+ (void)archiveCurrentSongsInfo: (CurrentSongsInfo *)currentSongsInfo {
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    [databaseInterfacePtr deleteAllObjectsWithEntityName:@"CurrentSongsInfoArchive"];
    CurrentSongsInfoArchive *currentSongsInfoArchive = (CurrentSongsInfoArchive *)[databaseInterfacePtr newManagedObjectOfType:@"CurrentSongsInfoArchive"];
    currentSongsInfoArchive.archivedCurrentSongIndex = currentSongsInfo.currentSongIndex;
    
    currentSongsInfoArchive.archivedCurrentSongsList = [NSKeyedArchiver archivedDataWithRootObject:currentSongsInfo.currentSongsList];
    currentSongsInfoArchive.archivedSongsNeverPlayed = [NSKeyedArchiver archivedDataWithRootObject:currentSongsInfo.songsNeverPlayed];
    currentSongsInfoArchive.archivedSongsOlderThanThirtyDays = [NSKeyedArchiver archivedDataWithRootObject:currentSongsInfo.songsOlderThanThirtyDays];
    currentSongsInfoArchive.archivedSongsOlderThanTwentyOneDays = [NSKeyedArchiver archivedDataWithRootObject:currentSongsInfo.songsOlderThanTwentyOneDays];
    currentSongsInfoArchive.archivedSongsOlderThanFourteenDays = [NSKeyedArchiver archivedDataWithRootObject:currentSongsInfo.songsOlderThanFourteenDays];
    currentSongsInfoArchive.archivedSongsOlderThanSevenDays = [NSKeyedArchiver archivedDataWithRootObject:currentSongsInfo.songsOlderThanSevenDays];
    
    [databaseInterfacePtr saveContext];
}

+ (NSMutableDictionary *)unarchiveCurrentSongsInfo {
    NSMutableDictionary *returnValue = nil;
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *currentSongsInfoArchiveArray = [databaseInterfacePtr entitiesOfType:@"CurrentSongsInfoArchive" withFetchRequestChangeBlock:nil];
    
    if (currentSongsInfoArchiveArray != nil && currentSongsInfoArchiveArray.count == 1) {
        CurrentSongsInfoArchive *CurrentSongsInfoArchive = [currentSongsInfoArchiveArray objectAtIndex:0];
        returnValue = [[NSMutableDictionary alloc] init];
        [returnValue setObject:CurrentSongsInfoArchive.archivedCurrentSongIndex forKey:@"archivedCurrentSongIndex"];
        [returnValue setObject:CurrentSongsInfoArchive.archivedCurrentSongsList forKey:@"archivedCurrentSongsList"];
        [returnValue setObject:CurrentSongsInfoArchive.archivedSongsNeverPlayed forKey:@"archivedSongsNeverPlayed"];
        [returnValue setObject:CurrentSongsInfoArchive.archivedSongsOlderThanThirtyDays forKey:@"archivedSongsOlderThanThirtyDays"];
        [returnValue setObject:CurrentSongsInfoArchive.archivedSongsOlderThanTwentyOneDays forKey:@"archivedSongsOlderThanTwentyOneDays"];
        [returnValue setObject:CurrentSongsInfoArchive.archivedSongsOlderThanFourteenDays forKey:@"archivedSongsOlderThanFourteenDays"];
        [returnValue setObject:CurrentSongsInfoArchive.archivedSongsOlderThanSevenDays forKey:@"archivedSongsOlderThanSevenDays"];
    }
    
    return returnValue;
}

@end
