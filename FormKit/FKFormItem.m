//
//  FKFormItem.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 17/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKFormItem.h"
#import "FKFormItemView.h"

@interface FKFormItem () {
    FKFormItemView *_view;
}

@property (nonatomic, weak) FKFormItem *parent;

-(FKFormItemView *)viewForItem;
-(NSDictionary *)allValuesUsingAccumulator:(NSMutableDictionary *)accumulator;
-(NSArray *)allInputItemsUsingAccumulator:(NSMutableArray *)accumulator;

@end

@implementation FKFormItem

- (id)init {
    self = [super init];
    if (self) {
        self.parent = nil;
    }
    return self;
}

-(FKFormItemView *)createView {
    _view = [self viewForItem];
    _view.item = self;
    [self reload];
    return _view;
}

-(FKFormItemView *)view {
    return _view;
}

-(FKFormItemView *)viewForItem {
    return [FKFormItemView new];
}

-(FKFormItem *)rootItem {
    if (!self.parent) return self;
    return [self.parent rootItem];
}

-(FKInputItem *)inputItemNamed:(NSString *)name {
    return nil;
}

-(id)valueForInputItemNamed:(NSString *)name {
    FKInputItem *inputItem = [self inputItemNamed:name];
    if (inputItem) {
        return inputItem.value;
    }
    return nil;
}

-(void)setValue:(id)value forInputItemNamed:(NSString *)name {
    FKInputItem *inputItem = [self inputItemNamed:name];
    if (inputItem) {
        inputItem.value = value;
    }
}

-(void)layout {
}

-(void)reload {
    [self.view reload];
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return 0;
}

-(NSDictionary *)allValues {
    return [self allValuesUsingAccumulator:[NSMutableDictionary dictionary]];
}

-(NSArray *)allInputItems {
    return [self allInputItemsUsingAccumulator:[NSMutableArray array]];
}

-(NSDictionary *)allValuesUsingAccumulator:(NSMutableDictionary *)accumulator {
    return accumulator;
}

-(NSArray *)allInputItemsUsingAccumulator:(NSMutableArray *)accumulator {
    return accumulator;
}

-(void)setValues:(NSDictionary *)values {
}

@end

@interface FKForm () {
    NSMutableArray *_rows;
    
    struct {
        unsigned int didFocusItem: 1;
        unsigned int didDefocusItem: 1;
        unsigned int valueChangedForItem: 1;
    } _delegateFlags;
    
}

@property (nonatomic, strong, readwrite) FKInputItem *focus;

@end

@implementation FKForm

-(void)setDelegate:(id<FKFormDelegate>)delegate {
    _delegateFlags.didFocusItem = delegate && [delegate respondsToSelector:@selector(form:didFocusItem:)];
    _delegateFlags.didDefocusItem = delegate && [delegate respondsToSelector:@selector(form:didDefocusItem:)];
    _delegateFlags.valueChangedForItem = delegate && [delegate respondsToSelector:@selector(form:valueDidChangedForItem:)];
    _delegate = delegate;
}


-(void)focusItem:(FKInputItem *)item {
    if (item == _focus) {
        return;
    }
    if (_focus) {
        [self defocusItem:_focus];
    }
    self.focus = item;
    if (_delegateFlags.didFocusItem) {
        [self.delegate form:self didFocusItem:item];
    }
}

-(void)defocusItem:(FKInputItem *)item {
    self.focus = nil;
    if (_delegateFlags.didDefocusItem) {
        [self.delegate form:self didDefocusItem:item];
    }
}

-(void)valueChangedForItem:(FKInputItem *)item {
    if (_delegateFlags.valueChangedForItem) {
        [self.delegate form:self valueDidChangedForItem:item];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _rows = [NSMutableArray array];
    }
    return self;
}

-(FKFormItemView *)viewForItem {
    FKFormView *form = [FKFormView new];
    for (FKRowItem *row in _rows) {
        FKFormItemView *rowView = [row createView];
        [form addSubview:rowView];
    }
    return form;
}

-(FKInputItem *)inputItemNamed:(NSString *)name {
    FKInputItem *item = nil;
    for (FKRowItem *row in _rows) {
        if ((item = [row inputItemNamed:name])) {
            return item;
        }
    }
    return nil;
}

