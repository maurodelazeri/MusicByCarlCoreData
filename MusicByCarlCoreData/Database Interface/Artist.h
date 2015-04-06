//
//  Artist.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Genre;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * indexCharacter;
@property (nonatomic, retain) NSNumber * internalID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * strippedName;
@property (nonatomic, retain) NSOrderedSet *artistAlbums;
@property (nonatomic, retain) NSSet *artistGenres;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)insertObject:(Album *)value inArtistAlbumsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromArtistAlbumsAtIndex:(NSUInteger)idx;
- (void)insertArtistAlbums:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeArtistAlbumsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInArtistAlbumsAtIndex:(NSUInteger)idx withObject:(Album *)value;
- (void)replaceArtistAlbumsAtIndexes:(NSIndexSet *)indexes withArtistAlbums:(NSArray *)values;
- (void)addArtistAlbumsObject:(Album *)value;
- (void)removeArtistAlbumsObject:(Album *)value;
- (void)addArtistAlbums:(NSOrderedSet *)values;
- (void)removeArtistAlbums:(NSOrderedSet *)values;
- (void)addArtistGenresObject:(Genre *)value;
- (void)removeArtistGenresObject:(Genre *)value;
- (void)addArtistGenres:(NSSet *)values;
- (void)removeArtistGenres:(NSSet *)values;

@end
