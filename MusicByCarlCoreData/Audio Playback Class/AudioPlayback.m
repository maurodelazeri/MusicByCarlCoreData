//
//  AudioPlayback.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "AudioPlayback.h"
//#import "AudioPlaybackArchive.h"
#import "Song.h"
#import "Album.h"
#import "DatabaseInterface.h"
#import "CurrentSongsInfo.h"
#import "GlobalVars.h"

#import "Logger.h"
#import "Utilities.h"
#import "MillisecondTimer.h"

static AudioPlayback *refToSelf;

@interface AudioPlayback()
{
    AVAudioSession *_audioSessionPtr;
}

@property (strong, nonatomic) CurrentSongsInfo *currentSongsInfo;
@property (strong, nonatomic) UIAlertView *lastPlayedAlert;

@end

@implementation AudioPlayback

- (NSString *)description
{
    NSString *returnValue = @"\n----- AudioPlayback -----";
    returnValue = [returnValue stringByAppendingFormat:@"\nvolume = %.2f", self.avPlayer.volume];
    returnValue = [returnValue stringByAppendingFormat:@"\npan = %.2f", self.avPlayer.pan];
    returnValue = [returnValue stringByAppendingFormat:@"\nrate = %.2f", self.avPlayer.rate];
    returnValue = [returnValue stringByAppendingFormat:@"\nrate = %ld", (long)self.avPlayer.numberOfLoops];
    returnValue = [returnValue stringByAppendingFormat:@"\ncurrentTime = %@", [Utilities convertDoubleTimeToString:self.avPlayer.currentTime]];
    returnValue = [returnValue stringByAppendingFormat:@"\nmeteringEnabled = %d", self.avPlayer.meteringEnabled];
    returnValue = [returnValue stringByAppendingFormat:@"\nchannelZeroPeak = %.2f", self.channelZeroPeak];
    returnValue = [returnValue stringByAppendingFormat:@"\nchannelOnePeak = %.2f", self.channelOnePeak];
    
    return returnValue;
}

- (CurrentSongsInfo *)currentSongsInfo
{
    if (!_currentSongsInfo)
    {
        _currentSongsInfo = [CurrentSongsInfo sharedCurrentSongsInfo];
    }
    
    return _currentSongsInfo;
}

- (Songs *)songsPtr
{
    if (!_songsPtr)
    {
        _songsPtr = [Songs sharedSongs];
    }
    
    return _songsPtr;
}

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (AudioPlayback *)sharedAudioPlayback
{
    static dispatch_once_t pred = 0;
    __strong static AudioPlayback *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[AudioPlayback alloc] init];
        if (_sharedObject) {
            [_sharedObject initAVSession];
        }
    });
    return _sharedObject;
}

- (UserPreferences *)userPreferencesPtr
{
    if (!_userPreferencesPtr)
    {
        _userPreferencesPtr = [UserPreferences sharedUserPreferences];
    }
    
    return _userPreferencesPtr;
}

- (void)initAVSession
{
    //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
    
    _audioSessionPtr = (AVAudioSession *)[AVAudioSession sharedInstance];

    NSError *error;

    [_audioSessionPtr setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error.code != 0)
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error setting audio session category: %@", error]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaServicesReset:) name:AVAudioSessionMediaServicesWereResetNotification object:nil];
    
    [_audioSessionPtr setActive: YES error: &error];
    if (error.code != 0)
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error setting audio session to active: %@", error]];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handlePlaybackDeviceUnavailable:)
                               name: @"MusicByCarlCoreData.playbackDeviceUnavailable"
                             object: nil];
    
    // If using a nonmixable audio session category, as this app does, you must activate reception of
    //    remote-control events to allow reactivation of the audio session when running in the background.
    //    Also, to receive remote-control events, the app must be eligible to become the first responder.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)handlePlaybackDeviceUnavailable:(id)notification
{
    [self pauseAudio];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self userInfo:nil];
}

- (void)mediaServicesReset: (NSNotification *)notification
{
    [Logger writeToLogFile:[NSString stringWithFormat:@"%s called with notification = %@", __PRETTY_FUNCTION__, notification]];
}

- (void)audioInterrupted: (NSNotification *)notification
{
    AVAudioSessionInterruptionType interruptionType = [[notification.userInfo objectForKey:@"AVAudioSessionInterruptionTypeKey"] unsignedIntegerValue];
    
    if (interruptionType == AVAudioSessionInterruptionTypeBegan)
    {
        // Audio is paused automatically, so update the pause button
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self userInfo:nil];
    }
    else
    {
        if (interruptionType == AVAudioSessionInterruptionTypeEnded)
        {
            AVAudioSessionInterruptionOptions interruptionOptions = [[notification.userInfo objectForKey:@"AVAudioSessionInterruptionOptionKey"] unsignedIntegerValue];
            if (interruptionOptions == AVAudioSessionInterruptionOptionShouldResume)
            {
                // Resume the audio and update the play button
                [self playAudio];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self userInfo:nil];
            }
        }
    }
}

