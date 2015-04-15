//
//  AlbumDetailViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/26/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "AlbumDetailViewController.h"
#import "NowPlayingViewController.h"
#import "AlbumInfoView.h"
#import "AlbumTrackDetailCell.h"
#import "Song.h"
#import "CurrentSongsInfo.h"

#import "Utilities.h"
#import "Logger.h"
#import "MillisecondTimer.h"

@interface AlbumDetailViewController () <UIContentContainer>
{
    NSMutableArray *albumTracks; // of NSOrderedSet
    DatabaseInterface *databaseInterfacePtr;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;
@end

@implementation AlbumDetailViewController

- (DatabaseInterface *)lazyDatabaseInterfacePtr
{
    if (!databaseInterfacePtr)
    {
        databaseInterfacePtr = [[DatabaseInterface alloc] init];
    }
    
    return databaseInterfacePtr;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.albumInternalIDs forKey:@"albumInternalIDs"];
    [coder encodeFloat:self.tableView.contentOffset.x forKey:@"tableContentOffsetX"];
    [coder encodeFloat:self.tableView.contentOffset.y forKey:@"tableContentOffsetY"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.albumInternalIDs = [coder decodeObjectForKey:@"albumInternalIDs"];
    CGFloat tableViewContentOffsetX = [coder decodeFloatForKey:@"tableContentOffsetX"];
    CGFloat tableViewContentOffsetY = [coder decodeFloatForKey:@"tableContentOffsetY"];
    self.tableView.contentOffset = CGPointMake(tableViewContentOffsetX, tableViewContentOffsetY);
    [super decodeRestorableStateWithCoder:coder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    Album *currentAlbum;
    NSNumber *currentAlbumInternalID;
    
    albumTracks = [[NSMutableArray alloc] init];
    
    databaseInterfacePtr = [self lazyDatabaseInterfacePtr];

    for (int i = 0; i < self.albumInternalIDs.count; i++)
    {
        currentAlbumInternalID = [self.albumInternalIDs objectAtIndex:i];
        currentAlbum = [Albums fetchAlbumWithInternalID:currentAlbumInternalID.unsignedLongLongValue withDatabasePtr:databaseInterfacePtr];
        
        self.title = currentAlbum.artist;
        [albumTracks addObject:currentAlbum.albumSongs];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lastInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         
         if (self.lastInterfaceOrientation != UIInterfaceOrientationUnknown && orientation != self.lastInterfaceOrientation)
         {
             if (orientation == UIInterfaceOrientationLandscapeLeft ||
                 orientation == UIInterfaceOrientationLandscapeRight)
             {
                 [Utilities segueToCoverFlow:self];
             }
             self.lastInterfaceOrientation = orientation;
         }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NowPlayingViewController *nowPlayingViewController = [segue destinationViewController];
    nowPlayingViewController.shuffleAllFlag = NO;
    
    if ([[segue identifier] isEqualToString:@"nowPlayingSegue"])
    {
        nowPlayingViewController.startNewAudio = NO;
        nowPlayingViewController.nowPlayingSegue = YES;
    }
    else
    {
        if ([[segue identifier] isEqualToString:@"playNewSong"])
        {
            NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
            NSOrderedSet *currentAlbumTracks;
            
            Song *albumTrack;
            NSInteger currentSongIndex = 0;
            
            CurrentSongsInfo *currentSongsInfo = [CurrentSongsInfo sharedCurrentSongsInfo];
            [currentSongsInfo resetCurrentSongsInfoArrays];
            for (int i = 0; i < albumTracks.count; i++)
            {
                currentAlbumTracks = [albumTracks objectAtIndex:i];
                
                for (int j = 0; j < currentAlbumTracks.count; j++)
                {
                    albumTrack = [currentAlbumTracks objectAtIndex:j];
                    [currentSongsInfo addCurrentSongListSong:albumTrack.internalID];
                    
                    if (i == selectedIndexPath.section && j == selectedIndexPath.row)
                    {
                        [currentSongsInfo updateCurrentSongIndex:currentSongIndex];
                    }
                    currentSongIndex++;
                }
            }
            nowPlayingViewController.newSongList = YES;
            nowPlayingViewController.startNewAudio = YES;
        }
    }
}

- (NSString *) getAlbumArtist: (NSInteger)section
{
    NSOrderedSet *currentAlbumTracks = [albumTracks objectAtIndex:section];
    
    for (int i = 0 ; i < [currentAlbumTracks count]; i++)
    {
        Song *albumTrackZero = [currentAlbumTracks objectAtIndex:i];
        
        if (albumTrackZero.artist)
        {
            return albumTrackZero.albumArtist;
        }
    }
    
    return @"Unknown artist";
}

- (NSString *) getAlbumGeneralInfo: (NSInteger)section
{
    NSOrderedSet *currentAlbumTracks = [albumTracks objectAtIndex:section];
    
    NSString *trackCount;
    
    if ([currentAlbumTracks count] > 1)
    {
        trackCount = [NSString stringWithFormat:@"%lu Songs", (unsigned long)[currentAlbumTracks count]];
    }
    else
    {
        trackCount = [NSString stringWithFormat:@"1 Song"];
    }
    
    double playbackDuration = 0;
    
    for (Song *track in currentAlbumTracks)
    {
        playbackDuration += [track.duration doubleValue];
    }
    
    int albumMimutes = (playbackDuration /60);
    NSString *albumDuration;
    
    if (albumMimutes > 1)
    {
        albumDuration = [NSString stringWithFormat:@"%i Mins.", albumMimutes];
    }
    else
    {
        albumDuration = [NSString stringWithFormat:@"1 Min."];
    }
    
    return [NSString stringWithFormat:@"%@, %@", trackCount, albumDuration];
}

- (BOOL) sameArtists: (NSInteger)section
{
    NSOrderedSet *currentAlbumTracks = [albumTracks objectAtIndex:section];
    
    Song *trackZero = [currentAlbumTracks objectAtIndex:0];
    Song *currentTrack;
    
    for (int i = 0 ; i < [currentAlbumTracks count]; i++)
    {
        currentTrack = [currentAlbumTracks objectAtIndex:i];
        
        if (![trackZero.artist isEqualToString:currentTrack.artist])
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.albumInternalIDs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSOrderedSet *currentAlbumTracks = [albumTracks objectAtIndex:section];
    
    return currentAlbumTracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlbumTrackDetailCell";
    AlbumTrackDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[AlbumTrackDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSOrderedSet *currentAlbumTracks = [albumTracks objectAtIndex:indexPath.section];
    Song *songItem = [currentAlbumTracks objectAtIndex:indexPath.row];
    NSUInteger trackNumber = [songItem.trackNumber unsignedIntegerValue];
    
    if (trackNumber)
    {
        NSNumber *songDuration = songItem.duration;
        NSInteger truncedSongDuration = trunc( songDuration.doubleValue );
        
        cell.trackNumberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)trackNumber];
        
        if (truncedSongDuration % 60 < 10)
        {
            cell.trackDurationLabel.text = [NSString stringWithFormat:@"%i:0%i", (int)(truncedSongDuration / 60), (int)(truncedSongDuration % 60)];
        }
        else
        {
            cell.trackDurationLabel.text = [NSString stringWithFormat:@"%i:%i", (int)(truncedSongDuration / 60), (int)(truncedSongDuration % 60)];
        }
    }
    
    if (![self sameArtists:indexPath.section] && songItem.artist)
    {
        cell.trackTitleLabel.text = songItem.songTitle;
        cell.trackArtistLabel.text = songItem.artist;
        cell.trackSingleArtistTitleLabel.text = @"";
    }
    else
    {
        cell.trackSingleArtistTitleLabel.text = songItem.songTitle;
        cell.trackArtistLabel.text = @"";
        cell.trackTitleLabel.text = @"";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 117.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AlbumInfoView *albumInfoView = [[AlbumInfoView alloc] init];
    NSNumber *currentAlbumInternalID = [self.albumInternalIDs objectAtIndex:section];
    databaseInterfacePtr = [self lazyDatabaseInterfacePtr];
    Album *currentAlbum = [Albums fetchAlbumWithInternalID:currentAlbumInternalID.unsignedLongLongValue withDatabasePtr:databaseInterfacePtr];
    
    MPMediaItemArtwork *localAlbumArtwork = [currentAlbum albumArtworkFromPersistentID];
    if (localAlbumArtwork == nil)
    {
        albumInfoView.albumArtworkImageView.image = [UIImage imageNamed:@"No-album-artwork.png"];
    }
    else
    {
        albumInfoView.albumArtworkImageView.image = [localAlbumArtwork imageWithSize: CGSizeMake (320, 320)];
    }
    
    albumInfoView.albumArtistLabel.text = [self getAlbumArtist:section];
    albumInfoView.albumTitleLabel.text = currentAlbum.title;
    albumInfoView.albumInfoLabel.text = [self getAlbumGeneralInfo:section];
    albumInfoView.albumReleaseYearLabel.text = currentAlbum.releaseYear;
    
    return albumInfoView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
