//
//  NowPlayingViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayback.h"
#import "NowPlayingViewController.h"
#import "UserPreferences.h"
#import "CurrentSongsInfo.h"
#import "Album.h"

#import "Utilities.h"
#import "Logger.h"
#import "MillisecondTimer.h"

@interface NowPlayingViewController ()
{
    UIImage *playIcon;
    UIImage *pauseIcon;
    
    NSTimer *oneSecondTimer;
    UIAlertView *lastPlayedAlert;
    
    BOOL restoreStateCase;
    NSTimeInterval currentPlaybackTime;
}
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) UserPreferences *userPreferencesPtr;
@property (strong, nonatomic) CurrentSongsInfo *currentSongsInfo;
@end

@implementation NowPlayingViewController

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeFloat:self.volumeSlider.value forKey:@"volumeLevel"];
    [coder encodeDouble:currentPlaybackTime forKey:@"currentPlaybackTime"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    currentPlaybackTime = [coder decodeDoubleForKey:@"currentPlaybackTime"];
    restoreStateCase = YES;
    [super decodeRestorableStateWithCoder:coder];
}

- (AudioPlayback *)audioPlaybackPtr
{
    if (!_audioPlaybackPtr)
    {
        _audioPlaybackPtr = [AudioPlayback sharedAudioPlayback];
    }
    
    return _audioPlaybackPtr;
}

- (UserPreferences *)userPreferencesPtr
{
    if (!_userPreferencesPtr)
    {
        _userPreferencesPtr = [UserPreferences sharedUserPreferences];
    }
    
    return _userPreferencesPtr;
}

- (CurrentSongsInfo *)currentSongsInfo
{
    if (!_currentSongsInfo)
    {
        _currentSongsInfo = [CurrentSongsInfo sharedCurrentSongsInfo];
    }
    
    return _currentSongsInfo;
}

- (void)customizeVolumeSlider
{
    UIEdgeInsets minSliderEdgeInsets = UIEdgeInsetsMake(0.0, 7.0, 0.0, 1.0);
    UIImage *minVolumeSliderImage = [[UIImage imageNamed:@"Min-volume-slider.png"] resizableImageWithCapInsets:minSliderEdgeInsets];
    
    UIEdgeInsets maxSliderEdgeInsets = UIEdgeInsetsMake(0.0, 1.0, 0.0, 7.0);
    UIImage *maxVolumeSliderImage = [[UIImage imageNamed:@"Max-volume-slider.png"] resizableImageWithCapInsets:maxSliderEdgeInsets];
    
    [self.volumeSlider setMinimumTrackImage:minVolumeSliderImage forState:UIControlStateNormal];
    [self.volumeSlider setMaximumTrackImage:maxVolumeSliderImage forState:UIControlStateNormal];
    
    UIImage *volumeSliderThumbImage = [UIImage imageNamed:@"Now-playing-volume-slider.png"];
    
    [self.volumeSlider setThumbImage:volumeSliderThumbImage forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:volumeSliderThumbImage forState:UIControlStateSelected];
    
    float volumeLevel = [self.userPreferencesPtr volumeLevel];
    [self.volumeSlider setValue:volumeLevel animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *artistFont = [UIFont boldSystemFontOfSize:12.0];
    self.scrollingArtistLabel.font = artistFont;
    self.scrollingArtistLabel.textColor = [UIColor whiteColor];
    self.scrollingArtistLabel.scrollSpeed = 25.0;
    
    UIFont *songTitleFont = [UIFont boldSystemFontOfSize:12.0];
    self.scrollingTitleLabel.font = songTitleFont;
    self.scrollingTitleLabel.textColor = [UIColor whiteColor];
    self.scrollingTitleLabel.scrollSpeed = 25.0;
    
    UIFont *albumTitleFont = [UIFont boldSystemFontOfSize:12.0];
    self.scrollingAlbumTitleLabel.font = albumTitleFont;
    self.scrollingAlbumTitleLabel.textColor = [UIColor whiteColor];
    self.scrollingAlbumTitleLabel.scrollSpeed = 25.0;
    
    self.navigationItem.leftBarButtonItem.target = self;
    self.navigationItem.leftBarButtonItem.action = @selector(backButtonPress);
    
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(shuffleButtonPress);
    
    [self updateShuffleButtonColor:self.userPreferencesPtr.shuffleFlag];
    
    UIImage *progressSliderThumbImage = [UIImage imageNamed:@"Now-playing-progress-slider.png"];
    [self.trackTimePercentageSlider setThumbImage:progressSliderThumbImage forState:UIControlStateNormal];
    [self.trackTimePercentageSlider setThumbImage:progressSliderThumbImage forState:UIControlStateSelected];
    
    self.volumeViewParentView.backgroundColor = [UIColor clearColor];
    
    playIcon = [UIImage imageNamed:@"Play-icon.png"];
    pauseIcon = [UIImage imageNamed:@"Pause-icon.png"];
    
    [self customizeVolumeSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deRegisterNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updatePlayPauseButtton:[self.audioPlaybackPtr isAudioPlaying]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self registerNotifications];
    
    [self.currentSongsInfo fillLastPlayedTimesArray];
    
    if (self.newSongList) {
        self.newSongList = NO;
        [self.currentSongsInfo fillOldSongsArrays];
    }
    
    NSInteger currentSongIndex = [self.currentSongsInfo retrieveCurrentSongIndex];
    
    if (self.shuffleAllFlag)
    {
        self.shuffleAllFlag = NO;
        self.startNewAudio = NO;
        [self.audioPlaybackPtr playNextSong:currentSongIndex];
    }
    else
    {
        if (self.startNewAudio)
        {
            self.startNewAudio = NO;
            [self.audioPlaybackPtr displayOrPlayCurrentSong:currentSongIndex withPlayFlag:YES];
        }
        else
        {
            if (restoreStateCase) {
                [self.audioPlaybackPtr displayOrPlayCurrentSong:currentSongIndex withPlayFlag:NO];
                if (currentPlaybackTime > 0.0)
                {
                    [self.audioPlaybackPtr setCurrentTime:currentPlaybackTime];
                }
                restoreStateCase = NO;
            }
            else {
                if (self.nowPlayingSegue) {
                    self.nowPlayingSegue = NO;
                    [self.audioPlaybackPtr displayCurrentSong:currentSongIndex];
                }
            }
        }
    }
    
    [self startSongPlaybackTimer];
    [self updateTimeDisplayElements];
}

-(void)startSongPlaybackTimer
{
    [self stopSongPlaybackTimer];
    oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressElements) userInfo:nil repeats:YES];
    [oneSecondTimer fire];
}