- (void)routeChanged: (NSNotification *)notification
{
    if (notification.userInfo)
    {
        AVAudioSessionRouteDescription *previousRoute = [notification.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionRouteChangeReason routeChangeReason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
        
        if (previousRoute)
        {
            if (previousRoute.outputs.count)
            {
                AVAudioSessionPortDescription *outputPort = [previousRoute.outputs objectAtIndex:0];
                if (outputPort)
                {
                    if ([outputPort.portType isEqualToString:AVAudioSessionPortHeadphones] && routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.playbackDeviceUnavailable" object:nil userInfo:nil];
                    }
                }
            }
        }
    }
}

- (void)logSongVolumeLevels
{
    [self.avPlayer updateMeters];

    float currentChannelZeroPeak = [self.avPlayer peakPowerForChannel:0];
    float currentChannelOnePeak = [self.avPlayer peakPowerForChannel:1];
    
    if (currentChannelZeroPeak > self.channelZeroPeak)
    {
        self.channelZeroPeak = currentChannelZeroPeak;
    }
    
    if (currentChannelOnePeak > self.channelOnePeak)
    {
        self.channelOnePeak = currentChannelOnePeak;
    }
}

- (void)displayOrPlayCurrentSong:(NSInteger)currentSongIndex withPlayFlag:(BOOL)playFlag
{
    Song *currentSong = [self getCurrentSongPtr:currentSongIndex];
    
    [self displayCurrentSong:currentSongIndex];
    
    if (playFlag)
    {
        [self playSongAudio:currentSong];
    }
    else
    {
        [self loadSongAudio:currentSong];
    }
}

- (void)displayCurrentSong:(NSInteger)currentSongIndex
{
    Song *currentSong = [self getCurrentSongPtr:currentSongIndex];
    
    NSDictionary *songInfo = @{@"currentSong": currentSong};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.displayCurrentSongInfo" object:self userInfo:songInfo];
    
    [self updateNowPlayingInfoCenter:currentSong];
}

- (void)updateNowPlayingInfoCenter:(Song *)song
{
    MPMediaItemArtwork *albumArtwork = [song albumArtworkFromPersistentID];
    
    NSArray *keys = [NSArray arrayWithObjects:
                     MPMediaItemPropertyTitle,
                     MPMediaItemPropertyArtist,
                     MPMediaItemPropertyPlaybackDuration,
                     MPMediaItemPropertyArtwork,
                     MPNowPlayingInfoPropertyPlaybackRate,
                     nil];
    NSArray *values = [NSArray arrayWithObjects:
                       song.songTitle,
                       song.artist,
                       song.duration,
                       albumArtwork,
                       [NSNumber numberWithInt:1],
                       nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    
    Album *album = [song albumFromAlbumPersistentID];
    if (album) {
        GlobalVars *globalVarsPtr = [GlobalVars sharedGlobalVars];
        globalVarsPtr.currentAlbum = album.internalID;
        globalVarsPtr.currentSong = song.internalID;
    }
}

- (void)playNextSong:(NSInteger)currentSongIndex
{
    NSInteger nextSongIndex = [self moveForwardOneSong:currentSongIndex];
    
    if (nextSongIndex == -1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self userInfo:nil];
    }
    else
    {
        [self.currentSongsInfo updateCurrentSongIndex:nextSongIndex];
        [self displayOrPlayCurrentSong:[self.currentSongsInfo retrieveCurrentSongIndex] withPlayFlag:YES];
    }
}

- (void)playSongWithURL: (NSURL *)songURL
{
    NSError *error;

    // Destroy a possible previous AV Player
    self.avPlayer = nil;
    
    //Load the audio into memory
    self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
    
    if (error.code != 0)
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error initializing audio player with contents of URL %@: %@", [songURL absoluteString], error]];
    }
    else
    {
        self.avPlayer.meteringEnabled = YES;
        self.channelZeroPeak = -160.0f;
        self.channelOnePeak = -160.0f;
        
        if ([self.avPlayer prepareToPlay])
        {
            self.avPlayer.delegate = self;
            
            self.avPlayer.volume = [self.userPreferencesPtr volumeLevel];
            
            if (![self.avPlayer play])
            {
                [Logger writeToLogFile:[NSString stringWithFormat:@"Error: avPlayer play returned NO"]];
            }
        }
        else
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"Error: avPlayer prepareToPlay in %s returned NO", __PRETTY_FUNCTION__]];
        }
    }
}

