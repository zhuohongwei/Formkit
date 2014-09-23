//
//  FKLoginViewController.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 20/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKLoginViewController.h"
#import "FKFormItem.h"
#import "FKFormItemView.h"

@interface FKLoginViewController ()

@end

@implementation FKLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        FKForm *form = [[FKForm alloc] init];
        form.title = @"Sign In";
        
        FKRowItem *row1 = [form addRow];
        [row1 addColumnWithItem:[FKTextFieldItem textFieldItemWithName:@"username" label:@"Username" text:nil placeholder:@"Email address"]];
        
        FKRowItem *row2 = [form addRow];
        [row2 addColumnWithItem:[FKTextFieldItem textFieldItemWithName:@"password" label:@"Password" text:nil placeholder:nil]];
        
        form.purpose = FKFormPurposeSubmit;
        form.submitLabel = @"Sign In";
        
        self.form = form;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //customization after form view is created
    
    FKTextFieldItem *usernameItem = (FKTextFieldItem *)[self.form inputItemNamed:@"username"];
    FKTextFieldView *usernameField = (FKTextFieldView *) usernameItem.view;
    usernameField.labelWidthRatio = 0.33;
    
    FKTextFieldItem *passwordItem = (FKTextFieldItem *)[self.form inputItemNamed:@"password"];
    FKTextFieldView *passwordField = (FKTextFieldView *) passwordItem.view;
    passwordField.textField.secureTextEntry = YES;
    passwordField.labelWidthRatio = 0.33;
}

@end
