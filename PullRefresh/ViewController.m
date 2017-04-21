//
//  ViewController.m
//  PullRefresh
//
//  Created by oxape on 2017/4/18.
//  Copyright © 2017年 oxape. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+PullRefresh.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.pr_header = [PullRefreshHeader headerWithRefreshBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.pr_header endRefreshing];
        });
    }];
}


@end
