//
//  Genres.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/6/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "DatabaseInterface.h"
#import "Genre.h"
#import "Genres.h"
#import "Songs.h"
#import "Utilities.h"
#import "Logger.h"
#import "Artist.h"

@interface Genres ()
{
    NSMutableOrderedSet *genresArray; // of MPMediaItem
    Songs *songsPtr;
}
@end

@implementation Genres

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
+ (Genres *)sharedGenres
{
    static dispatch_once_t pred = 0;
    __strong static Genres *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[Genres alloc] init];
    });
    return _sharedObject;
}

- (NSUInteger)numberOfGenresInDatabase
{
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    return [databaseInterfacePtr countOfEntitiesOfType:@"Genre" withFetchRequestChangeBlock:nil];
}

- (Genre *)fetchGenreWithInternalID: (NSInteger)genreInternalID
{
    Genre *genre = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *genreObjects = [databaseInterfacePtr entitiesOfType:@"Genre" withFetchRequestChangeBlock:
                             ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                             {
                                 [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"internalID == %@", [NSNumber numberWithInteger:genreInternalID]]];
                                 return inputFetchRequest;
                             }
                             ];
    
    if (genreObjects.count == 1)
    {
        genre = (Genre *)[genreObjects objectAtIndex:0];
    }
    
    return genre;
}

- (NSArray *)fetchGenreSongsWithGenreName: (NSString *)genreName withDatabasePtr: (DatabaseInterface *)databaseInterface
{
    NSArray *genreSongs;
    
    genreSongs = [databaseInterface entitiesOfType:@"Song" withFetchRequestChangeBlock:
                    ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                    {
                        [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"genre == %@", genreName]];
                        return inputFetchRequest;
                    }
                    ];
    
    return genreSongs;
}

// THIS METHOD MUST BE CALLED FROM A BACKGROUND THREAD TO AVOID BLOCKING THE UI
- (void)fillDatabaseGenresFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface
{
     MPMediaQuery *genresQuery = [MPMediaQuery genresQuery];
     
     NSArray *genresCollection = [genresQuery collections];
     
     genresArray = [[NSMutableOrderedSet alloc] init];
     
     MPMediaItemCollection *currentMediaCollection;
     MPMediaItem *genreMediaItem;
     Genre *currentGenre;
     NSArray *genreSongs;
     NSArray *genreArtists;
     
     float progressFraction;
     
     for (int i = 0; i < genresCollection.count; i++)
     {
         currentMediaCollection = [genresCollection objectAtIndex:i];
         
         uint64_t genrePersistentID = [[currentMediaCollection valueForProperty:MPMediaItemPropertyGenrePersistentID] unsignedLongLongValue];
         
         genreMediaItem = [currentMediaCollection representativeItem];
         
         if (genreMediaItem != nil)
         {
             [genresArray addObject:genreMediaItem];
             currentGenre = (Genre *)[databaseInterface newManagedObjectOfType:@"Genre"];
             
             if (currentGenre == nil)
             {
                 [Logger writeToLogFile:[NSString stringWithFormat:@"currentGenre == nil"]];
             }
             else
             {
                 currentGenre.internalID = [NSNumber numberWithInt:i];
                 currentGenre.name = [genreMediaItem valueForProperty: MPMediaItemPropertyGenre];
                 currentGenre.indexCharacter = [Utilities getMediaObjectIndexCharacter:currentGenre.name];
                 currentGenre.persistentID = [NSNumber numberWithUnsignedLongLong:genrePersistentID];
                 
                 genreSongs = [self fetchGenreSongsWithGenreName:currentGenre.name withDatabasePtr:databaseInterface];
                 
                 genreArtists = [songsPtr fetchAllArtistsFromSongs: genreSongs withDatabasePtr:databaseInterface];
                 
                 if (genreSongs.count == currentMediaCollection.items.count)
                 {
                     [currentGenre addGenreArtists:[NSOrderedSet orderedSetWithArray:genreArtists]];
                 }
                 else
                 {
                     [Logger writeToLogFile:[NSString stringWithFormat:@"Media collection count (%lu) differs from database song count (%lu) for genre %@", (unsigned long)currentMediaCollection.items.count, (unsigned long)genreSongs.count, currentGenre.name]];
                 }

                 [databaseInterface saveContext];
             }
         }
         
         if (i % 10 == 0 || i == genresCollection.count - 1)
         {
             progressFraction = (i + 1) / (float)genresCollection.count;
             [Utilities sendProgressNotification:progressFraction forOperationType:@"Genre" duringBuildAll:duringBuildAll];
         }
     }
}

@end
