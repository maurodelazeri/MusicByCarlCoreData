//
//  AllAlbumsViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "AllAlbumsViewController.h"
#import "AlbumDetailViewController.h"
#import "NowPlayingViewController.h"

#import "Album.h"
#import "Utilities.h"
#import "Logger.h"

@interface AllAlbumsViewController ()
{
    NSUInteger lastNumberOfAlbums;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *albumTypeButton;
@end

@implementation AllAlbumsViewController

@synthesize tableView = _tableView;

- (id)init
{
    self = [super initWithTableView:_tableView];
    
    return self;
}

- (void)createNewFetchedResultsController: (NSString *)searchString
{
    self.fetchedResultsController = nil;
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    
    if (self.instrumentalAlbumsFlag)
    {
        self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Album" withKeyPath:@"indexCharacter" secondarySortKey:@"strippedTitle" andFetchRequestChangeBlock:
                                    ^NSFetchRequest *(NSFetchRequest *inputFetchRequest)
                                    {
                                        NSString *predicateString = [NSString stringWithFormat:@"isInstrumental == %@", [NSNumber numberWithBool:YES]];
                                        
                                        if (searchString)
                                        {
                                            NSString *searchPredicateString = [NSString stringWithFormat:@" AND title contains[cd] \'%@\'", searchString];
                                            predicateString = [predicateString stringByAppendingString:searchPredicateString];
                                        }
                                        inputFetchRequest.predicate = [NSPredicate predicateWithFormat:predicateString];
                                        return inputFetchRequest;
                                    }];
    }
    else
    {
        if (searchString)
        {
            self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Album" withKeyPath:@"indexCharacter" secondarySortKey:@"strippedTitle" andFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *inputFetchRequest) {
                NSString *formatString = [NSString stringWithFormat:@"title contains[cd] \'%@\'", searchString];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];
                [inputFetchRequest setPredicate:predicate];
                
                return inputFetchRequest;
            }];
        }
        else
        {
            self.fetchedResultsController = [databaseInterfacePtr createFetchedResultsController:@"Album" withKeyPath:@"indexCharacter" andSecondarySortKey:@"strippedTitle"];
        }
    }
    
    self.sectionTitles = [Utilities convertSectionTitles:self.fetchedResultsController];
    self.sectionIndexTitles = [Utilities convertSectionIndexTitles:self.fetchedResultsController];
    
    self.fetchedResultsController.delegate = self;
    
    [self.tableView reloadData];
    
    [self assignFetchedResultsController:self.fetchedResultsController];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.instrumentalAlbumsFlag forKey:@"instrumentalAlbumsFlag"];
    [coder encodeFloat:self.tableView.contentOffset.x forKey:@"tableContentOffsetX"];
    [coder encodeFloat:self.tableView.contentOffset.y forKey:@"tableContentOffsetY"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.instrumentalAlbumsFlag = [coder decodeBoolForKey:@"instrumentalAlbumsFlag"];
    CGFloat tableViewContentOffsetX = [coder decodeFloatForKey:@"tableContentOffsetX"];
    CGFloat tableViewContentOffsetY = [coder decodeFloatForKey:@"tableContentOffsetY"];
    self.tableView.contentOffset = CGPointMake(tableViewContentOffsetX, tableViewContentOffsetY);
    [super decodeRestorableStateWithCoder:coder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    lastNumberOfAlbums = 0;
    
    [self.tableView setBackgroundColor: [UIColor clearColor]];
    [self.tableView setOpaque: NO];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor blackColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor blackColor];
    
    UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];

    [self.albumTypeButton setTitleTextAttributes:attrsDictionary forState:UIControlStateNormal];
    self.albumTypeButton.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.instrumentalAlbumsFlag)
    {
        self.albumTypeButton.title = @"Instrumental";
        [self newBarButtonColor:[UIColor orangeColor]];
    }
    else
    {
        self.albumTypeButton.title = @"All";
        [self newBarButtonColor:[UIColor whiteColor]];
    }
    
    [self createNewFetchedResultsController:self.searchBarText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUInteger currentNumberOfAlbums = [Albums numberOfAlbumsInDatabase];
    
    if (currentNumberOfAlbums != lastNumberOfAlbums)
    {
        lastNumberOfAlbums = currentNumberOfAlbums;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newBarButtonColor: (UIColor *)color
{
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     color, NSForegroundColorAttributeName,
                                     [UIFont boldSystemFontOfSize:18.0], NSFontAttributeName,
                                     nil];
    
    [self.albumTypeButton setTitleTextAttributes:attrsDictionary forState:UIControlStateNormal];
}

- (IBAction)albumTypeButtonPressed:(id)sender
{
    if ([self.albumTypeButton.title isEqualToString:@"All"])
    {
        self.albumTypeButton.title = @"Instrumental";
        [self newBarButtonColor:[UIColor orangeColor]];
        self.instrumentalAlbumsFlag = YES;
    }
    else
    {
        self.albumTypeButton.title = @"All";
        [self newBarButtonColor:[UIColor whiteColor]];
        self.instrumentalAlbumsFlag = NO;
    }
    
    [self createNewFetchedResultsController:self.searchBarText];
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
        if ([[segue identifier] isEqualToString:@"SelectAlbum"])
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
            Album *selectedAlbum = [self.fetchedResultsController objectAtIndexPath:realIndexPath];
            
            AlbumDetailViewController *detailViewController = [segue destinationViewController];
            detailViewController.albumInternalIDs = [[NSMutableOrderedSet alloc] init];
            [detailViewController.albumInternalIDs addObject:selectedAlbum.internalID];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
    
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
    Album *currentAlbum = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    tableViewCell.textLabel.text = currentAlbum.title;
    tableViewCell.detailTextLabel.text = currentAlbum.artist;
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
