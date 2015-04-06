//
//  Albums.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "DatabaseInterface.h"
#import "Album.h"
#import "Albums.h"
#import "AlbumTextLabelsData.h"
#import "Utilities.h"
#import "Songs.h"
#import "Logger.h"
#import "UserPreferences.h"
#import "GlobalVars.h"

#import "CurrentSongsInfo.h"

@interface Albums ()
{
    NSMutableOrderedSet *albumsArray; // of MPMediaItem
    UserPreferences *userPreferencesPtr;
}
@end

@implementation Albums

- (id)init
{
    self = [super init];
    
    if (self)
    {
        userPreferencesPtr = [UserPreferences sharedUserPreferences];
    }
    
    return self;
}

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (Albums *)sharedAlbums
{
    static dispatch_once_t pred = 0;
    __strong static Albums *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[Albums alloc] init];
    });
    return _sharedObject;
}

+ (Album *)fetchAlbumWithInternalID: (NSInteger)albumInternalID withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    Album *album = nil;
    
    NSArray *albumObjects = [databaseInterface entitiesOfType:@"Album" withFetchRequestChangeBlock:
                             ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                             {
                                 [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:albumInternalID]]];
                                 return inputFetchRequest;
                             }
                             ];
    
    if (albumObjects.count == 1)
    {
        album = (Album *)[albumObjects objectAtIndex:0];
    }
    
    return album;
}

+ (Album *)fetchAlbumWithPersitentID: (NSNumber *)persistentID withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    Album *album = nil;
    
    NSArray *albumObjects = [databaseInterface entitiesOfType:@"Album" withFetchRequestChangeBlock:
                             ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                             {
                                 [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"persistentID == %@", persistentID]];
                                 return inputFetchRequest;
                             }
                             ];
    
    if (albumObjects.count == 1)
    {
        album = (Album *)[albumObjects objectAtIndex:0];
    }
    
    return album;
}

- (NSArray *)fetchAlbumSongsByAlbumPersistentID: (uint64_t)persistentID withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    NSArray *songObjects = [databaseInterface entitiesOfType:@"Song" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"albumPersistentID == %llu", persistentID]];
                                return inputFetchRequest;
                            }
                            ];
    
    if (songObjects.count > 0)
    {
        songObjects = [songObjects sortedArrayUsingComparator:^NSComparisonResult(Song *a, Song *b)
                       {
                           return [a.trackNumber integerValue] > [b.trackNumber integerValue];
                       }];
    }
    else
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Zero songs returned for album with persistentID %llu", persistentID]];
    }
    
    return songObjects;
}

+ (Album *)fetchAlbumFromAlbumPersistentID: (uint64_t)persistentID {
    Album *returnValue = nil;
    
    return returnValue;
}