- (void)loadSongWithURL: (NSURL *)songURL
{
    NSError *error;
    
    // Destroy a possible previous AV Player
    self.avPlayer = nil;
    
    //Load the audio into memory
    self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
    
    if (error.code != 0)
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error initializing audio player with contents of URL %@: %@", [songURL absoluteString], error]];
    }
    else
    {
        if ([self.avPlayer prepareToPlay])
        {
            self.avPlayer.delegate = self;
            
            self.avPlayer.volume = [self.userPreferencesPtr volumeLevel];
        }
        else
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"Error: avPlayer prepareToPlay in %s returned NO", __PRETTY_FUNCTION__]];
        }
    }
}

- (BOOL)isAudioPlaying
{
    return self.avPlayer.isPlaying;
}

- (void)playAudio
{
    if (![self.avPlayer play])
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error: avPlayer play returned NO"]];
    }
}

- (void)pauseAudio
{
    [self.avPlayer pause];
}

- (void)stopAudio
{
    [self.avPlayer stop];
}

- (NSTimeInterval)duration
{
    return [self.avPlayer duration];
}

- (NSTimeInterval)currentTime
{
    float returnValue = -1.0f;
    
    if (self.avPlayer != nil)
    {
        return [self.avPlayer currentTime];
    }
    
    return returnValue;
}

- (void)setCurrentTime: (NSTimeInterval)newTime
{
    self.avPlayer.currentTime = newTime;
}

- (float)volume
{
    float returnValue = -1.0f;
    
    if (self.avPlayer != nil)
    {
        return self.avPlayer.volume;
    }
    
    return returnValue;
}

- (void)setVolume: (float)newVolume
{
    self.avPlayer.volume = newVolume;
    [self.userPreferencesPtr newVolumeLevel:newVolume];
}

- (BOOL)songsLeftToPlayForSongIndex: (NSInteger)songIndex
{
    NSInteger currentSongListCount = [self.currentSongsInfo retrieveCurrentSongsListCount];
    
    BOOL returnValue = songIndex >= 0 && songIndex < currentSongListCount;
    
    return returnValue;
}

- (NSTimeInterval)returnIntervalSinceLastPlay: (NSInteger)currentSongIndex
{
    Song *currentSong = [self getCurrentSongPtr:currentSongIndex];
    
    NSDate *now = [NSDate date];
    
    return [now timeIntervalSinceDate:currentSong.lastPlayedTime];
}

- (NSNumber *)returnSongOlderThan: (NSInteger)numberOfDays
{
    NSNumber *oldSongInternalId = nil;
    
    NSInteger newSongIndex;
    
    switch (numberOfDays)
    {
        case -1:
        {
            NSUInteger neverPlayedCount = [self.currentSongsInfo retrieveNeverPlayedSongsCount];
            if (neverPlayedCount > 0)
            {
                newSongIndex = arc4random_uniform((u_int32_t)neverPlayedCount);
                oldSongInternalId = [self.currentSongsInfo songsNeverPlayedObjectAtIndex:newSongIndex];
                [self.currentSongsInfo removeNeverPlayedSong:oldSongInternalId];
            }
        }
        break;
            
        case 30:
        {
            NSUInteger olderThanThirtyCount = [self.currentSongsInfo retrieveOlderThanThirtySongsCount];
            if (olderThanThirtyCount > 0)
            {
                newSongIndex = arc4random_uniform((u_int32_t)olderThanThirtyCount);
                oldSongInternalId = [self.currentSongsInfo songsOlderThanThirtyDaysObjectAtIndex:newSongIndex];
                [self.currentSongsInfo removeOlderThanThirtyDaysSong:oldSongInternalId];
            }
        }
        break;
            
        case 21:
        {
            NSUInteger olderThanTwentyOneCount = [self.currentSongsInfo retrieveOlderThanTwentyOneSongsCount];
            if (olderThanTwentyOneCount > 0)
            {
                newSongIndex = arc4random_uniform((u_int32_t)olderThanTwentyOneCount);
                oldSongInternalId = [self.currentSongsInfo songsOlderThanTwentyOneDaysObjectAtIndex:newSongIndex];
                [self.currentSongsInfo removeOlderThanTwentyOneDaysSong:oldSongInternalId];
            }
        }
        break;
            
        case 14:
        {
            NSUInteger olderThanFourteenCount = [self.currentSongsInfo retrieveOlderThanFourteenSongsCount];
            if (olderThanFourteenCount > 0)
            {
                newSongIndex = arc4random_uniform((u_int32_t)olderThanFourteenCount);
                oldSongInternalId = [self.currentSongsInfo songsOlderThanFourteenDaysObjectAtIndex:newSongIndex];
                [self.currentSongsInfo removeOlderThanFourteenDaysSong:oldSongInternalId];
            }
        }
        break;
            
        case 7:
        {
            NSUInteger olderThanSevenCount = [self.currentSongsInfo retrieveOlderThanSevenSongsCount];
            if (olderThanSevenCount > 0)
            {
                newSongIndex = arc4random_uniform((u_int32_t)olderThanSevenCount);
                oldSongInternalId = [self.currentSongsInfo songsOlderThanSevenDaysObjectAtIndex:newSongIndex];
                [self.currentSongsInfo removeOlderThanSevenDaysSong:oldSongInternalId];
            }
        }
        break;
            
    }
    
    return oldSongInternalId;
}

