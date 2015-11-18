//
//  DSCarouselView.m
//  DSCarouselViewDemo
//
//  Created by LS on 11/17/15.
//  Copyright © 2015 LS. All rights reserved.
//

#import "DSCarouselView.h"
#import "DSCollectionViewCell.h"
#import "UIImageView+WebCache.h"   

@interface DSCarouselView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, getter=isFirstLoad, assign) BOOL firstLoad;
@property (nonatomic, strong) NSTimer  *timer;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation DSCarouselView

#pragma mark - Init

+ (instancetype)carouseViewWithImageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder
{
    return [[self alloc] initWithImageURLs:imageURLs placeholder:placeholder];
}

- (void)awakeFromNib
{
    
    [self setupCollectionView];
}

- (instancetype)initWithImageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.minimumLineSpacing = 0.0;
    self = [super init];
    if(self)
    {
        [self setupCollectionView];
        [self setImageURLs:imageURLs];
        [self setPlaceholder:placeholder];
    }
    
    return  self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.collectionView.contentOffset = CGPointMake(CGRectGetWidth(frame), 0);
    self.pageControl.currentPage = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.isFirstLoad)
    {
        self.collectionView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
        self.pageControl.currentPage = 0;
        self.firstLoad = NO;
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self stopTimer];
}

#pragma mark - Config

- (void)setupCollectionView
{
    _autoMoving = YES;
    _autoMoveDuration = 3.0;
    _firstLoad = YES;
    [self registerNotification];
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self bringSubviewToFront:self.pageControl];
    [self setLayout];
}

- (void)setLayout
{
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(_collectionView,_pageControl);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0.0-[_collectionView]-0.0-|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0.0-[_collectionView]-0.0-|" options:0 metrics:nil views:viewDict]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5.0-[_pageControl]-5.0-|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl]-0.0-|" options:0 metrics:nil views:viewDict]];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAX(self.imageURLs.count, 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DSCollectionViewCell identifier] forIndexPath:indexPath];
    
    if(self.imageURLs.count == 0)
    {
        cell.showImageView.image = self.placeholder;
    }
    
    [cell.showImageView sd_setImageWithURL:[NSURL URLWithString:[self.imageURLs objectAtIndex:indexPath.row]] placeholderImage:self.placeholder];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%zd",indexPath.item-1);
    if(self.delegate && [self.delegate respondsToSelector:@selector(carouselView:didSelectItemAtIndex:)])
    {
        [self.delegate carouselView:self didSelectItemAtIndex:indexPath.item-1];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.isAutoMoving)
        [self pauseMove];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.isAutoMoving)
        [self resumeMove];
    
    if(scrollView.contentOffset.x < CGRectGetWidth(self.bounds))
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.imageURLs.count - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    else if(scrollView.contentOffset.x >= (self.imageURLs.count - 1) * CGRectGetWidth(self.bounds))
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.bounds) - 1;
    self.pageControl.currentPage = index;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    if(scrollView.contentOffset.x < CGRectGetWidth(self.bounds))
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.imageURLs.count - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    else if(scrollView.contentOffset.x == (self.imageURLs.count - 1) * CGRectGetWidth(self.bounds))
    {
        [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:NO];
    }
    
    NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.bounds) - 1;
    self.pageControl.currentPage = index;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.bounds.size;
}

#pragma mark - Private Method

- (void)startTimer
{
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)resumeMove
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoMoveDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        [self.timer setFireDate:[NSDate distantPast]];
    });
}

- (void)pauseMove
{
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollToNextPage:(NSTimer *)timer
{
    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetWidth(self.bounds), 0);
    [self.collectionView setContentOffset:contentOffset animated:YES];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if(self.isAutoMoving)
        [self stopTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoMoveDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.isAutoMoving)
        {
            [self startTimer];
        }
    });
}

#pragma mark Setter && Getter

- (void)setImageURLs:(NSArray *)imageURLs
{
    _imageURLs = imageURLs;
    if(imageURLs.count > 0)
    {
        self.pageControl.numberOfPages = imageURLs.count;
        NSMutableArray *tempImages = [NSMutableArray array];
        [tempImages addObject:[imageURLs lastObject]];
        [tempImages addObjectsFromArray:imageURLs];
        [tempImages addObject:[imageURLs firstObject]];
        
        _imageURLs = [NSArray arrayWithArray:tempImages];
    
        [self.collectionView reloadData];
    }
}

- (NSTimer *)timer
{
    if(!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.autoMoveDuration target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
    return _timer;
}

- (UICollectionView *)collectionView
{
    if(!_collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0.0;
        flowLayout.minimumLineSpacing = 0.0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    
        [_collectionView registerNib:[DSCollectionViewCell collectionViewCellFromNib]
          forCellWithReuseIdentifier:[DSCollectionViewCell identifier]];
    }
    
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if(!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(5.0, 100.0, 39.0, 37.0)];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _pageControl;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
