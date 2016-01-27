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

NS_ASSUME_NONNULL_BEGIN

@protocol DSCarouselViewDelegate;

@interface DSCarouselView : UIView

@property (nonnull ,nonatomic, copy)   NSArray<NSString *> *imageURLs;
@property (nullable ,nonatomic, strong) UIImage *placeholder;

@property (nonatomic, getter=isAutoMoving, assign) BOOL autoMoving;   // Default is YES
@property (nonatomic, assign) NSTimeInterval autoMoveDuration;        // Default is 3

@property (nullable ,nonatomic, weak) id<DSCarouselViewDelegate> delegate;

+ (instancetype)carouseViewWithImageURLs:(NSArray<NSString *> *)imageURLs placeholder:(UIImage *)placeholder;
- (instancetype)initWithImageURLs:(NSArray<NSString *> *)imageURLs placeholder:(UIImage *)placeholder;

@end

@protocol DSCarouselViewDelegate <NSObject>

@optional

- (void)carouselView:(DSCarouselView *)view didSelectImageItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END