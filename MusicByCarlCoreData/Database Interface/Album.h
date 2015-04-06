//
//  Album.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 4/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

@class Artist, Song;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * durationString;
@property (nonatomic, retain) NSString * indexCharacter;
@property (nonatomic, retain) NSNumber * internalID;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * releaseYear;
@property (nonatomic, retain) NSString * strippedTitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * isInstrumental;
@property (nonatomic, retain) Artist *albumArtist;
@property (nonatomic, retain) NSOrderedSet *albumSongs;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)insertObject:(Song *)value inAlbumSongsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAlbumSongsAtIndex:(NSUInteger)idx;
- (void)insertAlbumSongs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAlbumSongsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAlbumSongsAtIndex:(NSUInteger)idx withObject:(Song *)value;
- (void)replaceAlbumSongsAtIndexes:(NSIndexSet *)indexes withAlbumSongs:(NSArray *)values;
- (void)addAlbumSongsObject:(Song *)value;
- (void)removeAlbumSongsObject:(Song *)value;
- (void)addAlbumSongs:(NSOrderedSet *)values;
- (void)removeAlbumSongs:(NSOrderedSet *)values;

- (MPMediaItemArtwork *)albumArtworkFromPersistentID;

@end
