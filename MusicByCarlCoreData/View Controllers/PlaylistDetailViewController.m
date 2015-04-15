//
//  PlaylistDetailViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/5/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "DatabaseInterface.h"
#import "PlaylistDetailViewController.h"
#import "NowPlayingViewController.h"
#import "Song.h"
#import "UserPreferences.h"
#import "CurrentSongsInfo.h"

#import "Utilities.h"
#import "Logger.h"

@interface PlaylistDetailViewController () <UIContentContainer>

@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;

@end

@implementation PlaylistDetailViewController

@synthesize tableView = _tableView;

- (Playlists *)playlistsPtr
{
    if (!_playlistsPtr)
    {
        _playlistsPtr = [Playlists sharedPlaylists];
    }
    
    return _playlistsPtr;
}

- (id)init
{
    self = [super initWithTableView:_tableView];
    
    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.playlistInternalID forKey:@"playlistInternalID"];
    [coder encodeFloat:self.tableView.contentOffset.x forKey:@"tableContentOffsetX"];
    [coder encodeFloat:self.tableView.contentOffset.y forKey:@"tableContentOffsetY"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.playlistInternalID = [coder decodeObjectForKey:@"playlistInternalID"];
    self.playlist = [self.playlistsPtr fetchPlaylistWithInternalID:self.playlistInternalID.integerValue];
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

    self.title = self.playlist.title;

    self.playlistInternalID = self.playlist.internalID;
    
    self.songCountLabel.text = [NSString stringWithFormat:@"%lu songs", (unsigned long)self.playlist.playlistSongs.count];
    
    [self createNewFetchedResultsController:self.searchBarText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lastInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
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

- (void)createNewFetchedResultsController: (NSString *)searchString
{
    if (self.playlist.playlistSongs.count > 50)
    {
        DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
        self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Song" withKeyPath:@"indexCharacter" secondarySortKey:nil andFetchRequestChangeBlock: ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
        {
            NSString *playlistTitle = [self.playlist.title stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            NSString *predicateString = [NSString stringWithFormat:@"ANY inPlaylists.title LIKE '%@'", playlistTitle];
            
            if (searchString)
            {
                NSString *searchPredicateString = [NSString stringWithFormat:@" AND songTitle contains[cd] \'%@\'", searchString];
                predicateString = [predicateString stringByAppendingString:searchPredicateString];
            }
            
            [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateString]];
            return inputFetchRequest;
        }];
        
        self.sectionIndexTitles = [Utilities convertSectionIndexTitles:self.fetchedResultsController];
        self.sectionTitles = [Utilities convertSectionTitles:self.fetchedResultsController];
        
        self.tableView.sectionIndexBackgroundColor = [UIColor blackColor];
        self.tableView.sectionIndexTrackingBackgroundColor = [UIColor blackColor];
        
        self.fetchedResultsController.delegate = self;
        [self.tableView reloadData];
    }
    else
    {
        self.fetchedResultsController = nil;
    }
    
    [self assignFetchedResultsController:self.fetchedResultsController];
}

- (NSMutableOrderedSet *)fetchCurrentPlaylistSongsInternalIDs
{
    NSMutableOrderedSet *returnValue = [[NSMutableOrderedSet alloc] init];
    
    for (Song *song in self.playlist.playlistSongs)
    {
        [returnValue addObject:song.internalID];
    }
    
    return returnValue;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![[segue identifier] isEqualToString:@"ShowCoverFlow"]) {
        NowPlayingViewController *nowPlayingViewController = [segue destinationViewController];
        nowPlayingViewController.shuffleAllFlag = NO;
        
        if ([[segue identifier] isEqualToString:@"nowPlayingSegue"])
        {
            nowPlayingViewController.startNewAudio = NO;
            nowPlayingViewController.nowPlayingSegue = YES;
        }
        else
        {
            Song *selectedSong = nil;
            
            // Both the paths through here identify the song to be played by setting the audioPlaybackPtr's currentSongIndex
            CurrentSongsInfo *currentSongsInfo = [CurrentSongsInfo sharedCurrentSongsInfo];

            [currentSongsInfo resetCurrentSongsInfoArrays];
            [currentSongsInfo addAllCurrentSongListSongs:[self fetchCurrentPlaylistSongsInternalIDs]];

            if ([[segue identifier] isEqualToString:@"shuffleAllSongs"])
            {
                UserPreferences *userPreferencesPtr = [UserPreferences sharedUserPreferences];
                [userPreferencesPtr newShuffleFlagValue:YES];
                nowPlayingViewController.shuffleAllFlag = YES;
            }
            else
            {
                if ([[segue identifier] isEqualToString:@"playNewSong"])
                {
                    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                    
                    if (self.fetchedResultsController == nil)
                    {
                        selectedSong = [self.playlist.playlistSongs objectAtIndex:indexPath.row];
                    }
                    else
                    {
                        NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
                        selectedSong = [self.fetchedResultsController objectAtIndexPath:realIndexPath];
                    }
                }
                if (selectedSong)
                {
                    CurrentSongsInfo *currentSongsInfo = [CurrentSongsInfo sharedCurrentSongsInfo];
                    [currentSongsInfo updateCurrentSongIndex: [currentSongsInfo currentSongListIndexOfInternalId:selectedSong.internalID]];
                }
            }
            
            nowPlayingViewController.newSongList = YES;
            nowPlayingViewController.startNewAudio = YES;
        }
    }
}