-(FKRowItem *)addRow {
    FKRowItem *row = [FKRowItem new];
    row.parent = self;
    [_rows addObject:row];
    return row;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = 0;
    for (FKRowItem *row in _rows) {
        height += [row heightForWidth:width];
    }
    return height;
}

-(void)layout {
    FKFormItemView *view = self.view;
    CGFloat w = CGRectGetWidth(view.frame);
    
    CGFloat x = 0;
    CGFloat y = 0;
    for (FKRowItem *row in _rows) {
        FKFormItemView *rowView = row.view;
        CGFloat rowHeight = [row heightForWidth:w];
        [rowView setFrame:CGRectMake(x, y, w, rowHeight)];
        y += rowHeight;
    }
}

-(void)reload {
    [super reload];
    for (FKRowItem *row in _rows) {
        [row reload];
    }
}

-(NSDictionary *)allValuesUsingAccumulator:(NSMutableDictionary *)accumulator {
    for (FKRowItem *row in _rows) {
        [row allValuesUsingAccumulator:accumulator];
    }
    return accumulator;
}

-(NSArray *)allInputItemsUsingAccumulator:(NSMutableArray *)accumulator {
    for (FKRowItem *row in _rows) {
        [row allInputItemsUsingAccumulator:accumulator];
    }
    return accumulator;
}

-(void)setValues:(NSDictionary *)values {
    for (FKRowItem *row in _rows) {
        [row setValues:values];
    }
}

@end


static const CGFloat kRatioNotSpecified = -1;
@interface FKRowItem () {
    NSMutableArray *_columns;
}
@end
@implementation FKRowItem

- (id)init {
    self = [super init];
    if (self) {
        _columns = [NSMutableArray array];
    }
    return self;
}

-(void)addColumnWithItem:(FKFormItem *)item ratio:(CGFloat)ratio {
    FKColumnItem *column = [FKColumnItem new];
    column.item = item;
    column.ratio = ratio;
    column.parent = self;
    [_columns addObject:column];
}

-(void)addColumnWithItem:(FKFormItem *)item {
    FKColumnItem *column = [FKColumnItem new];
    column.item = item;
    column.ratio = kRatioNotSpecified;
    column.parent = self;
    [_columns addObject:column];
}

-(FKFormItemView *)viewForItem {
    FKFormRowView *row = [FKFormRowView new];
    for (FKColumnItem *col in _columns) {
        FKFormItemView *columnView = [col createView];
        [row addSubview:columnView];
    }
    return row;
}

-(FKInputItem *)inputItemNamed:(NSString *)name {
    FKInputItem *item = nil;
    for (FKColumnItem *column in _columns) {
        if ((item = [column inputItemNamed:name])) {
            return item;
        }
    }
    return nil;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    CGFloat unallocatedRatio = 1.0f;
    CGFloat height = 0;
    
    NSMutableArray *columnsWithUnspecifiedRatios = [NSMutableArray array];
    
    for (FKColumnItem *column in _columns) {
        if (column.ratio == kRatioNotSpecified) {
            [columnsWithUnspecifiedRatios addObject:column];
            continue;
        }
        unallocatedRatio -= column.ratio;
        height = MAX(height, [column heightForWidth:floor(width*column.ratio)]);
    }
    
    if (unallocatedRatio > 0.f && columnsWithUnspecifiedRatios.count > 0) {
        CGFloat autoRatio = unallocatedRatio/columnsWithUnspecifiedRatios.count;
        for (FKColumnItem *column in columnsWithUnspecifiedRatios) {
            height = MAX(height, [column heightForWidth:floor(width*autoRatio)]);
        }
    }
    
    return height;
}

