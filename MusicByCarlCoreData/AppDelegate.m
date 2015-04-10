//
//  AppDelegate.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "UserPreferences.h"
#import "CurrentSongsInfo.h"
#import "CoverFlowViewController.h"
#import "Crittercism.h"

#import "GlobalVars.h"
#import "AudioPlayback.h"
#import "Songs.h"

#import "Logger.h"

@interface AppDelegate ()
{
    UITabBarController *rootViewController;
}

@property (strong, nonatomic) GlobalVars *globalVarsPtr;
@property (strong, nonatomic) AudioPlayback *audioPlaybackPtr;
@property (strong, nonatomic) UserPreferences *userPreferencesPtr;
@property (strong, nonatomic) CurrentSongsInfo *currentSongsInfoPtr;
@property (strong, nonatomic) Logger *loggerPtr;
@end

@implementation AppDelegate

- (GlobalVars *)globalVarsPtr {
    if (!_globalVarsPtr) {
        _globalVarsPtr = [GlobalVars sharedGlobalVars];
    }
    
    return _globalVarsPtr;
}

- (AudioPlayback *)audioPlaybackPtr
{
    if (!_audioPlaybackPtr)
    {
        _audioPlaybackPtr = [AudioPlayback sharedAudioPlayback];
    }
    
    return _audioPlaybackPtr;
}

- (UserPreferences *)userPreferencesPtr
{
    if (!_userPreferencesPtr)
    {
        _userPreferencesPtr = [UserPreferences sharedUserPreferences];
    }
    
    return _userPreferencesPtr;
}

- (CurrentSongsInfo *)currentSongsInfoPtr
{
    if (!_currentSongsInfoPtr)
    {
        _currentSongsInfoPtr = [CurrentSongsInfo sharedCurrentSongsInfo];
    }
    
    return _currentSongsInfoPtr;
}

- (Logger *)loggerPtr
{
    if (!_loggerPtr)
    {
        _loggerPtr = [Logger sharedLogger];
    }
    
    return _loggerPtr;
}

#define SIM(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    SIM([self reportSimulatorError]);
    
    //[Crittercism enableWithAppID:@"5436e2ca0729df6b3d000003"];
    
    rootViewController = (UITabBarController *)self.window.rootViewController;
    
    [self registerOrientationChangedObserver];
    
    // Set an uncaught exception handler that logs a complete stack trace
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [self createCustomGUI];
    
    DatabaseManager *databaseManagerPtr = [DatabaseManager sharedDatabaseManager];
    
    // Initialize the Managed Object Model and Store
    [databaseManagerPtr initModelAndStore];

    [self.userPreferencesPtr loadUserPreferences];
    
    return YES;
}

- (void)reportSimulatorError
{
    NSLog(@"This code won't run successfully on the simulator!");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self archiveAppData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)registerOrientationChangedObserver {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UINavigationController *currentNavigationController = (UINavigationController *)rootViewController.selectedViewController;
    UIViewController *visibleViewController = currentNavigationController.visibleViewController;

    UIDevice *device = notification.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            [self segueToCoverFlow:currentNavigationController.visibleViewController];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self segueToCoverFlow:currentNavigationController.visibleViewController];
            break;
            
        case UIDeviceOrientationPortrait:
            if ([visibleViewController class] == [CoverFlowViewController class]) {
                [visibleViewController.navigationController popViewControllerAnimated:YES];
            }
            break;
            
        default:
            break;
    };
}

- (void)segueToCoverFlow:(UIViewController *)currentlyVisibleController {
    @try {
        [currentlyVisibleController performSegueWithIdentifier:@"ShowCoverFlow" sender:currentlyVisibleController];
    }
    @catch (NSException *exception) {
        NSLog(@"Segue not found: %@", exception);
    }
}

- (void) createCustomGUI
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    }
    else
    {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],
                                                          NSForegroundColorAttributeName,
                                                          nil]];
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"Tab-bar.png"]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"Tab-bar-item-selected.png"]];
    [[UITabBar appearance] setSelectedImageTintColor: [UIColor blackColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(1.0f, 1.0f);

    NSDictionary *titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.278 green:0.278 blue:0.278 alpha:1.0],
                                          NSShadowAttributeName: shadow};
    [[UITabBarItem appearance] setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
}

