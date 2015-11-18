//
//  DSCollectionViewCell.h
//  DSCarouselViewDemo
//
//  Created by LS on 11/17/15.
//  Copyright © 2015 LS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
+ (UINib *)collectionViewCellFromNib;

@property (weak, nonatomic) IBOutlet UIImageView *showImageView;

@end
