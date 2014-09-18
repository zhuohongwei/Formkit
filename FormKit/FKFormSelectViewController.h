//
//  FKFormSelectViewController.h
//  FormKit
//
//  Created by Hong Wei Zhuo on 18/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FKSelectFieldItem;
@interface FKFormSelectViewController : UITableViewController

-(id)initWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem;

@property (nonatomic, assign) BOOL allowSearching;

@end
