//
//  Artists.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/31/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Artist.h"
#import "Genre.h"

@interface Artists : NSObject

// Singleton pointer given to other classes that access the Artists class
+ (Artists *)sharedArtists;

- (NSUInteger)numberOfArtistsInDatabase;
-(void)fillDatabaseArtistsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface;
- (Artist *)fetchArtistWithInternalID: (NSInteger)artistInternalID;
- (Artist *)fetchArtistWithName: (NSString *)artistName withDatabasePtr:(DatabaseInterface *)databaseInterface;

@property (strong, nonatomic) NSString *genreFilter;

@end
