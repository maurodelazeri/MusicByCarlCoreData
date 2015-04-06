//
//  Artist.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "Artist.h"
#import "Album.h"
#import "Genre.h"


@implementation Artist

@dynamic indexCharacter;
@dynamic internalID;
@dynamic name;
@dynamic strippedName;
@dynamic artistAlbums;
@dynamic artistGenres;

- (NSString *)description
{
    NSString *returnValue = @"\n----- ARTIST -----";
    returnValue = [returnValue stringByAppendingFormat:@"\nname = %@", self.name];
    returnValue = [returnValue stringByAppendingFormat:@"\nstrippedName = %@", self.strippedName];
    returnValue = [returnValue stringByAppendingFormat:@"\nindexCharacter = %@", self.indexCharacter];
    returnValue = [returnValue stringByAppendingFormat:@"\ninternalID = %@", self.internalID];
    returnValue = [returnValue stringByAppendingString:@"\nartistAlbums:"];
    for (Album *album in self.artistAlbums)
    {
        returnValue = [returnValue stringByAppendingFormat:@"\n%@", album.title];
    }
    
    returnValue = [returnValue stringByAppendingString:@"\nartistGenres:"];
    if (self.artistGenres.count)
    {
        for (Genre *genre in self.artistGenres)
        {
            returnValue = [returnValue stringByAppendingFormat:@"\n%@", genre.name];
        }
    }
    else
    {
        returnValue = [returnValue stringByAppendingString:@"***** NO GENRES *****"];
    }
    
    return returnValue;
}

- (void)addArtistAlbums:(NSOrderedSet *)values
{
    [self willChangeValueForKey:@"artistAlbums"];
    
    NSMutableOrderedSet *tempOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"artistAlbums"]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tempOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    
    if (valuesCount > 0)
    {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"artistAlbums"];
        [tempOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tempOrderedSet forKey:@"artistAlbums"];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"artistAlbums"];
    }
    
    [self didChangeValueForKey:@"artistAlbums"];
}

@end
