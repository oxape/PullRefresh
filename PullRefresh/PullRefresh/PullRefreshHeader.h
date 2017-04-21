//
//  PullRefreshHeader.h
//  PullRefresh
//
//  Created by oxape on 2017/4/18.
//  Copyright © 2017年 oxape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullRefreshHeader : UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

+ (PullRefreshHeader *)headerWithRefreshBlock:(void (^)())refreshBlock;

- (void)beginRefreshing;
- (void)endRefreshing;

@end
