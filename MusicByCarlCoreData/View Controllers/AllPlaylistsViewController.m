//
//  AllPlaylistsViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/3/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "AllPlaylistsViewController.h"
#import "PlaylistDetailViewController.h"
#import "NowPlayingViewController.h"
#import "DatabaseManager.h"
#import "AllArtistsViewController.h"

#import "Utilities.h"
#import "GlobalConstants.h"
#import "Playlist.h"
#import "Playlists.h"
#import "Logger.h"

@interface AllPlaylistsViewController () <UIContentContainer>
{
    Playlists *playlistsPtr;
    NSUInteger lastNumberOfPlaylists;
}

@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;
@end

@implementation AllPlaylistsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    playlistsPtr = [Playlists sharedPlaylists];
    lastNumberOfPlaylists = 0;

    UITabBarItem *item1 = [[self.tabBarController.tabBar items] objectAtIndex:PLAYLISTS_TAB];
    UIImage *item1Image;
    item1Image = [self returnRenderedImage:@"Playlists-tab-bar-icon.png"];
    [item1 setImage:item1Image];
    
    UITabBarItem *item2 = [[self.tabBarController.tabBar items] objectAtIndex:ARTISTS_TAB];
    UIImage *item2Image;
    item2Image = [self returnRenderedImage:@"Artists-tab-bar-icon.png"];
    [item2 setImage:item2Image];
    
    UITabBarItem *item3 = [[self.tabBarController.tabBar items] objectAtIndex:SONGS_TAB];
    UIImage *item3Image;
    item3Image = [self returnRenderedImage:@"Songs-tab-bar-icon.png"];
    [item3 setImage:item3Image];
    
    UITabBarItem *item4 = [[self.tabBarController.tabBar items] objectAtIndex:ALBUMS_TAB];
    UIImage *item4Image;
    item4Image = [self returnRenderedImage:@"Albums-tab-bar-icon.png"];
    [item4 setImage:item4Image];
    
    UITabBarItem *item5 = [[self.tabBarController.tabBar items] objectAtIndex:MORE_TAB];
    UIImage *item5Image;
    item5Image = [self returnRenderedImage:@"More-tab-bar-icon.png"];
    [item5 setImage:item5Image];
    
    [self.tabBarController setDelegate:self];
}

- (UIImage *)returnRenderedImage:(NSString *)imageName
{
    UIImage *returnValue;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        returnValue = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else
    {
        returnValue = [UIImage imageNamed:imageName];
    }
    
    return returnValue;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lastInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    NSUInteger currentNumberOfPlaylists = [playlistsPtr numberOfPlaylistsInDatabase];
    
    if (currentNumberOfPlaylists != lastNumberOfPlaylists)
    {
        lastNumberOfPlaylists = currentNumberOfPlaylists;
        [self.tableView reloadData];
    }
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
    if ([[segue identifier] isEqualToString:@"selectPlaylist"])
    {
        PlaylistDetailViewController *detailViewController = [segue destinationViewController];
        
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        Playlist *selectedItem = [playlistsPtr fetchPlaylistWithInternalID:selectedIndex];
        
        [detailViewController setPlaylist:selectedItem];
    }
    else
    {
        if ([[segue identifier] isEqualToString:@"nowPlayingSegue"])
        {
            NowPlayingViewController *nowPlayingViewController = [segue destinationViewController];
            nowPlayingViewController.shuffleAllFlag = NO;
            nowPlayingViewController.startNewAudio = NO;
            nowPlayingViewController.nowPlayingSegue = YES;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [playlistsPtr numberOfPlaylistsInDatabase];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"playlistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Playlist *currentPlaylist;
    currentPlaylist = [playlistsPtr fetchPlaylistWithInternalID:indexPath.row];
    
    cell.textLabel.text = currentPlaylist.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    DatabaseManager *databaseManagerPtr = [DatabaseManager sharedDatabaseManager];
    return !databaseManagerPtr.databaseBuildInProgress;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController class] == [UINavigationController class])
    {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        [navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
