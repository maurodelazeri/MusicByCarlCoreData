//
//  Itoast.m
//  MusicByCarlCoreData
//
//  Created by Carleton Smith on 1/8/14.
//  Copyright (c) 2014 Bulletin Net Inc. All rights reserved.
//

#import "IToast.h"

#import "Logger.h"

@implementation IToast

@synthesize completionHandler = _completionHandler;

- (void)showToast: (NSString *)alertTitle withMessage: (NSString *)alertMessage forDuration: (NSTimeInterval)duration withCompletionHandler: (void(^)(void))completionHandler
{
    self.completionHandler = completionHandler;
    
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"MusicByCarlCoreData Alert"
                                                    message:alertMessage
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [toast show];
    
    [self performSelector:@selector(cancelToast:) withObject:toast afterDelay:duration];
}

- (void)cancelToast: (id)toast
{
    [toast dismissWithClickedButtonIndex:0 animated:YES];
    
    self.completionHandler();
}

@end
