//
//  ViewController.m
//  MGTTCardExample
//
//  Created by Luqiang on 2017/12/20.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import "ViewController.h"
#import "MGTTCardView.h"

@interface ViewController () <MGTTCardViewDelegate>

@property (nonatomic, strong) MGTTCardView *cardView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIButton *loadButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataArray = @[@"01", @"02", @"03"];
    [self.view addSubview:self.cardView];
}

- (NSInteger)numberOfItemsInCardView:(MGTTCardView *)cardView {
    return self.dataArray.count;
}

- (UIView *)cardView:(MGTTCardView *)cardView viewForItemAtIndex:(NSInteger)index reuseView:(UIView *)reuseView {
    if (!reuseView) {
        reuseView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    ((UIImageView *)reuseView).image = [UIImage imageNamed:self.dataArray[index]];
    return reuseView;
}

- (void)cardView:(MGTTCardView *)cardView didSelectView:(UIView *)itemView atIndex:(NSInteger)index {
    NSLog(@"点击itemView:%ld", (long)index);
}

- (MGTTCardView *)cardView {
    if (!_cardView) {
        _cardView = [[MGTTCardView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 300) / 2.0f, ([UIScreen mainScreen].bounds.size.height - 300) / 2.0f, 300, 300) showNumberOfItems:3 style:MGTTCardViewStyleTop];
        _cardView.delegate = self;
    }
    return _cardView;
}

@end
