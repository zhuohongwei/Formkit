//
//  FKFormItemView.h
//  FormKit
//
//  Created by Hong Wei Zhuo on 17/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FKFormItem;
@interface FKFormItemView : UIView
@property (nonatomic, weak) FKFormItem *item;
-(void)reload;
-(FKFormItemView *)rootFormItemView;
@end


@interface FKFormView: FKFormItemView
@end


@interface FKFormRowView: FKFormItemView
@end


@interface FKFormColumnView: FKFormItemView
@end


@interface FKInputControlView: FKFormItemView
-(CGFloat)heightForWidth:(CGFloat)width;
@property (nonatomic, assign) CGFloat labelWidthRatio;
@end


@interface FKTextFieldView: FKInputControlView
@property (nonatomic, strong, readonly) UILabel *fieldLabel;
@property (nonatomic, strong, readonly) UITextField *textField;
@end


@interface FKSelectFieldView: FKInputControlView
@property (nonatomic, strong, readonly) UILabel *fieldLabel;
@property (nonatomic, strong, readonly) UILabel *valueLabel;
@end


@interface FKInlineSelectFieldView : FKInputControlView
@property (nonatomic, strong, readonly) UILabel *fieldLabel;
@property (nonatomic, strong, readonly) NSArray *optionButtons;
@end


@interface FKInlineMultiSelectFieldView: FKInlineSelectFieldView
@end

@interface FKSwitchFieldView : FKInputControlView
@property (nonatomic, strong, readonly) UILabel *fieldLabel;
@property (nonatomic, strong, readonly) UISwitch *switchControl;
@end