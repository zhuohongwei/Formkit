//
//  FKDemosTableViewController.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 20/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKDemosTableViewController.h"
#import "FKLoginViewController.h"

@interface FKDemosTableViewController () {
    NSArray *_demoNames;
}

@end

@implementation FKDemosTableViewController

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        _demoNames = @[@"Sign In", @"Sign Up"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"FormKit Demos";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _demoNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"demoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _demoNames[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *demoName = _demoNames[indexPath.row];
    if ([demoName isEqualToString:@"Sign In"]) {
        FKLoginViewController *loginViewController = [[FKLoginViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        
        [self.navigationController presentViewController:loginNavigationController animated:YES completion:nil];
    }
}

@end
