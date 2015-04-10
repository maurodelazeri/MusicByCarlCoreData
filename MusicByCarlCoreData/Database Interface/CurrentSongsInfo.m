//
//  CurrentSongsInfo.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "CurrentSongsInfo.h"
#import "CurrentSongsInfoArchive.h"
#import "MillisecondTimer.h"

#import "Utilities.h"
#import "Logger.h"

@implementation CurrentSongsInfo

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (CurrentSongsInfo *)sharedCurrentSongsInfo
{
    static dispatch_once_t pred = 0;
    __strong static CurrentSongsInfo *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CurrentSongsInfo alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self unarchiveData];
    }
    
    return self;
}

- (Songs *)songsPtr
{
    if (!_songsPtr)
    {
        _songsPtr = [Songs sharedSongs];
    }
    
    return _songsPtr;
}

- (NSString *)description {
    NSString *returnValue = [NSString stringWithFormat:@"\ncurrentSongIndex = %ld", (long)[self.currentSongIndex integerValue]];
    returnValue = [returnValue stringByAppendingFormat:@"\ncurrentSongsList.count = %lu", (unsigned long)self.currentSongsList.count];
    returnValue = [returnValue stringByAppendingFormat:@"\nsongsNeverPlayed.counts = %lu", (unsigned long)self.songsNeverPlayed.count];
    returnValue = [returnValue stringByAppendingFormat:@"\nsongsOlderThanThirtyDays.count = %lu", (unsigned long)self.songsOlderThanThirtyDays.count];
    returnValue = [returnValue stringByAppendingFormat:@"\nsongsOlderThanTwentyOneDays.count = %lu", (unsigned long)self.songsOlderThanTwentyOneDays.count];
    returnValue = [returnValue stringByAppendingFormat:@"\nsongsOlderThanFourteenDays.count = %lu", (unsigned long)self.songsOlderThanFourteenDays.count];
    returnValue = [returnValue stringByAppendingFormat:@"\nsongsOlderThanSevenDays.count = %lu", (unsigned long)self.songsOlderThanSevenDays.count];
    
    return returnValue;
}

- (void)unarchiveData
{
    NSMutableDictionary *unarchivedDictionary = [CurrentSongsInfoArchive unarchiveCurrentSongsInfo];
    if (unarchivedDictionary != nil) {
        _currentSongIndex = [unarchivedDictionary objectForKey:@"archivedCurrentSongIndex"];
        _currentSongsList = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchivedDictionary objectForKey:@"archivedCurrentSongsList"]];
        _songsNeverPlayed = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchivedDictionary objectForKey:@"archivedSongsNeverPlayed"]];
        _songsOlderThanThirtyDays = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchivedDictionary objectForKey:@"archivedSongsOlderThanThirtyDays"]];
        _songsOlderThanTwentyOneDays = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchivedDictionary objectForKey:@"archivedSongsOlderThanTwentyOneDays"]];
        _songsOlderThanFourteenDays = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchivedDictionary objectForKey:@"archivedSongsOlderThanFourteenDays"]];
        _songsOlderThanSevenDays = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchivedDictionary objectForKey:@"archivedSongsOlderThanSevenDays"]];
    }
}

- (void)archiveData
{
    [CurrentSongsInfoArchive archiveCurrentSongsInfo:self];
}

- (NSMutableOrderedSet *)currentSongsList {
    if (!_currentSongsList) {
        _currentSongsList = [[NSMutableOrderedSet alloc] init];
    }
    
    return _currentSongsList;
}

- (NSMutableOrderedSet *)songsNeverPlayed {
    if (!_songsNeverPlayed) {
        _songsNeverPlayed = [[NSMutableOrderedSet alloc] init];
    }
    
    return _songsNeverPlayed;
}

- (NSMutableOrderedSet *)songsOlderThanThirtyDays {
    if (!_songsOlderThanThirtyDays) {
        _songsOlderThanThirtyDays = [[NSMutableOrderedSet alloc] init];
    }
    
    return _songsOlderThanThirtyDays;
}

