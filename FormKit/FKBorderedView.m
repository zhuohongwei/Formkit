//
//  FKBorderedView.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 20/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKBorderedView.h"

@interface FKBorderedView () {
    UIView *_topBorder;
    UIView *_bottomBorder;
    UIView *_leftBorder;
    UIView *_rightBorder;
}
@end

static CGFloat kBorderWidth;

@implementation FKBorderedView

+(void)initialize {
    if (self == [FKBorderedView class]) {
        kBorderWidth = 1.f/[UIScreen mainScreen].scale;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _topBorder = [UIView new];
        _bottomBorder = [UIView new];
        _leftBorder = [UIView new];
        _rightBorder = [UIView new];
    
        [self addSubview:_topBorder];
        [self addSubview:_bottomBorder];
        [self addSubview:_rightBorder];
        [self addSubview:_leftBorder];
        
        [self setBorderColor:[UIColor lightGrayColor]];
        [self setBorders:UIRectEdgeAll];
    }
    return self;
}

-(void)setBorders:(UIRectEdge)borders {
    _borders = borders;
    _topBorder.hidden = !(borders & UIRectEdgeTop);
    _leftBorder.hidden = !(borders & UIRectEdgeLeft);
    _bottomBorder.hidden = !(borders & UIRectEdgeBottom);
    _rightBorder.hidden = !(borders & UIRectEdgeRight);
}

-(void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    for (UIView *border in @[_topBorder, _bottomBorder, _leftBorder, _rightBorder]) {
        border.backgroundColor = borderColor;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    _topBorder.frame = CGRectMake(0, 0, w, kBorderWidth);
    _bottomBorder.frame = CGRectMake(0, h - kBorderWidth, w, kBorderWidth);
    _leftBorder.frame = CGRectMake(0, 0, kBorderWidth, h);
    _rightBorder.frame = CGRectMake(w - kBorderWidth, 0, kBorderWidth, h);
}

@end
