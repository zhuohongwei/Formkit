//
//  FKSampleTextAreaItem.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 23/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKSampleTextAreaItem.h"
#import "FKSampleTextAreaView.h"

@implementation FKSampleTextAreaItem

-(FKFormItemView *)viewForItem {
    return [FKSampleTextAreaView new];
}

+(FKSampleTextAreaItem *)textAreaItemWithName:(NSString *)name label:(NSString *)label text:(NSString *)text {
    FKSampleTextAreaItem *item = [FKSampleTextAreaItem new];
    item.name = name;
    item.label = label;
    item.value = text;
    item.disabled = NO;
    return item;
}

@end