#pragma mark - App State Preservation and Restoration

- (void)archiveAppData
{
    [self.globalVarsPtr archiveData];
    [self.userPreferencesPtr archiveData];
    [self.currentSongsInfoPtr archiveData];
    [self.loggerPtr archiveData];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (NSString *)eventTypeToString:(UIEventType)eventType
{
    NSString *returnValue = @"";
    
    switch (eventType)
    {
        case UIEventTypeTouches:
            returnValue = @"UIEventTypeTouches";
            break;
            
        case UIEventTypeMotion:
            returnValue = @"UIEventTypeMotion";
            break;
            
        case UIEventTypeRemoteControl:
            returnValue = @"UIEventTypeRemoteControl";
            break;
    }
    
    return returnValue;
}

- (NSString *)eventSubtypeToString:(UIEventSubtype)eventSubtype
{
    NSString *returnValue = @"";
    
    switch (eventSubtype)
    {
        case  UIEventSubtypeNone:
            returnValue = @"UIEventSubtypeNone";
            break;
            
        case  UIEventSubtypeMotionShake:
            returnValue = @"UIEventSubtypeMotionShake";
            break;
            
        case  UIEventSubtypeRemoteControlPlay:
            returnValue = @"UIEventSubtypeRemoteControlPlay";
            break;
            
        case  UIEventSubtypeRemoteControlPause:
            returnValue = @"UIEventSubtypeRemoteControlPause";
            break;
            
        case  UIEventSubtypeRemoteControlStop:
            returnValue = @"UIEventSubtypeRemoteControlStop";
            break;
            
        case  UIEventSubtypeRemoteControlTogglePlayPause:
            returnValue = @"UIEventSubtypeRemoteControlTogglePlayPause";
            break;
            
        case  UIEventSubtypeRemoteControlNextTrack:
            returnValue = @"UIEventSubtypeRemoteControlNextTrack";
            break;
            
        case  UIEventSubtypeRemoteControlPreviousTrack:
            returnValue = @"UIEventSubtypeRemoteControlPreviousTrack";
            break;
            
        case  UIEventSubtypeRemoteControlBeginSeekingBackward:
            returnValue = @"UIEventSubtypeRemoteControlBeginSeekingBackward";
            break;
            
        case  UIEventSubtypeRemoteControlEndSeekingBackward:
            returnValue = @"UIEventSubtypeRemoteControlEndSeekingBackward";
            break;
            
        case  UIEventSubtypeRemoteControlBeginSeekingForward:
            returnValue = @"UIEventSubtypeRemoteControlBeginSeekingForward";
            break;
            
        case  UIEventSubtypeRemoteControlEndSeekingForward:
            returnValue = @"UIEventSubtypeRemoteControlEndSeekingForward";
            break;
            
    }
    
    return returnValue;
}

#pragma mark Remote-control event handling
// Respond to remote control events
- (void) remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        switch (receivedEvent.subtype)
        {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if ([self.audioPlaybackPtr isAudioPlaying])
                {
                    [self.audioPlaybackPtr pauseAudio];
                }
                else
                {
                    [self.audioPlaybackPtr playAudio];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self];
            }
            break;
                
            case UIEventSubtypeRemoteControlPause:
            {
                [self.audioPlaybackPtr pauseAudio];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self];
            }
            break;
                
            case UIEventSubtypeRemoteControlPlay:
            {
                [self.audioPlaybackPtr playAudio];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.updatePlayPauseButton" object:self];
            }
            break;
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self.audioPlaybackPtr goToNextSong];
            }
            break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self.audioPlaybackPtr goToPreviousSong];
            }
            break;
                
            default:
            break;
        }
    }
}

#pragma mark - Uncaught Exception Handler

// This handler logs a complete stack trace if an exception occurs
void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    [Logger writeToLogFileSpecial:[NSString stringWithFormat:@"CRASH: %@", exception]];
    [Logger writeToLogFileSpecial:[NSString stringWithFormat:@"Stack Trace: %@", [exception callStackSymbols]]];
    // Internal error reporting
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    exit(-1);
}

@end
