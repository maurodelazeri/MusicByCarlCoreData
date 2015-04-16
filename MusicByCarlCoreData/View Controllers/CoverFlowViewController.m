//
//  CoverFlowViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "CoverFlowViewController.h"
#import "CoverFlowLayout.h"
#import "AlbumImageCell.h"
#import "AlbumTextLabelsData.h"
#import "GlobalVars.h"

#import "Album.h"
#import "Albums.h"
#import "DatabaseInterface.h"
#import "DatabaseManager.h"

#import "Logger.h"

@interface CoverFlowViewController() <UIContentContainer>
{
    __weak IBOutlet UICollectionView *collectionViewOutlet;
    __weak IBOutlet UILabel *artistLabel;
    __weak IBOutlet UILabel *songTitleLabel;
    __weak IBOutlet UILabel *albumTitleLabel;
    BOOL previousNavBarHidden;
    BOOL previousTabBarHidden;
    NSInteger currentAlbum;
}

@property (strong, nonatomic) DatabaseManager *databaseManagerPtr;
@property (strong, nonatomic) NSMutableDictionary *imageToOperationDictionary;
@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;
@end

@implementation CoverFlowViewController

- (DatabaseManager *)databaseManagerPtr {
    if (!_databaseManagerPtr) {
        _databaseManagerPtr = [[DatabaseManager alloc] init];
    }
    
    return _databaseManagerPtr;
}

- (NSMutableDictionary *)imageToOperationDictionary {
    if (!_imageToOperationDictionary) {
        _imageToOperationDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return _imageToOperationDictionary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CoverFlowLayout *layout = [[CoverFlowLayout alloc] init];
    collectionViewOutlet.collectionViewLayout = layout;
    
    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    previousNavBarHidden = self.navigationController.navigationBarHidden;
    previousTabBarHidden = self.tabBarController.tabBar.hidden;
    
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    GlobalVars *globalVarsPtr = [GlobalVars sharedGlobalVars];
    currentAlbum = globalVarsPtr.currentAlbum.integerValue;
    
    if (currentAlbum != -1) {
        [collectionViewOutlet scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentAlbum inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lastInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (self.lastInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self displayTextForAlbumAtScreenCenter];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = previousNavBarHidden;
    self.tabBarController.tabBar.hidden = previousTabBarHidden;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    [super viewDidDisappear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         
         if (self.lastInterfaceOrientation != UIInterfaceOrientationUnknown && orientation != self.lastInterfaceOrientation)
         {
             if (orientation == UIInterfaceOrientationPortrait)
             {
                 [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
/*
        CGPoint touchPoint = [gestureRecognizer locationInView:collectionViewOutlet];
        NSIndexPath *indexPath = [collectionViewOutlet indexPathForItemAtPoint:touchPoint];
 
        DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
        AlbumTextLabelsData *albumTextLabelsData = [Albums fetchAlbumTextDataWithAlbumInternalID:indexPath.row andDatabasePtr:databaseInterfacePtr];
        
        NSLog(@"Album artist: %@", albumTextLabelsData.albumArtistString);
        NSLog(@"Album title: %@", albumTextLabelsData.albumTitleString);
        NSLog(@"Song title: %@", albumTextLabelsData.songTitleString);
*/
    }
}

#pragma mark UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AlbumImageCell";
    
    AlbumImageCell *cell = (AlbumImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    UIImage *albumArtworkImage = [Albums fetchAlbumImageWithAlbumInternalID:indexPath.row withSize:CGSizeMake(130.0f, 130.0f) andDatabasePtr:databaseInterfacePtr];
    cell.albumArtworkImage.image = albumArtworkImage;
    
    cell.albumArtworkReflectionImage.image = albumArtworkImage;
    cell.albumArtworkReflectionImage.transform = CGAffineTransformMakeRotation(M_PI); //rotation image 180 degrees (pi radians)
    
    return cell;
}

#pragma mark UICollectionViewDelegate

// Number of rows in the section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Albums numberOfAlbumsInDatabase];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0.0f, 0.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0.0f, 0.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self displayTextForAlbumAtScreenCenter];
}

- (void)displayTextForAlbumAtScreenCenter
{
    CGPoint screenCenter = collectionViewOutlet.contentOffset;
    screenCenter.x += CGRectGetMidX(collectionViewOutlet.frame);
    
    NSIndexPath *indexPath = [collectionViewOutlet indexPathForItemAtPoint:screenCenter];
    if (indexPath != nil)
    {
        [self displayTextForAlbumWithIndex:indexPath.row];
    }
}

- (void)displayTextForAlbumWithIndex:(NSUInteger)albumRowIndex
{
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    AlbumTextLabelsData *albumTextLabelsData = [Albums fetchAlbumTextDataWithAlbumInternalID:albumRowIndex andDatabasePtr:databaseInterfacePtr];
    
    artistLabel.text = albumTextLabelsData.albumArtistString;
    
    if (albumRowIndex == currentAlbum)
    {
        albumTitleLabel.text = albumTextLabelsData.albumTitleString;
        songTitleLabel.text = albumTextLabelsData.songTitleString;
    }
    else
    {
        albumTitleLabel.text = @"";
        songTitleLabel.text = albumTextLabelsData.albumTitleString;
    }
}

@end