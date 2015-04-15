//
//  AllSongsViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "DatabaseInterface.h"
#import "Song.h"
#import "Songs.h"
#import "SongCell.h"
#import "AllSongsViewController.h"
#import "NowPlayingViewController.h"
#import "CurrentSongsInfo.h"

#import "Utilities.h"
#import "Logger.h"

@interface AllSongsViewController () <UIContentContainer>
{
    Songs *songsPtr;
    NSUInteger lastNumberOfSongs;
}

@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;
@end

@implementation AllSongsViewController

@synthesize tableView = _tableView;

- (AudioPlayback *)audioPlaybackPtr
{
    if (!_audioPlaybackPtr)
    {
        _audioPlaybackPtr = [AudioPlayback sharedAudioPlayback];
    }
    
    return _audioPlaybackPtr;
}

- (id)init
{
    self = [super initWithTableView:_tableView];
    
    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeFloat:self.tableView.contentOffset.x forKey:@"tableContentOffsetX"];
    [coder encodeFloat:self.tableView.contentOffset.y forKey:@"tableContentOffsetY"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    CGFloat tableViewContentOffsetX = [coder decodeFloatForKey:@"tableContentOffsetX"];
    CGFloat tableViewContentOffsetY = [coder decodeFloatForKey:@"tableContentOffsetY"];
    self.tableView.contentOffset = CGPointMake(tableViewContentOffsetX, tableViewContentOffsetY);
    [super decodeRestorableStateWithCoder:coder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    songsPtr = [Songs sharedSongs];
    lastNumberOfSongs = 0;
    
    [self.tableView setBackgroundColor: [UIColor clearColor]];
    [self.tableView setOpaque: NO];
        
    self.tableView.sectionIndexBackgroundColor = [UIColor blackColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![[segue identifier] isEqualToString:@"ShowCoverFlow"]) {
        NowPlayingViewController *nowPlayingViewController = [segue destinationViewController];
        nowPlayingViewController.shuffleAllFlag = NO;
        
        if ([[segue identifier] isEqualToString:@"playNewSong"])
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            Song *currentSong = [self.fetchedResultsController objectAtIndexPath:realIndexPath];
            
            CurrentSongsInfo *currentSongsInfo = [CurrentSongsInfo sharedCurrentSongsInfo];
            [currentSongsInfo resetCurrentSongsInfoArrays];
            [currentSongsInfo addAllCurrentSongListSongs:[songsPtr fetchAllSongInternalIDs]];
            [currentSongsInfo updateCurrentSongIndex:currentSong.internalID.integerValue];
            
            nowPlayingViewController.newSongList = YES;
            nowPlayingViewController.startNewAudio = YES;
        }
        else
        {
            if ([[segue identifier] isEqualToString:@"nowPlayingSegue"])
            {
                nowPlayingViewController.startNewAudio = NO;
                nowPlayingViewController.nowPlayingSegue = YES;
            }
        }
    }
}

- (void)createNewFetchedResultsController: (NSString *)searchString
{
    self.fetchedResultsController = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    
    if (searchString)
    {
        self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Song" withKeyPath:@"indexCharacter" secondarySortKey:@"strippedSongTitle" andFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
        {
            NSString *formatString = [NSString stringWithFormat:@"songTitle contains[cd] \'%@\'", searchString];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];
            [inputFetchRequest setPredicate:predicate];
            
            return inputFetchRequest;
        }];
    }
    else
    {
        self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Song" withKeyPath:@"indexCharacter" andSecondarySortKey:@"strippedSongTitle"];
    }
    
    self.sectionTitles = [Utilities convertSectionTitles:self.fetchedResultsController];
    self.sectionIndexTitles = [Utilities convertSectionIndexTitles:self.fetchedResultsController];
    
    self.fetchedResultsController.delegate = self;
    [self.tableView reloadData];
    
    [self assignFetchedResultsController:self.fetchedResultsController];
}

#pragma mark - Table view data source

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.fetchedResultsController.sections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    if (section != 0)
    {
        // Return the number of rows in the section.
        NSArray *sections = self.fetchedResultsController.sections;
        
        id <NSFetchedResultsSectionInfo> sectionInfo;
        sectionInfo = [sections objectAtIndex:section - 1];
        
        returnValue = sectionInfo.numberOfObjects;
    }
    
    return returnValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songCell" forIndexPath:indexPath];

    NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    [self configureCell:cell atIndexPath:realIndexPath];
    
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma Fetched results controller delegate

- (void)configureCell: (UITableViewCell *)tableViewCell atIndexPath: (NSIndexPath *)indexPath
{
    // Configure the cell...
    Song *currentSong = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    tableViewCell.textLabel.text = currentSong.songTitle;
    tableViewCell.detailTextLabel.text = currentSong.artist;
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
