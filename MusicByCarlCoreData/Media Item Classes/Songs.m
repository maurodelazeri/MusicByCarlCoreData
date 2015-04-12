//
//  Songs.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "DatabaseInterface.h"
#import "Artist.h"
#import "Song.h"
#import "Songs.h"
#import "CurrentSongsInfo.h"

#import "Utilities.h"
#import "Logger.h"
#import "MillisecondTimer.h"

@implementation Songs

- (Artists *)artistsPtr
{
    if (!_artistsPtr)
    {
        _artistsPtr = [Artists sharedArtists];
    }
    
    return _artistsPtr;
}

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (Songs *)sharedSongs
{
    static dispatch_once_t pred = 0;
    __strong static Songs *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[Songs alloc] init];
    });
    return _sharedObject;
}

- (NSMutableOrderedSet *)fetchAllSongInternalIDs
{
    NSMutableOrderedSet *returnValue = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *songObjects = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setResultType:NSDictionaryResultType];
                                [inputFetchRequest setReturnsDistinctResults:YES];
                                [inputFetchRequest setPropertiesToFetch:@[@"internalID"]];
                                
                                return inputFetchRequest;
                            }
                            ];
    
    if (songObjects.count > 0)
    {
        returnValue = [[NSMutableOrderedSet alloc] initWithCapacity:songObjects.count];
        NSDictionary *currentSong;
        NSNumber *songInternalID;
        
        for (int i = 0; i < songObjects.count; i++)
        {
            currentSong = [songObjects objectAtIndex:i];
            songInternalID = [currentSong objectForKey:@"internalID"];
            [returnValue addObject:songInternalID];
        }
    }
    
    return returnValue;
}

- (NSDictionary *)fetchSongTitleAndArtistWithInternalID: (NSInteger)songInternalID
{
    NSDictionary *songTitleAndArtist = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *songObjects = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:
        ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
        {
            [inputFetchRequest setResultType:NSDictionaryResultType];
            [inputFetchRequest setReturnsDistinctResults:YES];
            [inputFetchRequest setPropertiesToFetch:@[@"songTitle", @"artist"]];
            
            [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:songInternalID]]];
            return inputFetchRequest;
        }
        ];
    
    if (songObjects.count == 1)
    {
        songTitleAndArtist = [songObjects objectAtIndex:0];
    }
    
    return songTitleAndArtist;
}

- (Song *)fetchSongWithInternalID: (NSInteger)songInternalID
{
    Song *song = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *songObjects = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:
        ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
        {
            [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:songInternalID]]];
            return inputFetchRequest;
        }
    ];
    
    if (songObjects.count == 1)
    {
        song = (Song *)[songObjects objectAtIndex:0];
    }
    
    return song;
}

- (NSDate *)fetchSongLastPlayedTimeWithInternalID: (NSInteger)songInternalID
{
    NSDate *lastPlayedTime = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *songObjects = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:songInternalID]]];
                                [inputFetchRequest setIncludesSubentities: NO];
                                [inputFetchRequest setPropertiesToFetch: @[@"lastPlayedTime"]];
                                [inputFetchRequest setResultType: NSDictionaryResultType];
                                return inputFetchRequest;
                            }
                            ];
    
    if (songObjects.count == 1)
    {
        NSDictionary *songDictionary = (NSDictionary *)[songObjects objectAtIndex:0];
        lastPlayedTime = [songDictionary objectForKey:@"lastPlayedTime"];
    }
    
    return lastPlayedTime;
}

- (NSArray *)fetchSongsLastPlayedTimesWithInternalIDs: (NSOrderedSet *)songsInternalIDs
{
    NSArray *songDictionaries = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    songDictionaries = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(internalID IN %@)", songsInternalIDs]];
                                [inputFetchRequest setIncludesSubentities: NO];
                                [inputFetchRequest setPropertiesToFetch: @[@"internalID", @"lastPlayedTime"]];
                                [inputFetchRequest setResultType: NSDictionaryResultType];
                                return inputFetchRequest;
                            }
                            ];
    
    return songDictionaries;
}

