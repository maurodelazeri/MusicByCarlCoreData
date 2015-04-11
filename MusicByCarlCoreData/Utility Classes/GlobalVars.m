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
        _sharedObject = [self loadInstance];
    });
    return _sharedObject;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    
    if (self)
    {
        _currentAlbum = [decoder decodeObjectForKey:@"currentAlbum"];
        _currentSong = [decoder decodeObjectForKey:@"currentSong"];
    }
    else
    {
        _currentAlbum = [NSNumber numberWithInteger:-1];
        _currentSong = [NSNumber numberWithInteger:-1];
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

+(instancetype)loadInstance
{
    NSString *archivePath = [Utilities globalVarsArchiveFilePath];
    NSData *decodedData = [NSData dataWithContentsOfFile:archivePath];
    if (decodedData)
    {
        GlobalVars *globalVarsData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return globalVarsData;
    }
    
    return [[GlobalVars alloc] init];
}

@end
