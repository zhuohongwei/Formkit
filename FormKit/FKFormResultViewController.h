//
//  FKFormResultViewController.h
//  FormKit
//
//  Created by Hong Wei Zhuo on 18/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FKFormResultViewController;
@protocol FKFormResultViewControllerDelegate <NSObject>

@required
-(void)formResultViewControllerDidDismissFormResult:(FKFormResultViewController *)controller;

@end


@interface FKFormResultViewController : UIViewController

@property (nonatomic) BOOL disableBackButton;
@property (nonatomic, weak) id<FKFormResultViewControllerDelegate> delegate;
-(void)setImage:(UIImage *)image andMessage:(NSAttributedString *)message;

@end

