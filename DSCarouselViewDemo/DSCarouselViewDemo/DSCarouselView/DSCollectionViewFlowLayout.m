//
//  DSCollectionViewFlowLayout.m
//  DSCarouselViewDemo
//
//  Created by LS on 11/17/15.
//  Copyright © 2015 LS. All rights reserved.
//

#import "DSCollectionViewFlowLayout.h"

@implementation DSCollectionViewFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    self.collectionView.contentOffset = self.contentOffset;
}

@end
