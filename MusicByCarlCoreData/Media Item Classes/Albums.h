//
//  Albums.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Songs.h"
#import "AlbumTextLabelsData.h"

@interface Albums : NSObject

// Singleton pointer given to other classes who access the Albums class
+ (Albums *)sharedAlbums;

+ (NSUInteger)numberOfAlbumsInDatabase;
+ (Album *)fetchAlbumWithInternalID: (NSInteger)albumInternalID withDatabasePtr:(DatabaseInterface *)databaseInterface;
+ (Album *)fetchAlbumWithPersitentID: (NSNumber *)persistentID withDatabasePtr:(DatabaseInterface *)databaseInterface;

+ (AlbumTextLabelsData *)fetchAlbumTextDataWithAlbumInternalID: (NSInteger)internalID andDatabasePtr:(DatabaseInterface *)databaseInterface;
+ (UIImage *)fetchAlbumImageWithAlbumInternalID: (NSInteger)internalID withSize:(CGSize)albumArtSize andDatabasePtr:(DatabaseInterface *)databaseInterface;

- (void)fillDatabaseAlbumsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface;
@end
