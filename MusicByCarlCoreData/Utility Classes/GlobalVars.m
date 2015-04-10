//
//  GlobalVars.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "GlobalVars.h"
#import "Utilities.h"
#import "Logger.h"

@implementation GlobalVars

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (GlobalVars *)sharedGlobalVars
{
    static dispatch_once_t pred = 0;
    __strong static GlobalVars *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[GlobalVars alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *archivePath = [Utilities globalVarsArchiveFilePath];
        GlobalVars *archivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        
        if (archivedObject == nil)
        {
            _currentAlbum = [NSNumber numberWithInteger:-1];
            _currentSong = [NSNumber numberWithInteger:-1];
        }
        else
        {
            _currentAlbum = archivedObject.currentAlbum;
            _currentSong = archivedObject.currentSong;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self)
    {
        _currentAlbum = [decoder decodeObjectForKey:@"currentAlbum"];
        _currentSong = [decoder decodeObjectForKey:@"currentSong"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.currentAlbum forKey:@"currentAlbum"];
    [encoder encodeObject:self.currentSong forKey:@"currentSong"];
}
- (void)archiveData
{
    NSString *archivePath = [Utilities globalVarsArchiveFilePath];
    [NSKeyedArchiver archiveRootObject:self toFile:archivePath];
}

@end
