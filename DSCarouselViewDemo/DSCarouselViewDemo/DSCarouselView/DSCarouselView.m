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

@property (nonatomic, getter = isFirstLoad, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL timerState;

@property (nonnull, nonatomic, strong) UICollectionView *collectionView;
@property (nonnull, nonatomic, strong) UIPageControl *pageControl;
@property (nullable, nonatomic, strong) dispatch_source_t timerSource;

@end

@implementation DSCarouselView

#pragma mark - Init

+ (instancetype)carouseViewWithImageURLs:(NSArray<NSString *> *)imageURLs placeholder:(UIImage *)placeholder
{
    return [[self alloc] initWithImageURLs:imageURLs placeholder:placeholder];
}

- (void)awakeFromNib
{
    [self setupCollectionView];
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self setupCollectionView];
    }
    
    return self;
}

- (instancetype)initWithImageURLs:(NSArray<NSString *> *)imageURLs placeholder:(UIImage *)placeholder
{
    self = [self init];
    if(self)
    {
        [self setImageURLs:imageURLs];
        [self setPlaceholder:placeholder];
    }
    
    return  self;
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
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0.0-[_pageControl]-0.0-|" options:0 metrics:nil views:viewDict]];
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
    if(self.delegate && [self.delegate respondsToSelector:@selector(carouselView:didSelectImageItemAtIndex:)])
    {
        [self.delegate carouselView:self didSelectImageItemAtIndex:indexPath.item-1];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.isAutoMoving)
    {
        [self pauseMove];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.isAutoMoving)
    {
        [self resumeMove];
    }
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
    else if(scrollView.contentOffset.x >= (self.imageURLs.count - 1) * CGRectGetWidth(self.bounds))
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
    if(self.isAutoMoving && self.imageURLs.count > 0)
    {
        dispatch_resume(self.timerSource);
        self.timerState = YES;
    }
}

- (void)stopTimer
{
    if(self.isAutoMoving && self.imageURLs.count > 0)
    {
        dispatch_cancel(self.timerSource);
        self.timerSource = nil;
    }
}

- (void)resumeMove
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoMoveDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        dispatch_resume(self.timerSource);
    });
}

- (void)pauseMove
{
    dispatch_suspend(self.timerSource);
}

#pragma mark - Scroll Next

- (void)scrollToNextPage
{
    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetWidth(self.bounds), 0);
    [self.collectionView setContentOffset:contentOffset animated:YES];
}

#pragma mark - Application State

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self stopTimer];
    self.timerState = NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if(!self.timerState)
    {
        [self startTimer];
    }
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
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [self startTimer];
    }
}

- (dispatch_source_t)timerSource
{
    if(!_timerSource)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, self.autoMoveDuration * NSEC_PER_SEC);
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timerSource, start, self.autoMoveDuration * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timerSource, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [self scrollToNextPage];
            });
        });
    }
    
    return _timerSource;
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
        _collectionView.backgroundColor = [UIColor whiteColor];
    
        [_collectionView registerNib:[DSCollectionViewCell collectionViewCellFromNib]
          forCellWithReuseIdentifier:[DSCollectionViewCell identifier]];
    }
    
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if(!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        _pageControl.userInteractionEnabled = NO;
    }
    
    return _pageControl;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
