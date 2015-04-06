//
//  EmailLogViewController.m
//  MusicByCarlCoreData
//
//  Created by Carleton Smith on 1/8/14.
//  Copyright (c) 2014 Carleton Smith. All rights reserved.
//

#import "EmailLogViewController.h"
#import "IToast.h"

#import "Logger.h"
#import "Utilities.h"

@interface EmailLogViewController ()
{
    BOOL composeMailViewControllerRequested;
    NSString *emailRecipeTitle;
    IToast *resultToast;
}
@end

@implementation EmailLogViewController

@synthesize composeViewController = _composeViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"backButton.png"];

    self.navigationItem.leftBarButtonItem.target = self;
    self.navigationItem.leftBarButtonItem.action = @selector(popViewController:);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleExitEmailLogNotification:) name:@"MusicByCarlCoreData.exitEmailLogScreenNotification" object:nil];
    
    if (composeMailViewControllerRequested)
    {
        composeMailViewControllerRequested = NO;
        [self showMailComposeViewController];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MusicByCarlCoreData.exitEmailLogScreenNotification" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleExitEmailLogNotification: (NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(popViewController:) withObject:nil waitUntilDone:NO];
}

- (void)popViewController: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestMailComposeViewController
{
    composeMailViewControllerRequested = YES;
}

- (void)showMailComposeViewController
{
    // Check that the current device can send email messages before
    // attempting to create an instance of MFMailComposeViewController.
    if ([MFMailComposeViewController canSendMail])
    // The device can send email.
    {
        [self displayMailComposerSheet];
    }
    else
    // The device can not send email.
    {
		[Utilities showOkButtonAlert:@"MusicByCarlCoreData Alert" message:@"Device not configured to send mail." delegate:self];
    }
}

- (void)displayMailComposerSheet
{
    NSString *currentTime = [Utilities returnNSStringFromNSDate:[NSDate date]];
    
	self.composeViewController = [[MFMailComposeViewController alloc] init];
	self.composeViewController.mailComposeDelegate = self;
	
	[self.composeViewController setSubject:@"MusicByCarlCoreData Log File"];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"carl@afterburnerimages.com"];
	
	[self.composeViewController setToRecipients:toRecipients];
	
    [Logger writeLogFileToDisk];
    
	// Attach the log file to the email
	NSString *logFilePath = [Logger logFilePath];
	NSData *logFileData = [NSData dataWithContentsOfFile:logFilePath];
    
	[self.composeViewController addAttachmentData:logFileData mimeType:@"text" fileName:@"MusicByCarlCoreDataLog.txt"];
	
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"MusicByCarlCoreData Log sent at %@", currentTime];
	[self.composeViewController setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:self.composeViewController animated:NO completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *resultString;
    NSTimeInterval toastDuration = 2.0f;
    
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			resultString = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			resultString = @"Result: Mail saved";
            toastDuration = 2.0f;
			break;
		case MFMailComposeResultSent:
			resultString = @"Result: Mail sent";
            toastDuration = 2.0f;
			break;
		case MFMailComposeResultFailed:
			resultString = @"Result: Mail sending failed";
			break;
		default:
			resultString = @"Result: Mail not sent";
			break;
	}
    
    resultToast = [[IToast alloc] init];
    [resultToast showToast:@"MusicByCarlCoreData Alert" withMessage:resultString forDuration:toastDuration withCompletionHandler:^(void)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.exitEmailLogScreenNotification" object:self];
        
        [self dismissViewControllerAnimated:NO completion:NULL];
    }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
