//
//  Utilities.m
//  MusicByCarl
//
//  Created by CarlSmith on 3/24/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AppDelegate.h"
#import "Utilities.h"
//#import "CSMediaQuerySection.h"
#import "Logger.h"

const double secondsInADay = 60.0 * 60.0 * 24.0;

@interface Utilities ()
@end

@implementation Utilities

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (Utilities *)sharedUtilities
{
    static dispatch_once_t pred = 0;
    __strong static Utilities *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[Utilities alloc] init];
    });
    return _sharedObject;
}

+ (NSString *)globalVarsArchiveFilePath
{
    NSString *archivePath = [self documentsDirectoryPath];
    archivePath = [archivePath stringByAppendingPathComponent:@"MusicByCarlCoreData.globalVarsArchive"];
    
    return archivePath;
}

+ (NSString *)audioPlaybackArchiveFilePath
{
    NSString *archivePath = [self documentsDirectoryPath];
    archivePath = [archivePath stringByAppendingPathComponent:@"MusicByCarlCoreData.audioPlaybackArchive"];
    
    return archivePath;
}

+ (NSString *)songsArchiveFilePath
{
    NSString *archivePath = [self documentsDirectoryPath];
    archivePath = [archivePath stringByAppendingPathComponent:@"MusicByCarlCoreData.SongsArchive"];
    
    return archivePath;
}

+ (NSString *)userPreferencesArchiveFilePath
{
    NSString *archivePath = [self documentsDirectoryPath];
    archivePath = [archivePath stringByAppendingPathComponent:@"MusicByCarlCoreData.userPreferencesArchive"];
    
    return archivePath;
}

+ (NSString *)loggerArchiveFilePath
{
    NSString *archivePath = [self documentsDirectoryPath];
    archivePath = [archivePath stringByAppendingPathComponent:@"MusicByCarlCoreData.loggerArchive"];
    
    return archivePath;
}

+ (uint64_t) getTickCount
{
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Convert the mach time to milliseconds
    uint64_t millis = ((machTime / 1000000) * sTimebaseInfo.numer) / sTimebaseInfo.denom;
    return millis;
}

+ (NSString *)convertDoubleTimeToString: (double) inputTime
{
    NSString *returnValue = @"";
    
    long roundedInputTime = (long)inputTime;
    
    long roundedTimeMinutes = roundedInputTime / 60;
    long roundedTimeSeconds = roundedInputTime % 60;
    
    if (roundedTimeSeconds < 10)
    {
        returnValue = [NSString stringWithFormat:@"%ld:0%ld", roundedTimeMinutes, roundedTimeSeconds];
    }
    else
    {
        returnValue = [NSString stringWithFormat:@"%ld:%ld", roundedTimeMinutes, roundedTimeSeconds];
    }
    
    return returnValue;
}

