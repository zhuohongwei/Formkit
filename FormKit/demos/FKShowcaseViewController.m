//
//  FKInputItemShowcaseViewController.m
//  FormKit
//
//  Created by Meiwin Fu on 21/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKShowcaseViewController.h"
#import "FKSampleTextAreaItem.h"

@interface FKShowcaseViewController ()

@end

@implementation FKShowcaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        FKForm *form = [[FKForm alloc] init];
        form.title = @"Showcase";
        
        // ---------- FKTextFieldItem
        FKRowItem *row1 = [form addRow];
        [row1 addColumnWithItem:[FKTextFieldItem textFieldItemWithName:@"textfield" label:@"Text Field" text:nil placeholder:@"Enter text..."]];
        
        // ---------- FKSelectFieldItem & FKMultiSelectFieldItem
        NSDictionary * selectOptions = @{ @"1" : @"One", @"2" : @"Two", @"3" : @"Three" };
        
        FKRowItem *row2 = [form addRow];
        FKSelectFieldItem *selectFieldItem = [FKSelectFieldItem selectFieldItemWithName:@"selectfield" label:@"Select Field" placeholder:@"Select one..."];
        selectFieldItem.keyAndDisplayValues = selectOptions;
        selectFieldItem.sortedKeyValues = [selectOptions allKeys];
        [row2 addColumnWithItem:selectFieldItem];
        
        FKRowItem *row3 = [form addRow];
        FKMultiSelectFieldItem *multiSelectFieldItem = [FKMultiSelectFieldItem multiSelectFieldItemWithName:@"multiselectfield" label:@"Multi Select Field" placeholder:@"Select one or more..."];
        multiSelectFieldItem.keyAndDisplayValues = selectOptions;
        multiSelectFieldItem.sortedKeyValues = [selectOptions allKeys];
        [row3 addColumnWithItem:multiSelectFieldItem];
        
        // ---------- FKInlineSelectFieldItem & FKMultiInlineSelectFieldItem
        FKRowItem *row4 = [form addRow];
        FKInlineSelectFieldItem *inlineSelectFieldItem = [FKInlineSelectFieldItem inlineSelectFieldItemWithName:@"inlineselectfield" label:@"Inline Select Field"];
        inlineSelectFieldItem.keyAndDisplayValues = selectOptions;
        inlineSelectFieldItem.sortedKeyValues = [selectOptions allKeys];
        [row4 addColumnWithItem:inlineSelectFieldItem];

        FKRowItem *row5 = [form addRow];
        FKInlineMultiSelectFieldItem *inlineMultiSelectFieldItem = [FKInlineMultiSelectFieldItem inlineMultiSelectFieldItemWithName:@"inlinemultiselectfield" label:@"Inline Multi Select Field"];
        inlineMultiSelectFieldItem.keyAndDisplayValues = selectOptions;
        inlineMultiSelectFieldItem.sortedKeyValues = [selectOptions allKeys];
        [row5 addColumnWithItem:inlineMultiSelectFieldItem];
        
        // ---------- FKSwitchFieldItem
        FKRowItem *row6 = [form addRow];

        FKSwitchFieldItem *switchFieldItem1 = [FKSwitchFieldItem switchFieldItemWithName:@"switchfielditem1" label:@"Switch 1"];
        [row6 addColumnWithItem:switchFieldItem1];

        FKSwitchFieldItem *switchFieldItem2 = [FKSwitchFieldItem switchFieldItemWithName:@"switchfielditem2" label:@"Switch 2"];
        [row6 addColumnWithItem:switchFieldItem2];

        //----------- FKSampleTextAreaItem
        FKRowItem *row7 = [form addRow];
        
        FKSampleTextAreaItem *sampleTextAreaItem = [FKSampleTextAreaItem textAreaItemWithName:@"sampleTextArea" label:@"Sample Text Area" text:@"This is a sample text area"];
        [row7 addColumnWithItem:sampleTextAreaItem];
        
        form.purpose = FKFormPurposeSubmit|FKFormPurposeDelete;
        
        self.form = form;
    }
    return self;
}

// ---------- Override submit
- (void)submit:(id)sender
{
    NSString *formDataAsJsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self.form allValues]  options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [self presentSuccessMessage:[[NSAttributedString alloc] initWithString:formDataAsJsonString]];
}

// ---------- Override delete
- (void)delete:(id)sender {
    [self presentFailureMessage:[[NSAttributedString alloc] initWithString:@"Delete button pressed."]];
}

@end
