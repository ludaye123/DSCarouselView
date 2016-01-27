//
//  ViewController.m
//  DSCarouselViewDemo
//
//  Created by LS on 11/17/15.
//  Copyright © 2015 LS. All rights reserved.
//

#import "ViewController.h"
#import "DSCarouselView.h"

@interface ViewController ()

@property (nonatomic, strong) DSCarouselView *carouseView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.carouseView];
    
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(_carouseView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0.0-[_carouseView]-0.0-|" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20.0-[_carouseView(200.0)]" options:0 metrics:nil views:viewDict]];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSArray *images = @[@"http://pub.chinaunix.net/uploadfile/201204/20120422080605427.jpg",
//                        @"http://imgsrc.baidu.com/forum/w%3D580/sign=0c1b13ef0c3387449cc52f74610ed937/bf94b9315c6034a8a4e0f53ecb13495408237644.jpg",
//                        @"http://hiphotos.baidu.com/%95%D7%D4%AA%B5%C0/pic/item/432e6436d9cd9b4deac4af86.jpg"];
//    
//    self.carouseView.imageURLs = images;
//}

- (DSCarouselView *)carouseView
{
    if(!_carouseView)
    {
        NSArray *images = @[@"http://pub.chinaunix.net/uploadfile/201204/20120422080605427.jpg",
                            @"http://imgsrc.baidu.com/forum/w%3D580/sign=0c1b13ef0c3387449cc52f74610ed937/bf94b9315c6034a8a4e0f53ecb13495408237644.jpg",
                            @"http://hiphotos.baidu.com/%95%D7%D4%AA%B5%C0/pic/item/432e6436d9cd9b4deac4af86.jpg"];
        
        _carouseView = [DSCarouselView carouseViewWithImageURLs:images placeholder:[UIImage imageNamed:@"placeholder"]];
        _carouseView.translatesAutoresizingMaskIntoConstraints = 0.0;

        // set frame
//        _carouseView = [[DSCarouselView alloc] init];
//        _carouseView.frame = CGRectMake(0.0, 20.0, CGRectGetWidth(self.view.bounds), 200.0);
    }
    
    return _carouseView;
}

@end
