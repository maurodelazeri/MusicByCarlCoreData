//
//  EmailLogViewController.h
//  DealSiftr
//
//  Created by Carleton Smith on 1/8/14.
//  Copyright (c) 2014 Carleton Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface EmailLogViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MFMailComposeViewController *composeViewController;

- (void)requestMailComposeViewController;

@end
