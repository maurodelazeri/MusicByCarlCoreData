//
//  Genres.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/6/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DatabaseInterface.h"
#import "Genre.h"

@interface Genres : NSObject

// Singleton pointer given to other classes who access the Genres class
+ (Genres *)sharedGenres;

- (NSUInteger)numberOfGenresInDatabase;
- (Genre *)fetchGenreWithInternalID: (NSInteger)genreInternalID;
- (void)fillDatabaseGenresFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface;

@end
