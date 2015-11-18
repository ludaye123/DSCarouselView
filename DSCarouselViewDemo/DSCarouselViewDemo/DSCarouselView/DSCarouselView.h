//
//  DSCarouselView.h
//  DSCarouselViewDemo
//
//  Created by LS on 11/17/15.
//  Copyright © 2015 LS. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  DSCarouselView 水平方向自动轮播图片控件视图
 *  支持AutoLayout
 *  要求 iOS 8.0+
 */

@protocol DSCarouselViewDelegate;

@interface DSCarouselView : UIView

@property (nonatomic, copy)   NSArray *imageURLs;
@property (nonatomic, strong) UIImage *placeholder;

@property (nonatomic, getter=isAutoMoving, assign) BOOL autoMoving;   // Default is YES
@property (nonatomic, assign) NSTimeInterval autoMoveDuration;        // Default is 3

@property (nonatomic, weak) id<DSCarouselViewDelegate> delegate;

+ (instancetype)carouseViewWithImageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder;
- (instancetype)initWithImageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder;

@end

@protocol DSCarouselViewDelegate <NSObject>

@optional

- (void)carouselView:(DSCarouselView *)view didSelectItemAtIndex:(NSInteger)index;

@end