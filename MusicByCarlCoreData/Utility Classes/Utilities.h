//
//  Utilities.h
//  MusicByCarl
//
//  Created by CarlSmith on 3/24/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#include <mach/mach.h>
#include <mach/mach_time.h>

#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"

extern const double secondsInADay;

@interface Utilities : NSObject

+ (NSString *)songsArchiveFilePath;
+ (NSString *)userPreferencesArchiveFilePath;
+ (NSString *)globalVarsArchiveFilePath;
+ (NSString *)currentSongsInfoArchiveFilePath;
+ (NSString *)loggerArchiveFilePath;

+ (uint64_t) getTickCount;

+ (NSString *)convertDoubleTimeToString: (double) inputTime;

+ (BOOL) stringIsNumeric: (NSString *)inputString;

+ (BOOL) stringIsAlphaNumeric: (NSString *)inputString;

+ (NSString *)removeLeadingArticles: (NSString *)inputString;

+ (NSString *)getMediaObjectIndexCharacter:(NSString *)mediaObjectString;
+ (NSString *)getMediaObjectStrippedString:(NSString *)mediaObjectString;

+(UIButton *)customizeLeftBarButton: (UIViewController *)viewController withText: (NSString *)buttonText andWidth: (CGFloat) width;
+ (void)drawLeftBarButton: (UIViewController *)viewController;

+(UIButton *)createNowPlayingButton;

+(UIBarButtonItem *)showNowPlayingButton: (UIViewController *)viewController withNowPlayingButton: (UIButton *)nowPlayingButton;

+ (void)sendProgressNotification: (float)progressFraction forOperationType: (NSString *)operationType duringBuildAll: (BOOL)duringBuildAll;

+ (void)writelnToStandardOut: (NSString *)stringToWrite;

+ (NSArray *)convertSectionTitles: (NSFetchedResultsController *)fetchedResultsController;
+ (NSArray *)convertSectionIndexTitles: (NSFetchedResultsController *)fetchedResultsController;

+ (NSString *)documentsDirectoryPath;

+ (NSString *)routeChangeReasonToString: (SInt32) routeChangeReason;

+ (NSString *)dateToString: (NSDate *)date;
+ (NSString *)timeStampToString: (NSDate *)date;
+ (NSString *)returnNSStringFromNSDate:(NSDate *)date;

// Start a spinner in the center of the UIView specified as a parameter
+ (UIActivityIndicatorView *)startSpinner: (UIView *)view withStyle: (UIActivityIndicatorViewStyle)indicatorStyle;

// Stop and nil a spinner
+ (void)stopAndNilSpinner: (UIActivityIndicatorView *)spinner;

+ (void)showErrorAlert: (NSString *)alertText withDelegate: (UIViewController *)viewController;
+ (UIAlertView *)showOkButtonAlert: (NSString *)title message: (NSString *)message delegate: (id)delegate;
+ (UIAlertView *)showNoButtonAlert: (NSString *)title message: (NSString *)message;

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;

+ (NSString *)interfaceOrientationToString:(UIInterfaceOrientation)orientation;

+ (void)segueToCoverFlow:(UIViewController *)viewController;

@end
