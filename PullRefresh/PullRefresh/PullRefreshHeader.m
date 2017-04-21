//
//  PullRefreshHeader.m
//  PullRefresh
//
//  Created by oxape on 2017/4/18.
//  Copyright © 2017年 oxape. All rights reserved.
//

#import "PullRefreshHeader.h"

typedef NS_ENUM(NSInteger, PullRefreshState) {
    /** 普通闲置状态 */
    PullRefreshStateNormal = 0,
    /** 下拉状态 */
    PullRefreshStatePulling,
    /** 即将刷新的状态 */
    PullRefreshStateWillRefresh,
    /** 正在刷新中的状态 */
    PullRefreshStateRefreshing
};

@interface PullRefreshHeader ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) PullRefreshState state;
@property (nonatomic, strong) void (^refreshBlock)();

@end

@implementation PullRefreshHeader

+ (PullRefreshHeader *)headerWithRefreshBlock:(void (^)())refreshBlock {
    PullRefreshHeader *header = [[self alloc] init];
    header.refreshBlock = refreshBlock;
    return header;
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 200, 55);
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label.frame = self.bounds;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tipsLabel = label;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview || ![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }

    // 旧的父控件移除监听
    [self removeObservers];
    
    if (newSuperview) { // 新的父控件
        self.frame = CGRectMake(0, -50, newSuperview.frame.size.width, self.frame.size.height);
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        
        // 添加监听
        [self addObservers];
    }
}

#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
}

- (void)removeObservers {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewContentOffsetDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    CGPoint contentOffset = [[change objectForKey:@"new"] CGPointValue];
    NSLog(@"contentOffset = %@", NSStringFromCGPoint(contentOffset));
    if (self.state == PullRefreshStateRefreshing) {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
        offset = MIN(offset, 60);
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
    }
    // 当前的contentOffset
    CGFloat offsetY = self.scrollView.contentOffset.y;
    if (self.scrollView.isDragging) { // 如果正在拖拽
        switch (self.state) {
            case PullRefreshStateNormal:
                if (offsetY < -20) {
                    self.state = PullRefreshStatePulling;
                }
                break;
            case PullRefreshStatePulling:
                if (offsetY < -60) {
                    self.state = PullRefreshStateWillRefresh;
                }
            case PullRefreshStateWillRefresh:
                if (offsetY > -60) {
                    self.state = PullRefreshStatePulling;
                }
            default:
                break;
        }
    } else if (self.state == PullRefreshStateWillRefresh) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    }
}

- (void)setState:(PullRefreshState)state
{
    if (state == self.state) return;
    _state = state;
    
    // 根据状态做事情
    switch (state) {
        case PullRefreshStateNormal:
        {
            self.alpha = 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                [self.scrollView setContentOffset:CGPointMake(0, 0)];
            }];
        }
            break;
        case PullRefreshStatePulling:
            self.alpha = 1.0;
            self.tipsLabel.text = @"下拉刷新";
            break;
        case PullRefreshStateWillRefresh:
            self.alpha = 1.0;
            self.tipsLabel.text = @"松开立即刷新";
            break;
        case PullRefreshStateRefreshing:
        {
            self.alpha = 1.0;
            self.tipsLabel.text = @"正在刷新";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - 公共方法

- (void)beginRefreshing
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
    self.state = PullRefreshStateRefreshing;
}

- (void)endRefreshing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = PullRefreshStateNormal;
    });
}

@end
