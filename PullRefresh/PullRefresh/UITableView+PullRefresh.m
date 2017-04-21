//
//  UITableView+PullRefresh.m
//  PullRefresh
//
//  Created by oxape on 2017/4/18.
//  Copyright © 2017年 oxape. All rights reserved.
//

#import "UITableView+PullRefresh.h"
#import <objc/runtime.h>

@implementation UITableView (PullRefresh)

const static NSString *PullRefreshHeaderKey = @"PullRefreshHeader";

- (void)setPr_header:(PullRefreshHeader *)pr_header {
    if (pr_header != self.pr_header) {
        [self.pr_header removeFromSuperview];
        [self insertSubview:pr_header atIndex:0];
        
        [self willChangeValueForKey:@"pr_header"];
        objc_setAssociatedObject(self, &PullRefreshHeaderKey, pr_header, OBJC_ASSOCIATION_RETAIN);
        [self didChangeValueForKey:@"pr_header"];
    }
}

- (PullRefreshHeader *)pr_header {
    return objc_getAssociatedObject(self, &PullRefreshHeaderKey);
}

@end