-(void)layout {
    FKFormItemView *view = self.view;
    
    CGFloat w = CGRectGetWidth(view.frame);
    CGFloat h = CGRectGetHeight(view.frame);
    CGFloat unallocatedRatio = 1.0f;
    CGFloat columnWidth = 0;
    
    NSMutableArray *columnsWithUnspecifiedRatios = [NSMutableArray array];
    for (FKColumnItem *column in _columns) {
        if (column.ratio == kRatioNotSpecified) {
            [columnsWithUnspecifiedRatios addObject:column];
            continue;
        }
        unallocatedRatio -= column.ratio;
    }
    
    if (unallocatedRatio > 0.f && columnsWithUnspecifiedRatios.count > 0) {
        CGFloat autoRatio = unallocatedRatio/columnsWithUnspecifiedRatios.count;
        for (FKColumnItem *column in columnsWithUnspecifiedRatios) {
            column.ratio = autoRatio;
        }
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    for (FKColumnItem *column in _columns) {
        if (column.ratio == kRatioNotSpecified) {
            continue;
        }
        columnWidth = floor(column.ratio*w);
        [column.view setFrame:CGRectMake(x, y, columnWidth, h)];
        x += columnWidth;
    }
}

-(void)reload {
    [super reload];
    for (FKColumnItem *column in _columns) {
        [column reload];
    }
}

-(NSDictionary *)allValuesUsingAccumulator:(NSMutableDictionary *)accumulator {
    for (FKColumnItem *column in _columns) {
        [column allValuesUsingAccumulator:accumulator];
    }
    return accumulator;
}

-(NSArray *)allInputItemsUsingAccumulator:(NSMutableArray *)accumulator {
    for (FKColumnItem *column in _columns) {
        [column allInputItemsUsingAccumulator:accumulator];
    }
    return accumulator;
}

-(void)setValues:(NSDictionary *)values {
    for (FKRowItem *column in _columns) {
        [column setValues:values];
    }
}

@end


@implementation FKColumnItem

-(void)setItem:(FKFormItem *)item {
    _item = item;
    _item.parent = self;
}

-(FKFormItemView *)viewForItem {
    FKFormColumnView *columnView = [FKFormColumnView new];
    FKFormItemView *itemView = [self.item createView];
    [columnView addSubview:itemView];
    return columnView;
}

-(FKInputItem *)inputItemNamed:(NSString *)name {
    return [self.item inputItemNamed:name];
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return [self.item heightForWidth:width];
}

-(void)layout {
    FKFormItemView *view = self.view;
    CGFloat w = CGRectGetWidth(view.frame);
    CGFloat itemHeight = [self heightForWidth:w];
    [self.item.view setFrame:CGRectMake(0, 0, w, itemHeight)];
}

-(void)reload {
    [super reload];
    [self.item reload];
}


-(NSDictionary *)allValuesUsingAccumulator:(NSMutableDictionary *)accumulator {
    return [self.item allValuesUsingAccumulator:accumulator];
}

-(NSArray *)allInputItemsUsingAccumulator:(NSMutableArray *)accumulator {
    return [self.item allInputItemsUsingAccumulator:accumulator];
}

-(void)setValues:(NSDictionary *)values {
    return [self.item setValues:values];
}

@end



@implementation FKInputItem

-(CGFloat)heightForWidth:(CGFloat)width {
    FKInputControlView *view = (FKInputControlView *)self.view;
    return [view heightForWidth:width];
}

-(FKInputItem *)inputItemNamed:(NSString *)name {
    return [self.name isEqualToString:name]?self:nil;
}

-(void)layout {
    //no op;
}

-(void)reload {
    [super reload];
}

-(NSDictionary *)allValuesUsingAccumulator:(NSMutableDictionary *)accumulator {
    if (self.name && self.value) {
        [accumulator setObject:self.value forKey:self.name];
    }
    return accumulator;
}

-(NSArray *)allInputItemsUsingAccumulator:(NSMutableArray *)accumulator {
    [accumulator addObject:self];
    return accumulator;
}

-(void)setValues:(NSDictionary *)values {
    if (self.name) {
        id value = values[self.name];
        if (value) {
            self.value = value;
        }
    }
}

-(void)dealloc {
    if (self.view) {
        UIView *inputView = self.view;
        [self removeObserver:inputView forKeyPath:NSStringFromSelector(@selector(label))];
        [self removeObserver:inputView forKeyPath:NSStringFromSelector(@selector(name))];
        [self removeObserver:inputView forKeyPath:NSStringFromSelector(@selector(value))];
        [self removeObserver:inputView forKeyPath:NSStringFromSelector(@selector(placeholder))];
        [self removeObserver:inputView forKeyPath:NSStringFromSelector(@selector(disabled))];
    }
}

@end


@implementation FKTextFieldItem

-(FKFormItemView *)viewForItem {
    FKTextFieldView *textFieldView = [FKTextFieldView new];
    return textFieldView;
}

+(FKTextFieldItem *) textFieldItemWithName:(NSString *)name label:(NSString *)label text:(NSString *)text placeholder:(NSString *)placeholder {
    FKTextFieldItem *item = [FKTextFieldItem new];
    item.name = name;
    item.label = label;
    item.value = text;
    item.placeholder = placeholder;
    item.disabled = NO;
    return item;
}

@end



@implementation FKSelectFieldItem

-(FKFormItemView *)viewForItem {
    FKSelectFieldView *selectFieldView = [FKSelectFieldView new];
    return selectFieldView;
}

-(void)setKeyAndDisplayValues:(NSDictionary *)keyAndDisplayValues {
    _keyAndDisplayValues = keyAndDisplayValues;
}

-(NSString *)displayValue {
    NSString *displayValue = nil;
    if (self.value) {
        displayValue = [_keyAndDisplayValues objectForKey:self.value];
    }
    return displayValue?displayValue: self.placeholder;
}

+(FKSelectFieldItem *)selectFieldItemWithName:(NSString *)name label:(NSString *)label placeholder:(NSString *)placeholder {
    FKSelectFieldItem *item = [FKSelectFieldItem new];
    item.name = name;
    item.label = label;
    item.placeholder = placeholder;
    item.keyAndDisplayValues = nil;
    item.sortedKeyValues = nil;
    item.value = nil;
    item.disabled = NO;
    return item;
}

@end



@implementation FKMultiSelectFieldItem

-(NSString *)displayValue {
    NSString *displayValue = nil;
    if (self.value) {
        NSArray *selectedKeyValues = (NSArray *)self.value;
        NSArray *displayValues = [self.keyAndDisplayValues objectsForKeys:selectedKeyValues notFoundMarker:[NSNull null]];
        
        displayValues = [displayValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *value, NSDictionary *bindings) {
            return ![value isMemberOfClass:[NSNull class]];
        }]];
        
        if (displayValues.count > 0) {
            displayValue = [displayValues componentsJoinedByString:@", "];
        }
    }
    return displayValue?displayValue: self.placeholder;
}


