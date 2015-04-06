//
//  Song.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 4/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

@class Album, Playlist, DatabaseInterface;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * albumArtist;
//@property (nonatomic, retain) NSData * albumArtwork;
@property (nonatomic, retain) NSNumber * albumPersistentID;
@property (nonatomic, retain) NSString * albumTitle;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSData * assetURL;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * indexCharacter;
@property (nonatomic, retain) NSNumber * internalID;
@property (nonatomic, retain) NSDate * lastPlayedTime;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * songTitle;
@property (nonatomic, retain) NSString * strippedSongTitle;
@property (nonatomic, retain) NSNumber * trackNumber;
@property (nonatomic, retain) Album *fromAlbum;
@property (nonatomic, retain) NSSet *inPlaylists;

- (void)updateLastPlayedTime: (NSDate *)lastPlayedTime withDatabasePtr:(DatabaseInterface *)databaseInterface;

@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addInPlaylistsObject:(Playlist *)value;
- (void)removeInPlaylistsObject:(Playlist *)value;
- (void)addInPlaylists:(NSSet *)values;
- (void)removeInPlaylists:(NSSet *)values;

- (Album *)albumFromAlbumPersistentID;
- (MPMediaItemArtwork *)albumArtworkFromPersistentID;

@end
