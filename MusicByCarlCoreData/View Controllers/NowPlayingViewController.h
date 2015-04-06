//
//  NowPlayingViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoScrollLabel.h"
#import "AudioPlayback.h"
#import "Song.h"
#import "Songs.h"
#import "UserPreferences.h"

@interface NowPlayingViewController : UIViewController

@property (strong, nonatomic) AudioPlayback *audioPlaybackPtr;

@property (nonatomic) BOOL startNewAudio;
@property (nonatomic) BOOL shuffleAllFlag;
@property (nonatomic) BOOL newSongList;
@property (nonatomic) BOOL nowPlayingSegue;

@property (strong, nonatomic) IBOutlet AutoScrollLabel *scrollingArtistLabel;
@property (strong, nonatomic) IBOutlet AutoScrollLabel *scrollingTitleLabel;
@property (strong, nonatomic) IBOutlet AutoScrollLabel *scrollingAlbumTitleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (strong, nonatomic) IBOutlet UIView *volumeViewParentView;

@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;

@property (strong, nonatomic) IBOutlet UISlider *trackTimePercentageSlider;
@property (strong, nonatomic) IBOutlet UILabel *currentTrackOfTotalTracksLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackTimeElapsedLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackTimeRemainingLabel;

- (IBAction)playPauseButtonPressed:(id)sender;
- (IBAction)nextSongButtonPressed:(id)sender;
- (IBAction)previousSongButtonPressed:(id)sender;
- (IBAction)timePercentageSliderTouchInside:(id)sender;

@end
