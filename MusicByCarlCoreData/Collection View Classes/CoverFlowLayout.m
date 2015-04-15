//
//  CoverFlowLayout.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "CoverFlowLayout.h"

static const CGFloat kRotationOffset = (CGFloat)(40.0 * (M_PI / 180.0));
static const CGFloat kMaxRotation = (CGFloat)(40.0 * (M_PI / 180.0));
static const CGFloat kMaxZoom = 0.5;
static const CGFloat kMinZoom = 1.3;

@implementation CoverFlowLayout

#define ACTIVE_DISTANCE 530

- (id)init {
    self = [super init];
    
    if (self) {
        self.itemSize = CGSizeMake(130.0f, 300.0f);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGFloat)returnMultiplierForMinMultiplier:(CGFloat)minMultiplier
                              maxMultiplier:(CGFloat)maxMultiplier
                                minDistance:(CGFloat)minDistance
                                maxDistance:(CGFloat)maxDistance
                         andCurrentDistance:(CGFloat)distance
{
    CGFloat multiplierRange = maxMultiplier - minMultiplier;
    CGFloat distanceRange = maxDistance - minDistance;
    
    // Multiplier = ((Distance - 1.2)/(2.5 - 1.2)) * (100 - 85) + 85
    return (((distance - minDistance) / distanceRange) * multiplierRange) + minMultiplier;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes *attributes in array)
    {
        if (CGRectIntersectsRect(attributes.frame, rect))
        {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;

            normalizedDistance = MIN(normalizedDistance, 1.0f);
            normalizedDistance = MAX(normalizedDistance, -1.0f);

            CGFloat rotation = 0;
            
            if (ABS(normalizedDistance) > 0.1f)
            {
                if (normalizedDistance > 0)
                {
                    rotation = kRotationOffset + (normalizedDistance * kMaxRotation);
                }
                else
                {
                    rotation = -kRotationOffset + (normalizedDistance * kMaxRotation);
                }
            }
            
            CGFloat zoom = 1.0f + ((1.0f - ABS(normalizedDistance)) * kMaxZoom);
            
            if (zoom < kMinZoom)
            {
                zoom = kMinZoom;
                
            }

            CGFloat multiplier = [self returnMultiplierForMinMultiplier:50
                                                          maxMultiplier:500
                                                            minDistance:0.2
                                                            maxDistance:1.75
                                                     andCurrentDistance:normalizedDistance];
            if (normalizedDistance < 0)
            {
                multiplier = -multiplier;
            }
            
            if (normalizedDistance < 0.2f)
            {
                attributes.zIndex = 1;
            }
            else
            {
                attributes.zIndex = 0;
            }
            CATransform3D transform = CATransform3DIdentity;
            transform = CATransform3DTranslate(transform, normalizedDistance * multiplier, 0, 0);
            
            transform.m34 = 1.0 / -1000.0;

            transform = CATransform3DRotate(transform,
                                            rotation,
                                            0.0f,
                                            1.0f,
                                            0.0f);
            transform = CATransform3DScale(transform,
                                           zoom,
                                           zoom,
                                           1.0f);
            
            attributes.transform3D = transform;
        }
    }
    
    return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
