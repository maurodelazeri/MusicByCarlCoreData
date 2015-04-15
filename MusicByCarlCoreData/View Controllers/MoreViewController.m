//
//  MoreViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/14/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "MoreViewController.h"
#import "EmailLogViewController.h"
#import "MoreCell.h"

#import "Utilities.h"

@interface MoreViewController () <UIContentContainer>
{
    NSArray *categories;
    NSArray *icons;
}

@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;
@end

@implementation MoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lastInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    // Do any additional setup after loading the view.
    categories = @[@"Genres", @"Database", @"Email Log"];
    icons = @[[UIImage imageNamed:@"Genres-tab-bar-icon.png"],
              [UIImage imageNamed:@"Database-tab-bar-icon.png"],
              [UIImage imageNamed:@"Email-log-tab-bar-icon.png"]];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"emailLogSegue"])
    {
        EmailLogViewController *emailLogViewController = (EmailLogViewController *)segue.destinationViewController;
        
        if (emailLogViewController != nil)
        {
            [emailLogViewController requestMailComposeViewController];
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
    return categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoreCell";
    MoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.categoryLabel.text = [categories objectAtIndex:indexPath.row];
    cell.iconImageView.image = [icons objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"genresSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"databaseSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"emailLogSegue" sender:self];
            break;
    }
}

@end
