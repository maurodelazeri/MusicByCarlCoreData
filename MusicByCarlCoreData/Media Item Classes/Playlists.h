//
//  Playlists.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/3/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Playlist.h"
#import "DatabaseInterface.h"

@interface Playlists : NSObject

// Singleton pointer given to other classes who access the Playlists class
+ (Playlists *)sharedPlaylists;

- (NSUInteger)numberOfPlaylistsInDatabase;
- (Playlist *)fetchPlaylistWithInternalID: (NSInteger)playlistInternalID;
- (void)fillDatabasePlaylistsFromItunesLibrary: (BOOL)duringBuildAll withDatabasePtr: (DatabaseInterface *)databaseInterface;
@end
