//
//  UserPreferences.m
//  MusicByCarl
//
//  Created by CarlSmith on 3/24/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "UserPreferences.h"

#import "Utilities.h"

#import "Logger.h"

@interface UserPreferences ()
@property (nonatomic, readwrite) BOOL shuffleFlag;
@property (strong, nonatomic, readwrite) NSArray *instrumentalAlbums;
@property (nonatomic, readwrite) float volumeLevel;
@end

@implementation UserPreferences

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (UserPreferences *)sharedUserPreferences
{
    static dispatch_once_t pred = 0;
    __strong static UserPreferences *_sharedObject = nil;
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
        _shuffleFlag = [decoder decodeBoolForKey:@"shuffleFlag"];
        _volumeLevel = [decoder decodeFloatForKey:@"volumeLevel"];
        _instrumentalAlbums = [decoder decodeObjectForKey:@"instrumentalAlbums"];
    }
    else
    {
        _shuffleFlag = NO;
        _volumeLevel = 1.0f;
        _instrumentalAlbums = [[NSArray alloc] init];
    }
    
    return self;
}

+ (instancetype)loadInstance
{
    NSString *archivePath = [Utilities userPreferencesArchiveFilePath];
    NSData *decodedData = [NSData dataWithContentsOfFile:archivePath];
    if (decodedData)
    {
        UserPreferences *userPreferencesData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return userPreferencesData;
    }
    
    return [[UserPreferences alloc] init];
}

- (void)archiveData
{
    NSString *archivePath = [Utilities userPreferencesArchiveFilePath];
    [NSKeyedArchiver archiveRootObject:self toFile:archivePath];
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.shuffleFlag forKey:@"shuffleFlag"];
    [encoder encodeFloat:self.volumeLevel forKey:@"volumeLevel"];
    [encoder encodeObject:self.instrumentalAlbums forKey:@"instrumentalAlbums"];
}

- (void)readDefaultValues
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"defaultValues" ofType:@"plist"];
    NSMutableDictionary *preferencesDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [[NSUserDefaults standardUserDefaults] registerDefaults:preferencesDictionary];
}

- (void)loadUserPreferences
{
    [self readDefaultValues];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.shuffleFlag = [[userDefaults valueForKey:@"shuffleFlag"] boolValue];
    self.instrumentalAlbums = [userDefaults valueForKey:@"instrumentalAlbums"];
    self.volumeLevel = [[userDefaults valueForKey:@"volumeLevel"] floatValue];
}

- (BOOL)findInstrumentalAlbumWithTitle: (NSString *)title andArtist: (NSString *)artist
{
    BOOL returnValue = NO;
    NSDictionary *currentAlbum;
    
    for (int i = 0; i < self.instrumentalAlbums.count && !returnValue; i++)
    {
        currentAlbum = [self.instrumentalAlbums objectAtIndex:i];
        if ([[currentAlbum objectForKey:@"title"] isEqualToString:title] && [[currentAlbum objectForKey:@"artist"] isEqualToString:artist])
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

- (void)newShuffleFlagValue: (BOOL)newValue
{
    self.shuffleFlag = newValue;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:newValue forKey:@"shuffleFlag"];

    if (![userDefaults synchronize])
    {
        [self showSynchronizeError];
    }
}

- (void)newVolumeLevel: (float)newValue
{
    self.volumeLevel = newValue;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithFloat:newValue] forKey:@"volumeLevel"];
    
    if (![userDefaults synchronize])
    {
        [self showSynchronizeError];
    }
}

- (void)showSynchronizeError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MusicByCarlCoreData Alert"
                                                    message:@"Error saving settings"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