- (Song *)fetchSongBySongPersistentID: (uint64_t)persistentID withDatabasePtr: (DatabaseInterface *)databaseInterface
{
    Song *song = nil;
    
    NSArray *songObjects = [databaseInterface entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"persistentID == %llu", persistentID]];
                                return inputFetchRequest;
                            }
                            ];
    
    if (songObjects.count == 1)
    {
        song = (Song *)[songObjects objectAtIndex:0];
    }
    
    return song;
}

- (Song *)fetchSongBySongTitle: (NSString *)title albumTitle: (NSString *)albumTitle andArtist: (NSString *)artist withDatabasePtr: (DatabaseInterface *)databaseInterface
{
    Song *song = nil;
    
    NSArray *songObjects = [databaseInterface entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(songTitle == %@) AND (albumTitle == %@) AND (artist == %@)", title, albumTitle, artist]];
                                return inputFetchRequest;
                            }
                            ];
    
    if (songObjects.count == 1)
    {
        song = (Song *)[songObjects objectAtIndex:0];
    }
    
    return song;
}

-(NSArray *)fetchAllArtistsFromSongs: (NSArray *)songsArray withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] init];
    
    Song *currentSong;
    Artist *currentArtist;
    NSString *currentSongArtistName;
    
    for (int i = 0; i < songsArray.count; i++)
    {
        currentSong = [songsArray objectAtIndex:i];
        currentSongArtistName = currentSong.albumArtist;
        currentArtist = [self.artistsPtr fetchArtistWithName:currentSongArtistName withDatabasePtr:(DatabaseInterface *)databaseInterface];
        if (currentArtist != nil && ![returnValue containsObject:currentArtist])
        {
            [returnValue addObject:currentArtist];
        }
    }
    
    return returnValue;
}

- (NSUInteger)numberOfSongsInDatabase
{
    DatabaseInterface *databaseInterface = [[DatabaseInterface alloc] init];
    return [databaseInterface countOfEntitiesOfType:@"Song" withFetchRequestChangeBlock:nil];
}

-(Song *) findSongWithTitle: (NSString *)songTitle fromAlbum:(NSString *)albumTitle byArtist:(NSString *)artist andAlbumArtist:(NSString *)albumArtist withTrackNumber:(NSNumber *)trackNumber withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    Song *song = nil;
    
    NSArray *songObjects = [databaseInterface entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(songTitle == %@) AND (albumTitle == %@) AND (artist == %@) AND (albumArtist == %@) AND (trackNumber == %d)", songTitle, albumTitle, artist, albumArtist, trackNumber.integerValue]];
                                return inputFetchRequest;
                            }
                            ];
    
    if (songObjects.count == 1)
    {
        song = (Song *)[songObjects objectAtIndex:0];
    }
    
    return song;
}