- (NSNumber *)returnOldSong
{
    NSNumber *oldSongInternalID = nil;
    
    oldSongInternalID = [self returnSongOlderThan:-1];
    if (oldSongInternalID == nil)
    {
        oldSongInternalID = [self returnSongOlderThan:30];
        if (oldSongInternalID == nil)
        {
            oldSongInternalID = [self returnSongOlderThan:21];
            if (oldSongInternalID == nil)
            {
                oldSongInternalID = [self returnSongOlderThan:14];
                if (oldSongInternalID == nil)
                {
                    oldSongInternalID = [self returnSongOlderThan:7];
                }
            }
        }
    }
    
    return oldSongInternalID;
}

- (NSInteger)nextShuffleSongIndex
{
    NSInteger currentSongListCount = [self.currentSongsInfo retrieveCurrentSongsListCount];

    NSInteger newSongIndex;
    
    NSNumber *oldSongInternalID = [self returnOldSong];
    if (oldSongInternalID != nil)
    {
        newSongIndex = [self.currentSongsInfo currentSongListIndexOfInternalId:oldSongInternalID];
    }
    else
    {
        NSTimeInterval intervalSinceLastPlay = 0.0;
        NSInteger newSongsTried = 0;
        
        NSTimeInterval greatestIntervalSinceLastPlay = 0.0;
        NSInteger songIndexWithGreatestInterval = -1;
        
        NSUInteger maxSongsToTry = currentSongListCount / 5;
        
        while (intervalSinceLastPlay < secondsInADay * 14.0 && newSongsTried < maxSongsToTry)
        {
            newSongsTried++;
            newSongIndex = arc4random_uniform((u_int32_t)currentSongListCount);
            
            intervalSinceLastPlay = [self returnIntervalSinceLastPlay:newSongIndex];
            if (intervalSinceLastPlay > greatestIntervalSinceLastPlay)
            {
                greatestIntervalSinceLastPlay = intervalSinceLastPlay;
                songIndexWithGreatestInterval = newSongIndex;
            }
        }
        
        if (newSongsTried > maxSongsToTry && songIndexWithGreatestInterval != -1)
        {
            newSongIndex = songIndexWithGreatestInterval;
        }
    }
    
    return newSongIndex;
}

- (NSInteger)fetchNextSongIndex: (NSInteger)currentSongIndex;
{
    NSInteger returnValue;
    
    if (self.userPreferencesPtr.shuffleFlag)
    {
        returnValue = [self nextShuffleSongIndex];
    }
    else
    {
        returnValue = currentSongIndex + 1;
    }

    return returnValue;
}

- (NSInteger)fetchPreviousSongIndex: (NSInteger)currentSongIndex;
{
    NSInteger returnValue;
    
    NSTimeInterval intervalSinceLastPlay;
    intervalSinceLastPlay = [self returnIntervalSinceLastPlay:currentSongIndex];
    
    if (self.userPreferencesPtr.shuffleFlag)
    {
        returnValue = [self nextShuffleSongIndex];
    }
    else
    {
        returnValue = currentSongIndex - 1;
    }
    
    return returnValue;
}

- (NSInteger)moveBackOneSong: (NSInteger)currentSongIndex
{
    NSInteger returnValue = -1;
    
    NSInteger previousSongIndex = [self fetchPreviousSongIndex:currentSongIndex];
    
    if ([self songsLeftToPlayForSongIndex:previousSongIndex])
    {
        returnValue = previousSongIndex;
    }
    
    return returnValue;
}

