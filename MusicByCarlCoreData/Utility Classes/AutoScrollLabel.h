//
//  AutoScrollLabel.h
//  AutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Copyright 2009 Stormy Productions. All rights reserved.
//
//  Permission is granted to use this code free of charge for any project.
//

#import <UIKit/UIKit.h>

#define NUM_LABELS 2

#define LABEL_BUFFER_SPACE 20   // pixel buffer space between scrolling label
#define DEFAULT_PIXELS_PER_SECOND 30
#define DEFAULT_PAUSE_TIME 0.5f

enum AutoScrollDirection {
	AUTOSCROLL_SCROLL_RIGHT,
	AUTOSCROLL_SCROLL_LEFT,
};

@interface AutoScrollLabel : UIScrollView <UIScrollViewDelegate>{
	UILabel *label[NUM_LABELS];
	enum AutoScrollDirection _scrollDirection;
	float _scrollSpeed;
	NSTimeInterval _pauseInterval;
	int _bufferSpaceBetweenLabels;
	bool isScrolling;
}
@property(nonatomic) enum AutoScrollDirection scrollDirection;
@property(nonatomic) float scrollSpeed;
@property(nonatomic) NSTimeInterval pauseInterval;
@property(nonatomic) int bufferSpaceBetweenLabels;
// normal UILabel properties
@property(nonatomic,retain) UIColor *textColor;
@property(nonatomic, retain) UIFont *font;

- (void) readjustLabels;
- (void) setText: (NSString *) text;
- (NSString *) text;
- (void) scroll;


@end
