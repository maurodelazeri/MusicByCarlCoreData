//
//  AllArtistsViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/30/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "DatabaseInterface.h"

#import "AllArtistsViewController.h"
#import "AlbumDetailViewController.h"
#import "NowPlayingViewController.h"

#import "Artist.h"
#import "Utilities.h"
#import "Logger.h"

@implementation AllArtistsViewController

- (void)createNewFetchedResultsController
{
    self.fetchedResultsController = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    
    if (self.artistsPtr.genreFilter.length > 0)
    {
        self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Artist" withKeyPath:@"indexCharacter" secondarySortKey:@"strippedName" andFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
        {
            [inputFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY artistGenres.name == %@", self.artistsPtr.genreFilter]];
            return inputFetchRequest;
        }];
    }
    else
    {
        self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Artist" withKeyPath:@"indexCharacter" andSecondarySortKey:@"strippedName"];
    }
    
    self.sectionTitles = [Utilities convertSectionTitles:self.fetchedResultsController];
    self.sectionIndexTitles = [Utilities convertSectionIndexTitles:self.fetchedResultsController];
    
    self.fetchedResultsController.delegate = self;
    
    [self.tableView reloadData];
}

- (Artists *)artistsPtr
{
    if (!_artistsPtr)
    {
        _artistsPtr = [Artists sharedArtists];
    }
    
    return _artistsPtr;
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
    
    self.tableView.sectionIndexBackgroundColor = [UIColor blackColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.artistsPtr.genreFilter.length > 0)
    {
        self.showAllButton.title = @"Show All";
    }
    else
    {
        self.showAllButton.title = @"";
    }
    
    [self createNewFetchedResultsController];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAllButtonPressed:(id)sender
{
    if (self.showAllButton.title.length > 0)
    {
        self.showAllButton.title = @"";
        self.artistsPtr.genreFilter = nil;
        [self createNewFetchedResultsController];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"nowPlayingSegue"])
    {
        NowPlayingViewController *nowPlayingViewController = [segue destinationViewController];
        nowPlayingViewController.startNewAudio = NO;
        nowPlayingViewController.shuffleAllFlag = NO;
        nowPlayingViewController.nowPlayingSegue = YES;
    }
    else
    {
        if ([[segue identifier] isEqualToString:@"artistAlbumsSegue"])
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            Artist *selectedArtist = [self.fetchedResultsController objectAtIndexPath:realIndexPath];
            
            AlbumDetailViewController *albumDetailViewController = [segue destinationViewController];
            albumDetailViewController.albumInternalIDs = [[NSMutableOrderedSet alloc] init];
            Album *currentAlbum;
            for (int i = 0; i < selectedArtist.artistAlbums.count; i++)
            {
                currentAlbum = [selectedArtist.artistAlbums objectAtIndex:i];
                [albumDetailViewController.albumInternalIDs addObject:currentAlbum.internalID];
            }
        }
    }
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
    
    if (section > 0)
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"artistCell" forIndexPath:indexPath];
    
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
    Artist *currentArtist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    tableViewCell.textLabel.textColor = [UIColor whiteColor];
    tableViewCell.textLabel.text = currentArtist.name;
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
