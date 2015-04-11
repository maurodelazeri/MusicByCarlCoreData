//
//  CurrentSongsInfo.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Songs.h"

@interface CurrentSongsInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber * currentSongIndex;
@property (nonatomic, strong) NSMutableOrderedSet *currentSongsList;
@property (nonatomic, strong) NSMutableOrderedSet *songsNeverPlayed;
@property (nonatomic, strong) NSMutableOrderedSet *songsOlderThanFourteenDays;
@property (nonatomic, strong) NSMutableOrderedSet *songsOlderThanSevenDays;
@property (nonatomic, strong) NSMutableOrderedSet *songsOlderThanThirtyDays;
@property (nonatomic, strong) NSMutableOrderedSet *songsOlderThanTwentyOneDays;
@property (nonatomic, strong) Songs *songsPtr;

// Singleton pointer given to other classes who access the AudioPlayback class
+ (CurrentSongsInfo *)sharedCurrentSongsInfo;

- (void)initOldSongsArrays;
- (void)resetCurrentSongsInfoArrays;

- (NSInteger)retrieveCurrentSongIndex;

- (NSMutableOrderedSet *)retrieveCurrentSongsList;
- (NSUInteger)retrieveCurrentSongsListCount;
- (NSInteger)currentSongListIndexOfInternalId: (NSNumber *)songInternalId;
- (NSNumber *)currentSongListObjectAtIndex: (NSInteger)songIndex;
- (void)addCurrentSongListSong:(NSNumber *)songInternalId;
- (void)addAllCurrentSongListSongs:(NSMutableOrderedSet *)songInternalIds;
- (void)removeAllCurrentSongListSongs;

- (NSUInteger)retrieveNeverPlayedSongsCount;
- (NSUInteger)retrieveOlderThanThirtySongsCount;
- (NSUInteger)retrieveOlderThanTwentyOneSongsCount;
- (NSUInteger)retrieveOlderThanFourteenSongsCount;
- (NSUInteger)retrieveOlderThanSevenSongsCount;

- (void)updateCurrentSongIndex: (NSInteger)newValue;

- (NSNumber *)songsNeverPlayedObjectAtIndex: (NSInteger)newSongIndex;
- (void)addNeverPlayedSong:(NSNumber *)songInternalId;
- (void)removeNeverPlayedSong:(NSNumber *)songInternalId;
- (void)removeAllNeverPlayedSongs;

- (NSNumber *)songsOlderThanThirtyDaysObjectAtIndex: (NSInteger)newSongIndex;
- (void)addOlderThanThirtyDaysSong:(NSNumber *)songInternalId;
- (void)removeOlderThanThirtyDaysSong:(NSNumber *)songInternalId;
- (void)removeAllOlderThanThirtyDaysSongs;

- (NSNumber *)songsOlderThanTwentyOneDaysObjectAtIndex: (NSInteger)newSongIndex;
- (void)addOlderThanTwentyOneDaysSong:(NSNumber *)songInternalId;
- (void)removeOlderThanTwentyOneDaysSong:(NSNumber *)songInternalId;
- (void)removeAllOlderThanTwentyOneDaysSongs;

- (NSNumber *)songsOlderThanFourteenDaysObjectAtIndex: (NSInteger)newSongIndex;
- (void)addOlderThanFourteenDaysSong:(NSNumber *)songInternalId;
- (void)removeOlderThanFourteenDaysSong:(NSNumber *)songInternalId;
- (void)removeAllOlderThanFourteenDaysSongs;

- (NSNumber *)songsOlderThanSevenDaysObjectAtIndex: (NSInteger)newSongIndex;
- (void)addOlderThanSevenDaysSong:(NSNumber *)songInternalId;
- (void)removeOlderThanSevenDaysSong:(NSNumber *)songInternalId;
- (void)removeAllOlderThanSevenDaysSongs;

- (void)archiveData;

@end