+ (BOOL) stringIsNumeric: (NSString *)inputString
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    
    return ([inputString rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

+ (BOOL) stringIsAlphaNumeric: (NSString *)inputString
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([inputString rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

+ (NSString *)removeLeadingArticles: (NSString *)inputString
{
    NSString *returnValue;
    
    NSRange rangeOfThe = [inputString rangeOfString: @"The "];
    
    if (rangeOfThe.location == 0)
    {
        // If @"The " is found at index 0, we want to return everyting after it (starting at index 4)
        returnValue = [inputString substringFromIndex:4];
    }
    else
    {
        NSRange rangeOfAn = [inputString rangeOfString: @"An "];
        
        if (rangeOfAn.location == 0)
        {
            // If @"An " is found at index 0, we want to return everyting after it (starting at index 3)
            returnValue = [inputString substringFromIndex:3];
        }
        else
        {
            NSRange rangeOfA = [inputString rangeOfString: @"A "];
            
            if (rangeOfA.location == 0)
            {
                // If @"A " is found at index 0, we want to return everyting after it (starting at index 2)
                returnValue = [inputString substringFromIndex:2];
            }
            else
            {
                // If the first character isn't alphanumeric, everyting after it (starting at index 1)
                if (![self stringIsAlphaNumeric: [inputString substringToIndex:1]])
                {
                    returnValue = [inputString substringFromIndex:1];
                }
                else
                {
                    NSRange rangeOfTilde = [inputString rangeOfString:@"~"];
                    
                    if (rangeOfTilde.location != NSNotFound)
                    {
                        returnValue = [inputString substringFromIndex:rangeOfTilde.location + 1];
                    }
                    else
                    {
                        return [inputString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                    }
                }
            }
        }
    }
    
    returnValue = [returnValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    return returnValue;
}

+ (NSString *)getMediaObjectIndexCharacter:(NSString *)mediaObjectString
{
    NSString *trimmedString = [self removeLeadingArticles:mediaObjectString];
    
    if (trimmedString.length > 0)
    {
        NSString *accentedCharacter = [[trimmedString substringToIndex:1] uppercaseString];
        NSString *indexCharacter = [accentedCharacter stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_us"]];
        
        if ([self stringIsNumeric:indexCharacter])
        {
            indexCharacter = @"_";
        }
        
        return indexCharacter;
    }
    else
    {
        return @"";
    }
}

+ (NSString *)getMediaObjectStrippedString:(NSString *)mediaObjectString
{
    NSString *trimmedString = [self removeLeadingArticles:mediaObjectString];
    
    if (trimmedString.length > 0)
    {
        NSString *accentedCharacter = [[trimmedString substringToIndex:1] uppercaseString];
        NSString *strippedString = [accentedCharacter stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_us"]];
        
        if ([self stringIsNumeric:strippedString])
        {
            strippedString = [NSString stringWithFormat:@"_%@", trimmedString];
        }
        else
        {
            trimmedString = [trimmedString substringFromIndex:1];
            strippedString = [strippedString stringByAppendingString:trimmedString];
        }
        
        return strippedString;
    }
    else
    {
        return @"";
    }
}

+(UIButton *)customizeLeftBarButton: (UIViewController *)viewController withText: (NSString *)buttonText andWidth: (CGFloat) width
{
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, width - 5.0f, 29.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = buttonText;
    label.font = [UIFont boldSystemFontOfSize:13.0];
    label.textColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.5, 0.5);
    
    UIButton *customLeftButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, width, 29)];
    UIImage *buttonBackgroundImage = [[UIImage imageNamed:@"Nav-bar-back-button-background.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [customLeftButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    customLeftButton.adjustsImageWhenHighlighted = YES;
    [customLeftButton addSubview:label];
    
    UIBarButtonItem *customLeftBarButton = [[UIBarButtonItem alloc] initWithCustomView: customLeftButton];
    viewController.navigationItem.leftBarButtonItem = customLeftBarButton;
    
    return customLeftButton;
}

+ (void)drawLeftBarButton: (UIViewController *)viewController
{
    UIImage *leftBarButtonNormalImage = [[UIImage imageNamed:@"Nav-bar-back-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [viewController.navigationItem.leftBarButtonItem setBackgroundImage:leftBarButtonNormalImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    viewController.navigationItem.leftBarButtonItem.title = @"";
    viewController.navigationItem.leftBarButtonItem.target = viewController;
    viewController.navigationItem.leftBarButtonItem.action = @selector(backButtonPress);
}

+(UIButton *)createNowPlayingButton
{
    UILabel *nowLabel=[[UILabel alloc] initWithFrame:CGRectMake(2.0f, 4.0f, 45.0f, 10.0f)];
    nowLabel.backgroundColor = [UIColor clearColor];
    nowLabel.textAlignment = NSTextAlignmentCenter;
    nowLabel.text = @"Now";
    nowLabel.font = [UIFont boldSystemFontOfSize:10.0];
    nowLabel.textColor = [UIColor whiteColor];
    nowLabel.shadowColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    nowLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    UILabel *playingLabel=[[UILabel alloc] initWithFrame:CGRectMake(2.0f, 14.0f, 45.0f, 12.0f)];
    playingLabel.backgroundColor = [UIColor clearColor];
    playingLabel.textAlignment = NSTextAlignmentCenter;
    playingLabel.text = @"Playing";
    playingLabel.font = [UIFont boldSystemFontOfSize:10.0];
    playingLabel.textColor = [UIColor whiteColor];
    playingLabel.shadowColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    playingLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    UIButton *customNowPlayingButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 55, 30)];
    [customNowPlayingButton setBackgroundImage:[UIImage imageNamed:@"Now-Playing-Button.png"] forState:UIControlStateNormal];
    customNowPlayingButton.adjustsImageWhenHighlighted = YES;
    [customNowPlayingButton addSubview:nowLabel];
    [customNowPlayingButton addSubview:playingLabel];
    
    return customNowPlayingButton;
}

+(UIBarButtonItem *)showNowPlayingButton: (UIViewController *)viewController withNowPlayingButton: (UIButton *)nowPlayingButton
{
    UIBarButtonItem *customNowPlayingButtonItem = [[UIBarButtonItem alloc] initWithCustomView: nowPlayingButton];
    viewController.navigationItem.rightBarButtonItem = customNowPlayingButtonItem;
    
    return customNowPlayingButtonItem;
}

+ (void)sendProgressNotification: (float)progressFraction forOperationType: (NSString *)operationType duringBuildAll:(BOOL)duringBuildAll
{
    NSMutableDictionary *notificationUserInfo = [[NSMutableDictionary alloc] init];
    [notificationUserInfo setObject:[NSNumber numberWithFloat:progressFraction] forKey:@"progressFraction"];
    [notificationUserInfo setObject:operationType forKey:@"operationType"];
    [notificationUserInfo setObject:[NSNumber numberWithBool:duringBuildAll] forKey:@"buildAllFlag"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicByCarlCoreData.databaseProgressNotification" object:self userInfo:notificationUserInfo];
}

+ (void)writelnToStandardOut: (NSString *)stringToWrite
{
    NSFileHandle *standardOutFile = [NSFileHandle fileHandleWithStandardOutput];
    
    [standardOutFile writeData:[[NSString stringWithFormat:@"%@\n", stringToWrite] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSArray *)convertSectionTitles: (NSFetchedResultsController *)fetchedResultsController
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithObjects:@" ", nil];
    
    NSArray *sections = fetchedResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo;
    
    for (int i = 0; i < sections.count; i++)
    {
        sectionInfo = [sections objectAtIndex:i];
        
        if ([sectionInfo.name isEqualToString:@"_"])
        {
            [returnValue addObject:@"123"];
        }
        else
        {
            [returnValue addObject:sectionInfo.name];
        }
    }
    
    return returnValue;
}

+ (NSArray *)convertSectionIndexTitles: (NSFetchedResultsController *)fetchedResultsController
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithObjects:UITableViewIndexSearch, nil];
    [returnValue addObjectsFromArray:[fetchedResultsController.sectionIndexTitles mutableCopy]];
    
    NSString *sectionIndexTitle;
    
    for (int i = 0; i < returnValue.count; i++)
    {
        sectionIndexTitle = [returnValue objectAtIndex:i];
        
        if ([sectionIndexTitle isEqualToString:@"_"])
        {
            [returnValue replaceObjectAtIndex:i withObject:@"#"];
        }
    }
    
    return returnValue;
}

+ (NSString *)documentsDirectoryPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentDirectories objectAtIndex: 0];
    
    return documentsDirectory;
}

+ (NSString *)routeChangeReasonToString: (SInt32) routeChangeReason
{
    NSString *returnValue = @"Undetermined";
    
    switch (routeChangeReason)
    {
        case kAudioSessionRouteChangeReason_Unknown:
            returnValue = @"kAudioSessionRouteChangeReason_Unknown";
            break;
            
        case kAudioSessionRouteChangeReason_NewDeviceAvailable:
            returnValue = @"kAudioSessionRouteChangeReason_NewDeviceAvailable";
            break;
            
        case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
            returnValue = @"kAudioSessionRouteChangeReason_OldDeviceUnavailable";
            break;
            
        case kAudioSessionRouteChangeReason_CategoryChange:
            returnValue = @"kAudioSessionRouteChangeReason_CategoryChange";
            break;
            
        case kAudioSessionRouteChangeReason_Override:
            returnValue = @"kAudioSessionRouteChangeReason_Override";
            break;
            
        case kAudioSessionRouteChangeReason_WakeFromSleep:
            returnValue = @"kAudioSessionRouteChangeReason_WakeFromSleep";
            break;
            
        case kAudioSessionRouteChangeReason_NoSuitableRouteForCategory:
            returnValue = @"kAudioSessionRouteChangeReason_NoSuitableRouteForCategory";
            break;
            
        default:
            break;
    }
    
    return returnValue;
}

+ (NSString *)dateToString: (NSDate *)date
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [DateFormatter stringFromDate:date];
}

+ (NSString *)returnNSStringFromNSDate:(NSDate *)date
{
    NSString *userVisibleDateTimeString = @"";
    
    if (date != nil)
    {
        // Convert the date object to a user-visible date string.
        NSDateFormatter *userVisibleDateFormatter = [[NSDateFormatter alloc] init];
        if (userVisibleDateFormatter != nil)
        {
            [userVisibleDateFormatter setDateStyle:NSDateFormatterShortStyle];
            [userVisibleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            userVisibleDateTimeString = [userVisibleDateFormatter stringFromDate:date];
        }
    }
    
    return userVisibleDateTimeString;
}

+ (NSString *)timeStampToString: (NSDate *)date
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [DateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [DateFormatter stringFromDate:date];
}

// Start a spinner in the center of the UIView specified as a parameter
+ (UIActivityIndicatorView *)startSpinner: (UIView *)view withStyle: (UIActivityIndicatorViewStyle)indicatorStyle
{
    // Create a spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
    
    // Center the spinner on the UIView, and add it as a sub view
    [spinner setCenter: view.center];
    [view addSubview:spinner];
    
    // Start the spinning
    [spinner startAnimating];
    
    return spinner;
}

+ (void)stopAndNilSpinner: (UIActivityIndicatorView *)spinner
{
    if (spinner != nil)
    {
        // Remove the spinner from its superview and nil it out
        [spinner removeFromSuperview];
        spinner = nil;
    }
}

+ (void)showErrorAlert: (NSString *)alertText withDelegate: (UIViewController *)viewController
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MusicByCarlCoreData Alert"
                                                    message:alertText
                                                   delegate:viewController
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (UIAlertView *)showOkButtonAlert: (NSString *)title message: (NSString *)message delegate: (id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    return alertView;
}

+ (UIAlertView *)showNoButtonAlert: (NSString *)title message: (NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];

    return alert;
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end
