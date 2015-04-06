//
//  Genre.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "Genre.h"
#import "Artist.h"


@implementation Genre

@dynamic internalID;
@dynamic name;
@dynamic persistentID;
@dynamic indexCharacter;
@dynamic genreArtists;

- (NSString *)description
{
    NSString *returnValue = @"\n----- GENRE -----";
    returnValue = [returnValue stringByAppendingFormat:@"\nname = %@", self.name];
    returnValue = [returnValue stringByAppendingFormat:@"\nindexCharacter = %@", self.indexCharacter];
    returnValue = [returnValue stringByAppendingFormat:@"\ninternalID = %llu", self.internalID.unsignedLongLongValue];
    returnValue = [returnValue stringByAppendingFormat:@"\npersistentID = %llu", self.persistentID.unsignedLongLongValue];
    returnValue = [returnValue stringByAppendingString:@"\ngenreArtists:"];
    for (Artist *artist in self.genreArtists)
    {
        returnValue = [returnValue stringByAppendingFormat:@"\n%@", artist.name];
    }
    
    return returnValue;
}

- (void)addGenreArtists:(NSOrderedSet *)values
{
    [self willChangeValueForKey:@"genreArtists"];
    
    NSMutableOrderedSet *tempOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"genreArtists"]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tempOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    
    if (valuesCount > 0)
    {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"genreArtists"];
        [tempOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tempOrderedSet forKey:@"genreArtists"];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"genreArtists"];
    }
    
    [self didChangeValueForKey:@"genreArtists"];
}

@end