+ (Song *)fetchSongWithInternalID: (NSInteger)songInternalID andDatabasePtr:(DatabaseInterface *)databaseInterface
{
    Song *song = nil;
    
    NSArray *songObjects = [databaseInterface entitiesOfType:@"Song" withFetchRequestChangeBlock:
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

+ (UIImage *)fetchAlbumImageWithAlbumInternalID: (NSInteger)internalID withSize:(CGSize)albumArtSize andDatabasePtr:(DatabaseInterface *)databaseInterface
{
    UIImage *returnValue =  [UIImage imageNamed:@"No-album-artwork.png"];
    returnValue = [Utilities imageWithImage:returnValue convertToSize:albumArtSize];
    
    Album *album = [self fetchAlbumWithInternalID:internalID withDatabasePtr:databaseInterface];
    
    if (album)
    {
        MPMediaItemArtwork *localAlbumArtwork = [album albumArtworkFromPersistentID];
        if (localAlbumArtwork != nil)
        {
            returnValue = [localAlbumArtwork imageWithSize: CGSizeMake (320, 320)];
        }
    }
    
    return returnValue;
}

+ (AlbumTextLabelsData *)fetchAlbumTextDataWithAlbumInternalID: (NSInteger)internalID andDatabasePtr:(DatabaseInterface *)databaseInterface
{
    AlbumTextLabelsData *returnValue = [[AlbumTextLabelsData alloc] init];
    returnValue.albumTitleString = @"";
    returnValue.albumArtistString = @"";
    returnValue.songTitleString = @"";
    
    Album *album = [self fetchAlbumWithInternalID:internalID withDatabasePtr:databaseInterface];
    
    GlobalVars *globalVarsPtr = [GlobalVars sharedGlobalVars];
    
    Song *currentSong = [self fetchSongWithInternalID:globalVarsPtr.currentSong.integerValue andDatabasePtr:databaseInterface];
    
    if (album)
    {
        returnValue.albumTitleString = album.title;
        if (album.artist) {
            returnValue.albumArtistString = album.artist;
        }
        else {
            if (album.albumArtist) {
                returnValue.albumArtistString = album.albumArtist.name;
            }
        }
        
        if ([currentSong.albumTitle isEqualToString:album.title] &&
            [currentSong.albumArtist isEqualToString:album.albumArtist.name])
        {
            returnValue.songTitleString = currentSong.songTitle;
        }
    }
    
    return returnValue;
}

+ (NSUInteger)numberOfAlbumsInDatabase
{
    DatabaseInterface *databaseInterface = [[DatabaseInterface alloc] init];
    return [databaseInterface countOfEntitiesOfType:@"Album" withFetchRequestChangeBlock:nil];
}

-(NSString *)getAlbumReleaseYear: (MPMediaItem *)albumMediaItem
{
    NSNumber *yearNumber = [albumMediaItem valueForProperty:@"year"];
    
    if (yearNumber && [yearNumber isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"Released %i", [yearNumber intValue]];
    }
    else
    {
        return @"Unknown Release Year";
    }
}

- (NSString *)getAlbumPlaybackDuration: (NSArray *)albumTracks
{
    long playbackDuration = 0;

    for (MPMediaItem *track in albumTracks)
    {
        playbackDuration += [[track  valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    }

    long albumMimutes = (playbackDuration /60.0f);
    NSString *albumDuration;

    if (albumMimutes > 1)
    {
        albumDuration = [NSString stringWithFormat:@"%li Mins.", albumMimutes];
    }
    else
    {
        albumDuration = [NSString stringWithFormat:@"1 Min."];
    }
    
    return albumDuration;
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
- (void)fillDatabaseAlbumsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface
{
    NSError *error;

    MPMediaQuery *albumsQuery = [MPMediaQuery albumsQuery];

    NSArray *albumsCollection = [albumsQuery collections];
    
    albumsArray = [[NSMutableOrderedSet alloc] init];
    
    MPMediaItemCollection *currentMediaCollection;
    MPMediaItem *albumMediaItem;
    Album *currentAlbum;
    
    float progressFraction;
    
    for (int i = 0; i < albumsCollection.count; i++)
    {
        currentMediaCollection = [albumsCollection objectAtIndex:i];
        
        uint64_t albumPersistentID = [[currentMediaCollection valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
        
        albumMediaItem = [currentMediaCollection representativeItem];
        
        if (albumMediaItem != nil)
        {
            [albumsArray addObject:albumMediaItem];
            currentAlbum = (Album *)[databaseInterface newManagedObjectOfType:@"Album"];
            
            if (currentAlbum == nil)
            {
                [Logger writeToLogFile:[NSString stringWithFormat:@"currentAlbum == nil"]];
            }
            
            currentAlbum.internalID = [NSNumber numberWithInt:i];
            currentAlbum.title = [albumMediaItem valueForProperty: MPMediaItemPropertyAlbumTitle];
            currentAlbum.indexCharacter = [Utilities getMediaObjectIndexCharacter:currentAlbum.title];
            currentAlbum.strippedTitle = [Utilities getMediaObjectStrippedString:currentAlbum.title];
            
            currentAlbum.artist = [albumMediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
            currentAlbum.releaseYear = [self getAlbumReleaseYear:albumMediaItem];
            currentAlbum.durationString = [self getAlbumPlaybackDuration:currentMediaCollection.items];
            
            currentAlbum.persistentID = [NSNumber numberWithUnsignedLongLong:albumPersistentID];
            
            BOOL albumIsInstrumental = [userPreferencesPtr findInstrumentalAlbumWithTitle:currentAlbum.title andArtist:currentAlbum.artist];
            currentAlbum.isInstrumental = [NSNumber numberWithBool:albumIsInstrumental];
            
            NSArray *albumTracks = [self fetchAlbumSongsByAlbumPersistentID: albumPersistentID withDatabasePtr:databaseInterface];
            
            if (albumTracks.count == currentMediaCollection.items.count)
            {
                [currentAlbum addAlbumSongs:[NSOrderedSet orderedSetWithArray:albumTracks]];
            }
            else
            {
                [Logger writeToLogFile:[NSString stringWithFormat:@"Media collection count (%lu) differs from database track count (%lu) for album %@", (unsigned long)currentMediaCollection.items.count, (unsigned long)albumTracks.count, currentAlbum.title]];
            }
        }
        
        if (i % 10 == 0 || i == albumsCollection.count - 1)
        {
            progressFraction = (i + 1) / (float)albumsCollection.count;
            [Utilities sendProgressNotification:progressFraction forOperationType:@"Album" duringBuildAll:duringBuildAll];
        }
        
        if (error.code != 0)
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"Error obtaining permanent IDs for objects: %@", error]];
        }
        
        [databaseInterface saveContext];
    }
    
    [self performSelectorOnMainThread:@selector(sendAlbumsTableNeedsReloadNotification) withObject:nil waitUntilDone:NO];
}

-(void)sendAlbumsTableNeedsReloadNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.AlbumsTableNeedsReloadNotification" object:self userInfo:nil];
}

@end