- (NSMutableOrderedSet *)songsOlderThanTwentyOneDays {
    if (!_songsOlderThanTwentyOneDays) {
        _songsOlderThanTwentyOneDays = [[NSMutableOrderedSet alloc] init];
    }
    
    return _songsOlderThanTwentyOneDays;
}

- (NSMutableOrderedSet *)songsOlderThanFourteenDays {
    if (!_songsOlderThanFourteenDays) {
        _songsOlderThanFourteenDays = [[NSMutableOrderedSet alloc] init];
    }
    
    return _songsOlderThanFourteenDays;
}

- (NSMutableOrderedSet *)songsOlderThanSevenDays {
    if (!_songsOlderThanSevenDays) {
        _songsOlderThanSevenDays = [[NSMutableOrderedSet alloc] init];
    }
    
    return _songsOlderThanSevenDays;
}

- (NSInteger)retrieveCurrentSongIndex {
    return [self.currentSongIndex integerValue];
}

- (NSMutableOrderedSet *)retrieveCurrentSongsList {
    return self.currentSongsList;
}

- (NSUInteger)retrieveCurrentSongsListCount {
    return self.currentSongsList.count;
}

- (NSInteger)currentSongListIndexOfInternalId: (NSNumber *)songInternalId {
    return [self.currentSongsList indexOfObject:songInternalId];
}

- (NSNumber *)currentSongListObjectAtIndex: (NSInteger)songIndex {
    return [self.currentSongsList objectAtIndex:songIndex];
}

- (void)addCurrentSongListSong:(NSNumber *)songInternalId {
    [self.currentSongsList addObject:songInternalId];
}

- (void)addAllCurrentSongListSongs:(NSMutableOrderedSet *)songInternalIds {
    for (NSNumber *songInternalId in songInternalIds) {
        [self.currentSongsList addObject:songInternalId];
    }
}

- (void)removeAllCurrentSongListSongs {
    [self.currentSongsList removeAllObjects];
}

- (NSUInteger)retrieveNeverPlayedSongsCount {
    return self.songsNeverPlayed.count;
}

- (NSUInteger)retrieveOlderThanThirtySongsCount {
    return self.songsOlderThanThirtyDays.count;
}

- (NSUInteger)retrieveOlderThanTwentyOneSongsCount {
    return self.songsOlderThanTwentyOneDays.count;
}

- (NSUInteger)retrieveOlderThanFourteenSongsCount {
    return self.songsOlderThanFourteenDays.count;
}

- (NSUInteger)retrieveOlderThanSevenSongsCount {
    return self.songsOlderThanSevenDays.count;
}

- (void)updateCurrentSongIndex: (NSInteger)newValue {
    self.currentSongIndex = [NSNumber numberWithInteger:newValue];
}

- (NSNumber *)songsNeverPlayedObjectAtIndex: (NSInteger)newSongIndex {
    return [self.songsNeverPlayed objectAtIndex:newSongIndex];
}

- (NSNumber *)songsOlderThanThirtyDaysObjectAtIndex: (NSInteger)newSongIndex {
    return [self.songsOlderThanThirtyDays objectAtIndex:newSongIndex];
}

- (void)addNeverPlayedSong:(NSNumber *)songInternalId {
    [self.songsNeverPlayed addObject:songInternalId];
}

- (void)addOlderThanThirtyDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanThirtyDays addObject:songInternalId];
}

- (void)removeNeverPlayedSong:(NSNumber *)songInternalId {
    [self.songsNeverPlayed removeObject:songInternalId];
}

- (void)removeOlderThanThirtyDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanThirtyDays removeObject:songInternalId];
}

- (void)removeAllNeverPlayedSongs {
    [self.songsNeverPlayed removeAllObjects];
}

- (void)removeAllOlderThanThirtyDaysSongs {
    [self.songsOlderThanThirtyDays removeAllObjects];
}

- (NSNumber *)songsOlderThanTwentyOneDaysObjectAtIndex: (NSInteger)newSongIndex {
    return [self.songsOlderThanTwentyOneDays objectAtIndex:newSongIndex];
}

- (void)addOlderThanTwentyOneDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanTwentyOneDays addObject:songInternalId];
}

- (void)removeOlderThanTwentyOneDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanTwentyOneDays removeObject:songInternalId];
}

- (void)removeAllOlderThanTwentyOneDaysSongs {
    [self.songsOlderThanTwentyOneDays removeAllObjects];
}

- (NSNumber *)songsOlderThanFourteenDaysObjectAtIndex: (NSInteger)newSongIndex {
    return [self.songsOlderThanFourteenDays objectAtIndex:newSongIndex];
}

- (void)addOlderThanFourteenDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanFourteenDays addObject:songInternalId];
}

- (void)removeOlderThanFourteenDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanFourteenDays removeObject:songInternalId];
}

- (void)removeAllOlderThanFourteenDaysSongs {
    [self.songsOlderThanFourteenDays removeAllObjects];
}

- (NSNumber *)songsOlderThanSevenDaysObjectAtIndex: (NSInteger)newSongIndex {
    return [self.songsOlderThanSevenDays objectAtIndex:newSongIndex];
}

- (void)addOlderThanSevenDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanSevenDays addObject:songInternalId];
}

- (void)removeOlderThanSevenDaysSong:(NSNumber *)songInternalId {
    [self.songsOlderThanSevenDays removeObject:songInternalId];
}

- (void)removeAllOlderThanSevenDaysSongs {
    [self.songsOlderThanSevenDays removeAllObjects];
}

- (void)resetCurrentSongsInfoArrays {
    [self removeAllCurrentSongListSongs];
    [self removeAllNeverPlayedSongs];
    [self removeAllOlderThanThirtyDaysSongs];
    [self removeAllOlderThanTwentyOneDaysSongs];
    [self removeAllOlderThanFourteenDaysSongs];
    [self removeAllOlderThanSevenDaysSongs];
}

- (void)initOldSongsArrays
{
    int songsNeverPlayedCount = 0;
    int songsOlderThanThirtyDaysCount = 0;
    int songsOlderThanTwentyOneDaysCount = 0;
    int songsOlderThanFourteenDaysCount = 0;
    int songsOlderThanSevenDaysCount = 0;
    
    NSOrderedSet *currentSongList = [self retrieveCurrentSongsList];
    
    if (currentSongList != nil) {
            NSArray *songDictionaries = [self.songsPtr fetchSongsLastPlayedTimesWithInternalIDs:currentSongList];
        
        NSNumber *songInternalID;
        NSDate *songLastPlayedTime;
        NSTimeInterval daysSinceLastPlay;
        NSDate *songNotPlayedDate = [NSDate dateWithTimeIntervalSince1970:0];
        Song *currentSong;
        
        for (NSDictionary *songDictionary in songDictionaries)
        {
            songInternalID = [songDictionary objectForKey:@"internalID"];
            songLastPlayedTime = [songDictionary objectForKey:@"lastPlayedTime"];
            
            if (songInternalID && songLastPlayedTime)
            {
                if ([songLastPlayedTime isEqualToDate:songNotPlayedDate])
                {
                    [self addNeverPlayedSong:songInternalID];
                    songsNeverPlayedCount++;
                }
                else
                {
                    currentSong = [self.songsPtr fetchSongWithInternalID:[songInternalID integerValue]];
                    daysSinceLastPlay = [songLastPlayedTime timeIntervalSinceNow] / secondsInADay;
                    
                    if (daysSinceLastPlay < -30.0)
                    {
                        [self addOlderThanThirtyDaysSong:songInternalID];
                        songsOlderThanThirtyDaysCount++;
                    }
                    else
                    {
                        if (daysSinceLastPlay < -21.0)
                        {
                            [self addOlderThanTwentyOneDaysSong:songInternalID];
                            songsOlderThanTwentyOneDaysCount++;
                        }
                        else
                        {
                            if (daysSinceLastPlay < -14.0)
                            {
                                [self addOlderThanFourteenDaysSong:songInternalID];
                                songsOlderThanFourteenDaysCount++;
                            }
                            else
                            {
                                if (daysSinceLastPlay < -7.0)
                                {
                                    [self addOlderThanSevenDaysSong:songInternalID];
                                    songsOlderThanSevenDaysCount++;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@end
