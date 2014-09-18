//
//  FKFormViewController.h
//  FormKit
//
//  Created by Hong Wei Zhuo on 18/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKFormItem.h"

@class FKForm;
@class FKSelectFieldItem;
@interface FKFormViewController : UIViewController <FKFormDelegate>

@property (nonatomic, strong) FKForm *form;
@property (nonatomic, readonly) UIBarButtonItem * submitButton;
@property (nonatomic, readonly) UIBarButtonItem * cancelButton;
@property (nonatomic, readonly) UIBarButtonItem * deleteButton;

-(void)overlayMessage:(NSString *)message;
-(void)removeOverlay;

-(void)presentViewControllerForSelectFieldItem:(FKSelectFieldItem *)selectFieldItem;
-(void)presentSuccessMessage:(NSAttributedString *)message;
-(void)presentFailureMessage:(NSAttributedString *)message;


//Methods to override in subclass, do not call directly
-(void)cancel:(id)sender;
-(void)submit:(id)sender;


@end

