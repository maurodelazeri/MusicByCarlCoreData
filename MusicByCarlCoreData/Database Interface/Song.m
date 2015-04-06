//
//  Song.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 4/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "Song.h"
#import "Album.h"
#import "Albums.h"
#import "Playlist.h"

#import "DatabaseInterface.h"
#import "Utilities.h"

@implementation Song

@dynamic albumArtist;
//@dynamic albumArtwork;
@dynamic albumPersistentID;
@dynamic albumTitle;
@dynamic artist;
@dynamic assetURL;
@dynamic duration;
@dynamic genre;
@dynamic indexCharacter;
@dynamic internalID;
@dynamic lastPlayedTime;
@dynamic persistentID;
@dynamic songTitle;
@dynamic strippedSongTitle;
@dynamic trackNumber;
@dynamic fromAlbum;
@dynamic inPlaylists;

- (NSString *)description
{
    NSString *returnValue = @"\n----- SONG -----";
    returnValue = [returnValue stringByAppendingFormat:@"\ntitle = %@", self.songTitle];
    returnValue = [returnValue stringByAppendingFormat:@"\nstrippedSongTitle = %@", self.strippedSongTitle];
    returnValue = [returnValue stringByAppendingFormat:@"\npersistentID = %llu", self.persistentID.unsignedLongLongValue];
    returnValue = [returnValue stringByAppendingFormat:@"\nartist = %@", self.artist];
    returnValue = [returnValue stringByAppendingFormat:@"\nalbumTitle = %@", self.albumTitle];
    returnValue = [returnValue stringByAppendingFormat:@"\nalbumArtist = %@", self.albumArtist];
    returnValue = [returnValue stringByAppendingFormat:@"\nalbumPersistentID = %llu", self.albumPersistentID.unsignedLongLongValue];
    returnValue = [returnValue stringByAppendingFormat:@"\ntrackNumber = %llu", self.trackNumber.unsignedLongLongValue];
    NSURL *assetURL = [NSKeyedUnarchiver unarchiveObjectWithData:self.assetURL];;
    returnValue = [returnValue stringByAppendingFormat:@"\nalbumTitle = %@", assetURL.absoluteString];
    returnValue = [returnValue stringByAppendingFormat:@"\nlastPlayedTime = %@", [Utilities dateToString:self.lastPlayedTime]];
    returnValue = [returnValue stringByAppendingFormat:@"\nduration = %@", [Utilities convertDoubleTimeToString:self.duration.doubleValue]];
    returnValue = [returnValue stringByAppendingFormat:@"\ngenre = %@", self.genre];
    returnValue = [returnValue stringByAppendingFormat:@"\nindexCharacter = %@", self.indexCharacter];
    returnValue = [returnValue stringByAppendingFormat:@"\ninternalID = %@", self.internalID];
    returnValue = [returnValue stringByAppendingFormat:@"\nfromAlbum = %@", self.fromAlbum.title];
    returnValue = [returnValue stringByAppendingString:@"\ninPlaylists:"];
    for (Playlist *playlist in self.inPlaylists)
    {
        returnValue = [returnValue stringByAppendingFormat:@"\n%@", playlist.title];
    }
    
    return returnValue;
}

- (void)updateLastPlayedTime: (NSDate *)lastPlayedTime withDatabasePtr:(DatabaseInterface *)databaseInterface
{
    self.lastPlayedTime = lastPlayedTime;
    
    [databaseInterface saveContext];
}

- (Album *)albumFromAlbumPersistentID {
    Album *returnValue = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    returnValue = [Albums fetchAlbumWithPersitentID:self.albumPersistentID withDatabasePtr:databaseInterfacePtr];
    return returnValue;
}

- (MPMediaItemArtwork *)albumArtworkFromPersistentID
{
    MPMediaItemArtwork *albumArtwork = nil;
    MPMediaItem *song;

    MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
    
    [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:self.persistentID forProperty:MPMediaItemPropertyPersistentID]];
    
    NSArray *songs = [songQuery items];
    
    if (songs.count == 1)
    {
        song = [songs objectAtIndex:0];
        albumArtwork = [song valueForProperty: MPMediaItemPropertyArtwork];
    }

    if (albumArtwork == nil) {
        albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"No-album-artwork.png"]];
    }
    
    return albumArtwork;
}

@end