-(void)stopSongPlaybackTimer
{
    [oneSecondTimer invalidate];
    oneSecondTimer = nil;
}

- (void)registerNotifications
{
    NSNotificationCenter *notificationCenter;
    
    notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector(handleEnterForeground:)
                               name: UIApplicationWillEnterForegroundNotification
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector(handleUpdatePlayPauseButton:)
                               name: @"MusicByCarlCoreData.updatePlayPauseButton"
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(handleDisplayCurrentSongInfo:)
                               name: @"MusicByCarlCoreData.displayCurrentSongInfo"
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(handleStartSongPlaybackTimer:)
                               name: @"MusicByCarlCoreData.startSongPlaybackTimer"
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(handleStopSongPlaybackTimer:)
                               name: @"MusicByCarlCoreData.stopSongPlaybackTimer"
                             object: nil];
}

- (void)deRegisterNotifications
{
    NSNotificationCenter *notificationCenter;
    
    [notificationCenter removeObserver: self
                                  name: UIApplicationWillEnterForegroundNotification
                                object:nil];
    
    [notificationCenter removeObserver: self
                                  name: @"MusicByCarlCoreData.updatePlayPauseButton"
                                object:nil];
    
    [notificationCenter removeObserver: self
                                  name: @"MusicByCarlCoreData.startSongPlaybackTimer"
                                object: nil];
    
    [notificationCenter removeObserver: self
                               name: @"MusicByCarlCoreData.stopSongPlaybackTimer"
                             object: nil];
}

- (void)backButtonPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shuffleButtonPress
{
    [self.userPreferencesPtr newShuffleFlagValue:!self.userPreferencesPtr.shuffleFlag];
    
    [self updateShuffleButtonColor:self.userPreferencesPtr.shuffleFlag];
}

