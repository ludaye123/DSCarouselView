//
//  DSCollectionViewCell.m
//  DSCarouselViewDemo
//
//  Created by LS on 11/17/15.
//  Copyright © 2015 LS. All rights reserved.
//

#import "DSCollectionViewCell.h"

@implementation DSCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)collectionViewCellFromNib
{
    return [UINib nibWithNibName:[self identifier] bundle:[NSBundle bundleForClass:[self class]]];
}

- (void)awakeFromNib {
    // Initialization code
}

@end
