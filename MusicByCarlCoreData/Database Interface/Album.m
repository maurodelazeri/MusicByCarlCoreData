//
//  Album.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 4/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "Album.h"
#import "Artist.h"
#import "Song.h"


@implementation Album

@dynamic artist;
@dynamic durationString;
@dynamic indexCharacter;
@dynamic internalID;
@dynamic persistentID;
@dynamic releaseYear;
@dynamic strippedTitle;
@dynamic title;
@dynamic isInstrumental;
@dynamic albumArtist;
@dynamic albumSongs;

- (NSString *)description
{
    NSString *returnValue = @"\n----- ALBUM -----";
    returnValue = [returnValue stringByAppendingFormat:@"\nartist = %@", self.artist];
    returnValue = [returnValue stringByAppendingFormat:@"\ndurationString = %@", self.durationString];
    returnValue = [returnValue stringByAppendingFormat:@"\nindexCharacter = %@", self.indexCharacter];
    returnValue = [returnValue stringByAppendingFormat:@"\ninternalID = %llu", self.internalID.unsignedLongLongValue];
    returnValue = [returnValue stringByAppendingFormat:@"\npersistentID = %llu", self.persistentID.unsignedLongLongValue];
    returnValue = [returnValue stringByAppendingFormat:@"\nreleaseYear = %@", self.releaseYear];
    returnValue = [returnValue stringByAppendingFormat:@"\ntitle = %@", self.title];
    returnValue = [returnValue stringByAppendingFormat:@"\nstrippedTitle = %@", self.strippedTitle];
    returnValue = [returnValue stringByAppendingFormat:@"\nisInstrumental = %llu", self.isInstrumental.unsignedLongLongValue];
    int i = 1;
    for (Song *song in self.albumSongs)
    {
        returnValue = [returnValue stringByAppendingFormat:@"\nTrack %d: %@", i, song.songTitle];
    }
    
    return returnValue;
}

- (void)addAlbumSongs:(NSOrderedSet *)values
{
    [self willChangeValueForKey:@"albumSongs"];
    
    NSMutableOrderedSet *tempOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"albumSongs"]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tempOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    
    if (valuesCount > 0)
    {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"albumSongs"];
        [tempOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tempOrderedSet forKey:@"albumSongs"];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"albumSongs"];
    }
    
    [self didChangeValueForKey:@"albumSongs"];
}

- (MPMediaItemArtwork *)albumArtworkFromPersistentID
{
    MPMediaItemArtwork *albumArtwork = nil;
    
    MPMediaItem *currentAlbumTrack;
    MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
    
    [albumQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:self.persistentID forProperty:MPMediaItemPropertyAlbumPersistentID]];
    
    NSArray *albumTracks = [albumQuery items];
    
    if (albumTracks.count >= 1)
    {
        currentAlbumTrack = [albumTracks objectAtIndex:0];
        albumArtwork = [currentAlbumTrack valueForProperty: MPMediaItemPropertyArtwork];
    }
    
    return albumArtwork;
}

@end