- (NSArray *)getNonzeroPlayedTimeSongsWithDatabasePtr:(DatabaseInterface *)databaseInterfacePtr
{
    NSArray *songsArray = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                                   {
                                       [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"lastPlayedTime != %@", [NSDate dateWithTimeIntervalSince1970:0]]];
                                       return inputFetchRequest;
                                   }];
    
    return songsArray;
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
- (NSMutableArray *)returnAllSongsLastPlayedTimes
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] init];
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *songsArray = [databaseInterfacePtr entitiesOfType:@"Song" withFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                           {
                               [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"lastPlayedTime != %@", [NSDate dateWithTimeIntervalSince1970:0]]];
                               [inputFetchRequest setPropertiesToFetch:@[@"songTitle", @"artist", @"albumTitle", @"lastPlayedTime"]];
                               NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastPlayedTime" ascending:NO];
                               [inputFetchRequest setSortDescriptors:@[sortDescriptor]];
                               return inputFetchRequest;
                           }];

    Song *currentSong;
    NSDictionary *currentSongDictionary;
    
    for (int i = 0; i < songsArray.count; i++)
    {
        currentSong = (Song *)[songsArray objectAtIndex:i];
        currentSongDictionary = @{@"songTitle": currentSong.songTitle,
                                  @"albumTitle": currentSong.albumTitle,
                                  @"artist": currentSong.artist,
                                  @"albumArtist": currentSong.albumArtist,
                                  @"trackNumber": currentSong.trackNumber,
                                  @"lastPlayedTime": currentSong.lastPlayedTime};
        [returnValue addObject:currentSongDictionary];
    }
     
    return returnValue;
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
- (void)restoreLastPlayedTimesWithDatabasePtr:(DatabaseInterface *)databaseInterface
{
    NSDictionary *currentSong;
    Song *songInDatabase;
    int songsFound = 0;
    
    NSArray *lastPlayedTimesArray = [[CurrentSongsInfo sharedCurrentSongsInfo] returnSongsLastPlayedTimesArray];
    
    for (int i = 0; i < lastPlayedTimesArray.count; i++)
    {
        currentSong = [lastPlayedTimesArray objectAtIndex:i];
        songInDatabase = [self findSongWithTitle:[currentSong objectForKey:@"songTitle"] fromAlbum:[currentSong objectForKey:@"albumTitle"] byArtist:[currentSong objectForKey:@"artist"] andAlbumArtist:[currentSong objectForKey:@"albumArtist"] withTrackNumber:[currentSong objectForKey:@"trackNumber"] withDatabasePtr:databaseInterface];
        if (songInDatabase != nil)
        {
            [songInDatabase updateLastPlayedTime:[currentSong objectForKey:@"lastPlayedTime"] withDatabasePtr:databaseInterface];
            songsFound++;
        }
    }
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
-(void)fillDatabaseSongsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    MPMediaItem *currentMediaItem;
    
    Song *currentSong;
    
    float progressFraction;
    
    // Fill in the all songs array with all the songs in the user's media library
    MPMediaQuery *allSongsQuery = [MPMediaQuery songsQuery];
    self.mediaLibrarySongsArray = [allSongsQuery items];
    
    for (int i = 0; i < self.mediaLibrarySongsArray.count; i++)
    {
        currentMediaItem = [self.mediaLibrarySongsArray objectAtIndex:i];
        currentSong = (Song *)[databaseInterface newManagedObjectOfType:@"Song"];
        
        if (currentSong == nil)
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"currentSong == nil"]];
        }
        else
        {
            currentSong.internalID = [NSNumber numberWithInt:i];
            currentSong.persistentID = [currentMediaItem valueForProperty:MPMediaItemPropertyPersistentID];
            currentSong.albumPersistentID = [currentMediaItem valueForProperty:MPMediaItemPropertyAlbumPersistentID];
            currentSong.assetURL = [NSKeyedArchiver archivedDataWithRootObject:[currentMediaItem valueForProperty:MPMediaItemPropertyAssetURL]];
            
            currentSong.songTitle = [currentMediaItem valueForProperty:MPMediaItemPropertyTitle];
            currentSong.indexCharacter = [Utilities getMediaObjectIndexCharacter:currentSong.songTitle];
            currentSong.strippedSongTitle = [Utilities getMediaObjectStrippedString:currentSong.songTitle];
            
            currentSong.genre = [currentMediaItem valueForProperty:MPMediaItemPropertyGenre];
            currentSong.artist = [currentMediaItem valueForProperty:MPMediaItemPropertyArtist];
            currentSong.albumArtist = [currentMediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
            
            currentSong.albumTitle = [currentMediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            currentSong.duration = [currentMediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            currentSong.trackNumber = [currentMediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
            currentSong.lastPlayedTime = [NSDate dateWithTimeIntervalSince1970:0];
            
            [databaseInterface saveContext];
        }
        
        if (i % 20 == 0 || i == self.mediaLibrarySongsArray.count - 1)
        {
            progressFraction = (i + 1) / (float)self.mediaLibrarySongsArray.count;
            [Utilities sendProgressNotification:progressFraction forOperationType:@"Song" duringBuildAll:duringBuildAll];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.AllSongsTableNeedsReloadNotification" object:self userInfo:nil];
}

@end