- (NSInteger)moveForwardOneSong: (NSInteger)currentSongIndex
{
    NSInteger returnValue = -1;
    
    NSInteger nextSongIndex = [self fetchNextSongIndex:currentSongIndex];
    if ([self songsLeftToPlayForSongIndex:nextSongIndex])
    {
        returnValue = nextSongIndex;
    }
    
    return returnValue;
}

- (Song *)getCurrentSongPtr: (NSInteger)currentSongIndex
{
    NSNumber *songInternalID = [self.currentSongsInfo currentSongListObjectAtIndex:currentSongIndex];
    Song *currentSong = [self.songsPtr fetchSongWithInternalID:songInternalID.integerValue];
    
    return currentSong;
}

- (void)playSongAudio: (Song *)currentSong
{
    NSURL *currentSongAssetURL = [NSKeyedUnarchiver unarchiveObjectWithData:currentSong.assetURL];
    [self playSongWithURL:currentSongAssetURL];
    
    [AppDelegate archiveAppData];
}

- (void)loadSongAudio: (Song *)currentSong
{
    NSURL *songAssetURL = [NSKeyedUnarchiver unarchiveObjectWithData:currentSong.assetURL];
    
    [self loadSongWithURL:songAssetURL];
}

- (void)logFinalPeakPower: (float)powerLevel forChannel: (NSString *)channelName
{
    NSString *stringToLog = [NSString stringWithFormat:@"Final peak power for channel %@ = %f", channelName, powerLevel];
    
    if (powerLevel > -0.0001)
    {
        stringToLog = [stringToLog stringByAppendingString:@" (PROBABLE CLIPPING)"];
    }
    else
    {
        if (powerLevel > -1.0)
        {
            stringToLog = [stringToLog stringByAppendingString:@" (VERY GOOD)"];
        }
        else
        {
            if (powerLevel > -2.0)
            {
                stringToLog = [stringToLog stringByAppendingString:@" (GOOD)"];
            }
            else
            {
                if (powerLevel > -4.0)
                {
                    stringToLog = [stringToLog stringByAppendingString:@" (ACCEPTABLE)"];
                }
                else
                {
                    stringToLog = [stringToLog stringByAppendingString:@" (TOO SOFT)"];
                }
            }
        }
    }
    
    [Logger writeToLogFileSpecial:stringToLog];
}

- (void)goToNextSong
{
    NSInteger nextSongIndex = [self moveForwardOneSong:[self.currentSongsInfo retrieveCurrentSongIndex]];
    BOOL audioIsPlaying = [self isAudioPlaying];
    
    if (nextSongIndex == -1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self];
    }
    else
    {
        if (audioIsPlaying)
        {
            // Stop the current song
            [self stopAudio];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.stopSongPlaybackTimer" object:self];
        }
        [self.currentSongsInfo updateCurrentSongIndex:nextSongIndex];
        [self displayOrPlayCurrentSong:[self.currentSongsInfo retrieveCurrentSongIndex] withPlayFlag:audioIsPlaying];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.startSongPlaybackTimer" object:self];
    }
}

- (void)goToPreviousSong
{
    BOOL audioIsPlaying = [self isAudioPlaying];
    
    if ([self currentTime] > 1.0)
    {
        [self setCurrentTime:0.0];
        [self displayOrPlayCurrentSong:[self.currentSongsInfo retrieveCurrentSongIndex] withPlayFlag:audioIsPlaying];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.startSongPlaybackTimer" object:self];
    }
    else
    {
        NSInteger previousSongIndex = [self moveBackOneSong:[self.currentSongsInfo retrieveCurrentSongIndex]];
        
        if (previousSongIndex == -1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self];
        }
        else
        {
            if (audioIsPlaying)
            {
                // Stop the current song
                [self stopAudio];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.stopSongPlaybackTimer" object:self];
            }
            
            [self.currentSongsInfo updateCurrentSongIndex:previousSongIndex];
            [self displayOrPlayCurrentSong:[self.currentSongsInfo retrieveCurrentSongIndex] withPlayFlag:audioIsPlaying];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.startSongPlaybackTimer" object:self];
        }
    }
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [Logger writeToLogFile:[NSString stringWithFormat:@"%s called with error = %@", __PRETTY_FUNCTION__, error]];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    Song *currentSong = [self getCurrentSongPtr:[self.currentSongsInfo retrieveCurrentSongIndex]];
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    
    [currentSong updateLastPlayedTime:[NSDate date] withDatabasePtr:databaseInterfacePtr];

    //[self logFinalPeakPower:self.channelZeroPeak forChannel:@"zero"];
    //[self logFinalPeakPower:self.channelOnePeak forChannel:@"one"];

    [self playNextSong:[self.currentSongsInfo retrieveCurrentSongIndex]];
}

@end
