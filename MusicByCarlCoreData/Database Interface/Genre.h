//
//  Genre.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist;

@interface Genre : NSManagedObject

@property (nonatomic, retain) NSNumber * internalID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * indexCharacter;
@property (nonatomic, retain) NSOrderedSet *genreArtists;
@end

@interface Genre (CoreDataGeneratedAccessors)

- (void)insertObject:(Artist *)value inGenreArtistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGenreArtistsAtIndex:(NSUInteger)idx;
- (void)insertGenreArtists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGenreArtistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGenreArtistsAtIndex:(NSUInteger)idx withObject:(Artist *)value;
- (void)replaceGenreArtistsAtIndexes:(NSIndexSet *)indexes withGenreArtists:(NSArray *)values;
- (void)addGenreArtistsObject:(Artist *)value;
- (void)removeGenreArtistsObject:(Artist *)value;
- (void)addGenreArtists:(NSOrderedSet *)values;
- (void)removeGenreArtists:(NSOrderedSet *)values;
@end
