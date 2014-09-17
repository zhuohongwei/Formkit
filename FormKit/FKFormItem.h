//
//  FKFormItem.h
//  FormKit
//
//  Created by Hong Wei Zhuo on 17/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FKFormItemView;
@class FKInputItem;
@interface FKFormItem : NSObject
-(FKFormItemView *)createView;
-(FKFormItemView *)view;
-(CGFloat)heightForWidth:(CGFloat)width;
-(FKFormItem *)rootItem;
-(FKInputItem *)itemNamed:(NSString *)name;
-(id)valueForItemNamed:(NSString *)name;
-(void)setValue:(id)value forItemNamed:(NSString *)name;
-(void)layout;
-(void)reload;
-(NSDictionary *)allValues;
-(void)setValues:(NSDictionary *)values;
-(NSArray *)allInputItems;
@end


@class FKRowItem;
@class FKInputItem;
@class FKForm;
@protocol FKFormDelegate <NSObject>
@optional
-(void)form:(FKForm *)form didFocusItem:(FKInputItem *)item;
-(void)form:(FKForm *)form didDefocusItem:(FKInputItem *)item;
-(void)form:(FKForm *)form valueDidChangedForItem:(FKInputItem *)item;
@end


@interface FKForm : FKFormItem
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cancelLabel;
@property (nonatomic, copy) NSString *submitLabel;
@property (nonatomic, copy) NSString *deleteLabel;
@property (nonatomic, strong, readonly) FKInputItem *focus;
@property (nonatomic, weak) id<FKFormDelegate> delegate;

-(FKRowItem *)addRow;
-(void)focusItem:(FKInputItem *)item;
-(void)defocusItem:(FKInputItem *)item;
-(void)valueChangedForItem:(FKInputItem *)item;

@end


@interface FKRowItem : FKFormItem
-(void)addColumnWithItem:(FKFormItem *)item ratio:(CGFloat)ratio;
-(void)addColumnWithItem:(FKFormItem *)item;
@end


@interface FKColumnItem: FKFormItem
@property (nonatomic, strong) FKFormItem *item;
@property (nonatomic, assign) CGFloat ratio;
@end


@interface FKInputItem: FKFormItem
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id value;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, assign) BOOL disabled;
@end


@interface FKTextFieldItem: FKInputItem
+(FKTextFieldItem *) textFieldItemWithName:(NSString *)name label:(NSString *)label text:(NSString *)text placeholder:(NSString *)placeholder;
@end


@interface FKSelectFieldItem: FKInputItem
//value of control refers to selected KEY value;
@property (nonatomic, strong) NSDictionary *keyAndDisplayValues;
@property (nonatomic, strong) NSArray *sortedKeyValues;
-(NSString *)displayValue;
+(FKSelectFieldItem *) selectFieldItemWithName:(NSString *)name label:(NSString *)label placeholder:(NSString *)placeholder;
@end


@interface FKMultiSelectFieldItem: FKSelectFieldItem
+(FKMultiSelectFieldItem *) multiSelectFieldItemWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem;
@end


@interface FKInlineSelectFieldItem : FKSelectFieldItem
+(FKInlineSelectFieldItem *)inlineSelectFieldItemWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem;
@end


@interface FKInlineMultiSelectFieldItem : FKInlineSelectFieldItem
+(FKInlineMultiSelectFieldItem *)inlineMultiSelectFieldItemWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem;
@end