#pragma mark - Table view data source

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.fetchedResultsController == nil)
    {
        return [[NSArray alloc] init];
    }
    else
    {
        return self.sectionIndexTitles;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.fetchedResultsController == nil)
    {
        return @"";
    }
    else
    {
        return [self.sectionTitles objectAtIndex:section];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.fetchedResultsController == nil)
    {
        return 1;
    }
    else
    {
        return self.fetchedResultsController.sections.count + 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    if (self.fetchedResultsController == nil)
    {
        returnValue = self.playlist.playlistSongs.count;
    }
    else
    {
        if (section > 0)
        {
            // Return the number of rows in the section.
            NSArray *sections = self.fetchedResultsController.sections;
            
            id <NSFetchedResultsSectionInfo> sectionInfo;
            sectionInfo = [sections objectAtIndex:section - 1];
            
            returnValue = sectionInfo.numberOfObjects;
        }
    }
    
    return returnValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistSongCell" forIndexPath:indexPath];

    if (self.fetchedResultsController == nil)
    {
        [self configureCell:cell atIndexPath:indexPath];
    }
    else
    {
        NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        
        [self configureCell:cell atIndexPath:realIndexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.playlist.playlistSongs.count > 50)
    {
        return 22.0f;
    }
    else
    {
        return 0.0f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.playlist.playlistSongs.count > 50)
    {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
        [sectionView setBackgroundColor:[UIColor blackColor]];
        
        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,tableView.bounds.size.width, 22)];
        headerLabel.textColor = [UIColor orangeColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:20.0];
        
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:section];
        
        if (sectionTitle)
        {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:sectionTitle];
            [attString addAttribute:NSUnderlineStyleAttributeName
                              value:[NSNumber numberWithInt:NSUnderlineStyleDouble]
                              range:(NSRange){0,[attString length]}];
            
            headerLabel.attributedText = attString;
        }
        
        [sectionView addSubview:headerLabel];
        
        return sectionView;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma Fetched results controller delegate

- (void)configureCell: (UITableViewCell *)tableViewCell atIndexPath: (NSIndexPath *)indexPath
{
    // Configure the cell...
    Song *song;
    
    // Configure the cell...
    if (self.fetchedResultsController == nil)
    {
        song = [self.playlist.playlistSongs objectAtIndex:indexPath.row];
    }
    else
    {
        song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    tableViewCell.textLabel.text = song.songTitle;
    tableViewCell.detailTextLabel.text = song.artist;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
