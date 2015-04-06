//
//  Playlist.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/4/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "Playlist.h"
#import "Song.h"


@implementation Playlist

@dynamic title;
@dynamic internalID;
@dynamic playlistSongs;

- (NSString *)description
{
    NSString *returnValue = @"\n----- PLAYLIST -----";
    returnValue = [returnValue stringByAppendingFormat:@"\ntitle = %@", self.title];
    returnValue = [returnValue stringByAppendingFormat:@"\ninternalID = %@", self.internalID];
    for (Song *song in self.playlistSongs)
    {
        returnValue = [returnValue stringByAppendingFormat:@"\n%@", song.songTitle];
    }
    
    return returnValue;
}

- (void)addPlaylistSongsObject:(Song *)value
{
    [self willChangeValueForKey:@"playlistSongs"];
    
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.playlistSongs];
    [tempSet addObject:value];
    self.playlistSongs = tempSet;
    
    [self didChangeValueForKey:@"playlistSongs"];
}

@end