+(FKMultiSelectFieldItem *)multiSelectFieldItemWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem {
    FKMultiSelectFieldItem *item = [FKMultiSelectFieldItem new];
    item.name = selectFieldItem.name;
    item.label = selectFieldItem.label;
    item.placeholder = selectFieldItem.placeholder;
    item.keyAndDisplayValues = selectFieldItem.keyAndDisplayValues;
    item.sortedKeyValues = selectFieldItem.sortedKeyValues;
    item.value = selectFieldItem.value? @[selectFieldItem.value]: nil;
    item.disabled = selectFieldItem.disabled;
    return item;
}

@end


@implementation FKInlineSelectFieldItem

-(FKFormItemView *)viewForItem {
    FKInlineSelectFieldView *selectFieldView = [FKInlineSelectFieldView new];
    return selectFieldView;
}

+(FKInlineSelectFieldItem *)inlineSelectFieldItemWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem {
    FKInlineSelectFieldItem *item = [FKInlineSelectFieldItem new];
    item.name = selectFieldItem.name;
    item.label = selectFieldItem.label;
    item.placeholder = selectFieldItem.placeholder;
    item.keyAndDisplayValues = selectFieldItem.keyAndDisplayValues;
    item.sortedKeyValues = selectFieldItem.sortedKeyValues;
    item.value = selectFieldItem.value;
    item.disabled = selectFieldItem.disabled;
    return item;
}

@end


@implementation  FKInlineMultiSelectFieldItem

-(FKFormItemView *)viewForItem {
    FKInlineMultiSelectFieldView *selectFieldView = [FKInlineMultiSelectFieldView new];
    return selectFieldView;
}

+(FKInlineMultiSelectFieldItem *)inlineMultiSelectFieldItemWithSelectFieldItem:(FKSelectFieldItem *)selectFieldItem {
    FKInlineMultiSelectFieldItem *item = [FKInlineMultiSelectFieldItem new];
    item.name = selectFieldItem.name;
    item.label = selectFieldItem.label;
    item.placeholder = selectFieldItem.placeholder;
    item.keyAndDisplayValues = selectFieldItem.keyAndDisplayValues;
    item.sortedKeyValues = selectFieldItem.sortedKeyValues;
    item.value = selectFieldItem.value? @[selectFieldItem.value]: nil;
    item.disabled = selectFieldItem.disabled;
    return item;
}

@end


