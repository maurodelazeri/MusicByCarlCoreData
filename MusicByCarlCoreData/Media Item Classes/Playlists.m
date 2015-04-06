//
//  Playlists.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/3/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <tgmath.h>

#import <MediaPlayer/MediaPlayer.h>

#import "Playlists.h"
#import "Songs.h"
#import "Utilities.h"
#import "Logger.h"

@interface Playlists()
{
    Songs *songsPtr;
    NSArray *playlists;
}
@end

@implementation Playlists

- (id)init
{
    self = [super init];
    
    if (self)
    {
        songsPtr = [Songs sharedSongs];
    }
    
    return self;
}

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (Playlists *)sharedPlaylists
{
    static dispatch_once_t pred = 0;
    __strong static Playlists *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[Playlists alloc] init];
    });
    return _sharedObject;
}

- (NSUInteger)numberOfPlaylistsInDatabase
{
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    return [databaseInterfacePtr countOfEntitiesOfType:@"Playlist" withFetchRequestChangeBlock:nil];
}

- (Playlist *)fetchPlaylistWithInternalID: (NSInteger)playlistInternalID
{
    Playlist *playlist = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *playlistObjects = [databaseInterfacePtr entitiesOfType:@"Playlist" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:playlistInternalID]]];
                                return inputFetchRequest;
                            }
                            ];
    
    if (playlistObjects.count == 1)
    {
        playlist = (Playlist *)[playlistObjects objectAtIndex:0];
    }
    
    return playlist;
}

- (NSArray *)getPlaylistSongs: (NSString *)playlistTitle withPlaylistIndex: (NSInteger)playlistIndex
{
    MPMediaQuery *playlistQuery = [MPMediaQuery playlistsQuery];
    MPMediaPropertyPredicate *playlistPredicate = [MPMediaPropertyPredicate predicateWithValue: playlistTitle forProperty: MPMediaPlaylistPropertyName];
    [playlistQuery addFilterPredicate:playlistPredicate];
    
    MPMediaPlaylist *playlist = [playlists objectAtIndex:playlistIndex];
    NSArray *playlistSongs = playlist.items;
    
    return playlistSongs;
}

- (NSUInteger)getTotalPlaylistsSongCount
{
    MPMediaPlaylist *currentPlaylist;
    NSUInteger totalSongCount = 0;
    
    for (int i = 0; i < playlists.count; i++)
    {
        currentPlaylist = [playlists objectAtIndex:i];
        totalSongCount += currentPlaylist.count;
    }
    
    return totalSongCount;
}

- (NSString *)playbackDurationToString: (NSNumber *)playbackDuration
{
    NSTimeInterval duration = round( [playbackDuration doubleValue] );
    
    NSTimeInterval durationMinutes = floor(duration / 60l);
    NSTimeInterval durationSeconds = duration - (60l * durationMinutes);
    
    NSString *returnValue;
    
    if (durationSeconds < 10l)
    {
        returnValue = [NSString stringWithFormat:@"%.0f:0%.0f", durationMinutes, durationSeconds];
    }
    else
    {
        returnValue = [NSString stringWithFormat:@"%.0f:%.0f", durationMinutes, durationSeconds];
    }
    
    return returnValue;
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
- (void)fillDatabasePlaylistsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface
{
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    playlists = [playlistsQuery collections];

    MPMediaPlaylist *currentPlaylist;
    NSString *playlistTitle;

    Playlist *currentPlaylistObject;
    NSArray *playlistSongs;

    MPMediaItem *currentSong;
    uint64_t currentSongPersistentId;
    Song *currentSongObject;
    NSString *currentSongTitle;
    
    float progressFraction;
    
    NSUInteger currentSongIndex = 0;
    NSUInteger totalPlaylistSongCount = [self getTotalPlaylistsSongCount];
    
    for (int i = 0; i < playlists.count; i++)
    {
        currentPlaylist = [playlists objectAtIndex:i];
        playlistTitle = [currentPlaylist valueForProperty:MPMediaPlaylistPropertyName];
        
        currentPlaylistObject = (Playlist *)[databaseInterface newManagedObjectOfType:@"Playlist"];
        
        if (currentPlaylistObject == nil)
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"currentPlaylistObject == nil"]];
        }
        
        currentPlaylistObject.title = playlistTitle;
        currentPlaylistObject.internalID = [NSNumber numberWithInt:i];
        
        playlistSongs = [self getPlaylistSongs:playlistTitle withPlaylistIndex:i];
        
        for (int j = 0; j < playlistSongs.count; j++)
        {
            currentSong = [playlistSongs objectAtIndex:j];
            currentSongPersistentId = [[currentSong valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
            currentSongTitle = [currentSong valueForProperty:MPMediaItemPropertyTitle];
            
            currentSongObject = [songsPtr fetchSongBySongPersistentID:currentSongPersistentId withDatabasePtr:databaseInterface];
            
            if (currentSongObject != nil)
            {
                [currentPlaylistObject addPlaylistSongsObject:currentSongObject];
            }
            
            if (currentSongIndex % 30 == 0 || currentSongIndex == totalPlaylistSongCount - 1)
            {
                progressFraction = (currentSongIndex + 1) / (float)totalPlaylistSongCount;
                [Utilities sendProgressNotification:progressFraction forOperationType:@"Playlist" duringBuildAll:duringBuildAll];
            }
            
            currentSongIndex++;
        }
        
        [databaseInterface saveContext];
    }
}

@end
