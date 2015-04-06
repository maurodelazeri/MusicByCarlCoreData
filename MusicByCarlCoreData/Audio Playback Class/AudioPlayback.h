//
//  AudioPlayback.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "Songs.h"
#import "UserPreferences.h"

@interface AudioPlayback : NSObject <AVAudioPlayerDelegate>

// Singleton pointer given to other classes who access the AudioPlayback class
+ (AudioPlayback *)sharedAudioPlayback;

@property (strong, nonatomic) AVAudioPlayer *avPlayer;
@property (nonatomic) float channelZeroPeak;
@property (nonatomic) float channelOnePeak;

@property (strong, nonatomic) AVAudioSession *audioSessionPtr;

@property (strong, nonatomic) UserPreferences *userPreferencesPtr;

@property (strong, nonatomic) Songs *songsPtr;

- (Song *)getCurrentSongPtr: (NSInteger)currentSongIndex;

- (void)playNextSong:(NSInteger)currentSongIndex;

- (void)displayOrPlayCurrentSong:(NSInteger)currentSongIndex withPlayFlag:(BOOL)playFlag;
- (void)displayCurrentSong:(NSInteger)currentSongIndex;

- (void)playSongAudio: (Song *)currentSong;
- (void)loadSongAudio: (Song *)currentSong;

- (void)playSongWithURL: (NSURL *)songURL;

- (BOOL)isAudioPlaying;

- (void)playAudio;
- (void)pauseAudio;
- (void)stopAudio;

- (void)goToNextSong;
- (void)goToPreviousSong;

- (NSTimeInterval)duration;

- (NSInteger)moveForwardOneSong: (NSInteger)currentSongIndex;
- (NSInteger)moveBackOneSong: (NSInteger)currentSongIndex;

- (void)logSongVolumeLevels;

- (NSInteger)nextShuffleSongIndex;

- (NSTimeInterval)currentTime;
- (void)setCurrentTime:(NSTimeInterval)currentTime;

- (float)volume;
- (void)setVolume: (float)newVolume;

@end