- (void)updateShuffleButtonColor:(BOOL)shuffleValue
{
    if (shuffleValue)
    {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor orangeColor];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

- (void)handleEnterForeground:(id)notification
{
    self.scrollingArtistLabel.scrollSpeed = 25.0;
    self.scrollingTitleLabel.scrollSpeed = 25.0;
    self.scrollingAlbumTitleLabel.scrollSpeed = 25.0;
}

- (void)handleStartSongPlaybackTimer:(id)notification
{
    [self startSongPlaybackTimer];
}

- (void)handleStopSongPlaybackTimer:(id)notification
{
    [self stopSongPlaybackTimer];
}

- (void)handleUpdatePlayPauseButton:(id)notification {
    [self updatePlayPauseButtton:[self.audioPlaybackPtr isAudioPlaying]];
}

- (void)handleDisplayCurrentSongInfo:(NSNotification *)notification
{
    Song *currentSong = [notification.userInfo objectForKey:@"currentSong"];
    [self displayCurrentSongInformation:currentSong];
}

- (void)cancelAlert:(id)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)displayCurrentSongInformation:(Song *)currentSong
{
    NSInteger currentSongIndex = [self.currentSongsInfo retrieveCurrentSongIndex];
    NSUInteger currentSongsListCount = [self.currentSongsInfo retrieveCurrentSongsListCount];
    self.currentTrackOfTotalTracksLabel.text = [NSString stringWithFormat:@"%ld of %lu", (long)currentSongIndex + 1, (unsigned long)currentSongsListCount];
    
    self.scrollingArtistLabel.text = currentSong.artist;
    self.scrollingTitleLabel.text = currentSong.songTitle;
    self.scrollingAlbumTitleLabel.text = currentSong.albumTitle;
    
    MPMediaItemArtwork *songArtwork = [currentSong albumArtworkFromPersistentID];
    if (songArtwork == nil)
    {
        self.artworkImageView.image = [UIImage imageNamed:@"No-album-artwork.png"];
    }
    else
    {
        self.artworkImageView.image = [songArtwork imageWithSize: CGSizeMake (320, 320)];
    }
}

- (void)updateTimeDisplayElements
{
    currentPlaybackTime = [self.audioPlaybackPtr currentTime];
    
    self.trackTimeElapsedLabel.text = [Utilities convertDoubleTimeToString:currentPlaybackTime];
    
    NSTimeInterval nowPlayingDuration = [self.audioPlaybackPtr duration];
    
    NSTimeInterval remainingPlaybackTime = nowPlayingDuration - currentPlaybackTime;
    
    self.trackTimeRemainingLabel.text = [NSString stringWithFormat:@"-%@", [Utilities convertDoubleTimeToString:remainingPlaybackTime]];
    
    float playbackPercentage = currentPlaybackTime / nowPlayingDuration;
    
    [self.trackTimePercentageSlider setValue:playbackPercentage animated:YES];
}

- (void)updateProgressElements
{
    if ([self.audioPlaybackPtr isAudioPlaying])
    {
        [self updateTimeDisplayElements];
        [self.audioPlaybackPtr logSongVolumeLevels];
    }
}

- (void)updatePlayPauseButtton:(BOOL)isPlayingState
{
    if (isPlayingState)
    {
        [self.playPauseButton setImage:pauseIcon forState:UIControlStateNormal];
    }
    else
    {
        [self.playPauseButton setImage:playIcon forState:UIControlStateNormal];
    }
}

- (IBAction)volumeSliderValueChanged:(UISlider *)sender
{
    [self.audioPlaybackPtr setVolume:sender.value];
}

- (IBAction)playPauseButtonPressed:(id)sender
{
    if ([self.audioPlaybackPtr isAudioPlaying])
    {
        [self.audioPlaybackPtr pauseAudio];
    }
    else
    {
        [self.audioPlaybackPtr playAudio];
    }
    
    [self updatePlayPauseButtton:[self.audioPlaybackPtr isAudioPlaying]];
}

- (IBAction)nextSongButtonPressed:(id)sender
{
    [self.audioPlaybackPtr goToNextSong];
}

- (IBAction)previousSongButtonPressed:(id)sender
{
    [self.audioPlaybackPtr goToPreviousSong];
}

- (IBAction)timePercentageSliderTouchInside:(id)sender
{
    [self.audioPlaybackPtr setCurrentTime:[self.audioPlaybackPtr duration] * self.trackTimePercentageSlider.value];
}

@end
