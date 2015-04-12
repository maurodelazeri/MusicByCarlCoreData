//
//  Songs.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Song.h"
#import "Artists.h"

@interface Songs : NSObject

// Singleton pointer given to other classes who access the Songs class
+ (Songs *)sharedSongs;

@property (strong, nonatomic) NSArray *mediaLibrarySongsArray; // of MPMediaItem

@property (strong, nonatomic) Artists *artistsPtr;

-(void)fillDatabaseSongsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr:(DatabaseInterface *)databaseInterface;

- (void)restoreLastPlayedTimesWithDatabasePtr:(DatabaseInterface *)databaseInterface;

- (NSUInteger)numberOfSongsInDatabase;
- (Song *)fetchSongWithInternalID: (NSInteger)songInternalID;
- (NSMutableArray *)returnAllSongsLastPlayedTimes;
- (NSDate *)fetchSongLastPlayedTimeWithInternalID: (NSInteger)songInternalID;
- (NSArray *)fetchSongsLastPlayedTimesWithInternalIDs: (NSOrderedSet *)songsInternalIDs;
- (NSDictionary *)fetchSongTitleAndArtistWithInternalID: (NSInteger)songInternalID;
- (Song *)fetchSongBySongPersistentID: (uint64_t)persistentID withDatabasePtr: (DatabaseInterface *)databaseInterface;
- (Song *)fetchSongBySongTitle: (NSString *)title albumTitle: (NSString *)albumTitle andArtist: (NSString *)artist withDatabasePtr: (DatabaseInterface *)databaseInterface;
-(NSArray *)fetchAllArtistsFromSongs: (NSArray *)songsArray withDatabasePtr:(DatabaseInterface *)databaseInterface;
- (NSMutableOrderedSet *)fetchAllSongInternalIDs;

@end
