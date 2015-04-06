//
//  FetchedTableViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/17/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "FetchedTableViewController.h"
#import "Logger.h"

@interface FetchedTableViewController ()
{
    CGFloat beginYOffset;
}
@end

@implementation FetchedTableViewController

@synthesize tableView = _tableView;

@synthesize mySearchBar = _mySearchBar;
@synthesize searchBarShown = _searchBarShown;
@synthesize searchBarText = _searchBarText;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithTableView: (UITableView *)tableView
{
    if (self)
    {
        _tableView = tableView;
    }
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _fetchedResultsController = nil;
        
        _mySearchBar = nil;
        _searchBarShown = NO;
        _searchBarText = nil;
        
        beginYOffset = 0.0f;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)assignFetchedResultsController: (NSFetchedResultsController *)fetchedResultsController;
{
    self.fetchedResultsController = fetchedResultsController;
}

- (void)resizeTableView: (CGFloat)amount
{
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y += amount;
    tableFrame.size.height -= amount;
    self.tableView.frame = tableFrame;
}

- (void)showSearchBar
{
    if (!self.mySearchBar)
    {
        self.mySearchBar = [[UISearchBar alloc] init];
        [self.mySearchBar setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.view.frame.size.width, 55)];
        [self.mySearchBar setShowsCancelButton:YES animated:YES];
        [self.mySearchBar setBarStyle:UIBarStyleBlackOpaque];
        [self.mySearchBar setTintColor:[UIColor whiteColor]];
        [self.view addSubview: self.mySearchBar];
        self.mySearchBar.delegate = self;
    }
    else
    {
        self.mySearchBar.alpha = 1.0f;
    }
    
    [self resizeTableView:55.0f];
}

- (void)hideSearchBar
{
    self.mySearchBar.alpha = 0.0f;
    [self resizeTableView:-55.0f];
}

-(void)showHideSearchBar
{
    if (self.searchBarShown)
    {
        [self hideSearchBar];
    }
    else
    {
        [self showSearchBar];
    }
    
    self.searchBarShown = !self.searchBarShown;
}

- (void)clearSearchBarText
{
    self.mySearchBar.text = @"";
    self.searchBarText = nil;
}

- (void)createNewFetchedResultsController: (NSString *)searchString
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index == 0 && self.fetchedResultsController)
    {
        [self showHideSearchBar];
    }
    
    return index;
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self clearSearchBarText];
    [self.mySearchBar resignFirstResponder];
    [self showHideSearchBar];
    [self createNewFetchedResultsController:self.searchBarText];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        self.searchBarText = searchText;
    }
    else
    {
        self.searchBarText = nil;
    }
    
    [self createNewFetchedResultsController:self.searchBarText];
}


#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginYOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (beginYOffset >= 0.0f && scrollView.contentOffset.y < -30.0f && self.fetchedResultsController)
    {
        beginYOffset = -1.0f;
        [self showHideSearchBar];
    }
}

@end
