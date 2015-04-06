//
//  Artists.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/31/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "DatabaseInterface.h"
#import "Artist.h"
#import "Artists.h"
#import "Utilities.h"
#import "Logger.h"

@interface Artists ()
{
    NSMutableArray *artistsArray;
}
@end

@implementation Artists

@synthesize genreFilter = _genreFilter;

+ (Artists *)sharedArtists
{
    static dispatch_once_t pred = 0;
    __strong static Artists *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[Artists alloc] init];
    });
    return _sharedObject;
}

- (NSUInteger)numberOfArtistsInDatabase
{
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    
    return [databaseInterfacePtr countOfEntitiesOfType:@"Artist" withFetchRequestChangeBlock:nil];
}

- (NSArray *)fetchArtistAlbumsWithArtistName: (NSString *)artistName withDatabasePtr:(DatabaseInterface *)databaseInterfacePtr
{
    NSArray *artistAlbums;
    
    artistAlbums = [databaseInterfacePtr entitiesOfType:@"Album" withFetchRequestChangeBlock:
                    ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                    {
                        [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"artist == %@", artistName]];
                        return inputFetchRequest;
                    }
                    ];
    
    return artistAlbums;
}

- (Artist *)fetchArtistWithInternalID: (NSInteger)artistInternalID
{
    Artist *artist = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    
    NSArray *artistObjects = [databaseInterfacePtr entitiesOfType:@"Artist" withFetchRequestChangeBlock:
                            ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                            {
                                [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:artistInternalID]]];
                                return inputFetchRequest;
                            }
                            ];
    
    if (artistObjects.count == 1)
    {
        artist = (Artist *)[artistObjects objectAtIndex:0];
    }
    
    return artist;
}

- (Artist *)fetchArtistWithName: (NSString *)artistName withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    Artist *artist = nil;
    
    NSArray *artistObjects = [databaseInterface entitiesOfType:@"Artist" withFetchRequestChangeBlock:
                              ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                              {
                                  [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", artistName]];
                                  return inputFetchRequest;
                              }
                              ];
    
    if (artistObjects.count == 1)
    {
        artist = (Artist *)[artistObjects objectAtIndex:0];
    }
    
    return artist;
}

-(NSArray *)getArtistAlbums: (NSString *) artistName
{
    MPMediaQuery *artistAlbumsQuery = [MPMediaQuery albumsQuery];
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue: artistName forProperty: MPMediaItemPropertyAlbumArtist];
    
    [artistAlbumsQuery addFilterPredicate:albumPredicate];
    NSArray *returnValue = [artistAlbumsQuery collections];
    
    return returnValue;
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
-(void)fillDatabaseArtistsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface
{
    float progressFraction;
    
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    artistsQuery.groupingType = MPMediaGroupingAlbumArtist;
    NSArray *artistsCollection = [artistsQuery collections];
    
    MPMediaItem *currentArtistMediaItem;
    NSString *artistName;
    MPMediaItemCollection *artistCollection;
    
    Artist *currentArtist;
    
    NSArray *artistMediaAlbums;
    NSOrderedSet *artistCoreDataAlbums;
    
    for (int i = 0; i < artistsCollection.count; i++)
    {
        artistCollection = [artistsCollection objectAtIndex:i];
        
        currentArtist = (Artist *)[databaseInterface newManagedObjectOfType:@"Artist"];
        
        if (currentArtist == nil)
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"currentArtist == nil"]];
        }
        
        currentArtistMediaItem = [artistCollection representativeItem];
        artistName = [currentArtistMediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
        
        if (artistName != nil)
        {
            currentArtist.internalID = [NSNumber numberWithInt:i];
            currentArtist.name = artistName;
            currentArtist.indexCharacter = [Utilities getMediaObjectIndexCharacter:currentArtist.name];
            currentArtist.strippedName = [Utilities getMediaObjectIndexCharacter:currentArtist.name];
            
            artistMediaAlbums = [self getArtistAlbums:artistName];
            artistCoreDataAlbums = [NSOrderedSet orderedSetWithArray:[self fetchArtistAlbumsWithArtistName:artistName withDatabasePtr:databaseInterface]];
            
            if (artistMediaAlbums.count == artistCoreDataAlbums.count)
            {
                [currentArtist addArtistAlbums:artistCoreDataAlbums];
            }
            else
            {
                [Logger writeToLogFile:[NSString stringWithFormat:@"Media album count (%lu) not equal to Core Data album count (%lu) for artist %@", (unsigned long)artistMediaAlbums.count, (unsigned long)artistCoreDataAlbums.count, artistName]];
            }
        }
        
        if (i % 10 == 0 || i == artistsCollection.count - 1)
        {
            progressFraction = (i + 1) / (float)artistsCollection.count;
            [Utilities sendProgressNotification:progressFraction forOperationType:@"Artist" duringBuildAll:duringBuildAll];
        }

        [databaseInterface saveContext];
    }
}

@end
