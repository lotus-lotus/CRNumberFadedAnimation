//
//  CRNumberFaded.m
//  CRNumberFaded
//
//  Created by Bear on 17/3/22.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CRNumberFaded.h"
#import "CRFadedView.h"

typedef NS_ENUM(NSUInteger, CRFadeViewIndexType) {
    CRFadeViewIndexType_Last,
    CRFadeViewIndexType_Now,
    CRFadeViewIndexType_Next,
};

typedef NS_ENUM(NSUInteger, CRFadeViewDirType) {
    CRFadeViewDirType_Null,
    CRFadeViewDirType_Last,
    CRFadeViewDirType_Next,
};


@interface CRNumberFaded () <CRFadedViewDelegate>
{
    NSMutableArray  *_fadedViews;
    int             _toIndex;
}

@property (assign, nonatomic) int currentIndex;

@end

@implementation CRNumberFaded

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSetPara];
        [self createUI];
    }
    
    return self;
}

- (void)initSetPara
{
    _currentIndex = 0;
    self.allowCircle = YES;
}

- (void)createUI
{
    
}

- (void)generateFadedViews
{
    if (_fadedViews) {
        for (CRFadedView *fadedView in _fadedViews) {
            [fadedView removeFromSuperview];
        }
    }else{
        _fadedViews = [NSMutableArray new];
    }
    
    int actualDafedViewsTotal = 3;
    for (int i = 0; i < actualDafedViewsTotal; i++) {
        CRFadedView *fadedView = [[CRFadedView alloc] initWithFrame:self.bounds];
        [self addSubview:fadedView];
        [_fadedViews addObject:fadedView];
    }
    
    CRFadedView *fadedViewLast  = [self getFadedViewWithIndexType:CRFadeViewIndexType_Last];
    CRFadedView *fadedViewNow   = [self getFadedViewWithIndexType:CRFadeViewIndexType_Now];
    CRFadedView *fadedViewNext  = [self getFadedViewWithIndexType:CRFadeViewIndexType_Next];
    
    fadedViewLast.layer.opacity = 0;
    fadedViewLast.label.text = _strings[[self caculateIndex:_currentIndex - 1]];
    [fadedViewLast relayUI];
    
    fadedViewNow.layer.opacity = 1;
    fadedViewNow.label.text = _strings[[self caculateIndex:_currentIndex]];
    [fadedViewNow relayUI];
    
    fadedViewNext.layer.opacity = 0;
    fadedViewNext.label.text = _strings[[self caculateIndex:_currentIndex + 1]];
    [fadedViewNext relayUI];
}

- (void)showNextView
{
    [self showNextViewWithDuratin:nil];
}

- (void)showNextViewWithDuratin:(NSNumber *)duration
{
    if (!duration) {
        duration = @0.6;
    }
    
    CRFadedView *fadedViewLast  = [self getFadedViewWithIndexType:CRFadeViewIndexType_Last];
    CRFadedView *fadedViewNow   = [self getFadedViewWithIndexType:CRFadeViewIndexType_Now];
    CRFadedView *fadedViewNext  = [self getFadedViewWithIndexType:CRFadeViewIndexType_Next];
    
    fadedViewLast.animationDuration = duration;
    fadedViewLast.layer.opacity = 0;
    
    fadedViewNow.animationDuration = duration;
    fadedViewNow.layer.opacity = 0;
    
    fadedViewNext.animationDuration = duration;
    fadedViewNext.layer.opacity = 0;
    
    fadedViewLast.label.text = _strings[[self caculateIndex:self.currentIndex - 1]];
    
    fadedViewNow.label.text = _strings[[self caculateIndex:self.currentIndex]];
    [fadedViewNow fadedViewAnimationWithType:CRFadedViewAnimationType_NormalToBig];
    
    fadedViewNext.label.text = _strings[[self caculateIndex:self.currentIndex + 1]];
    [fadedViewNext relayUI];
    [fadedViewNext fadedViewAnimationWithType:CRFadedViewAnimationType_SmallToNormal];
    
    [self insertSubview:fadedViewLast belowSubview:fadedViewNext];
    
    [self setDelegateOfFadedView:fadedViewNext];
    [_fadedViews removeAllObjects];
    [_fadedViews addObjectsFromArray:self.subviews];
//    [_fadedViews addObjectsFromArray:@[fadedViewLast, fadedViewNext, fadedViewNow]];
    
    self.currentIndex = self.currentIndex + 1;
}

- (void)showLastView
{
    [self showLastViewWithDuratin:nil];
}

- (void)showLastViewWithDuratin:(NSNumber *)duration
{
    if (!duration) {
        duration = @0.6;
    }
    
    CRFadedView *fadedViewLast  = [self getFadedViewWithIndexType:CRFadeViewIndexType_Last];
    CRFadedView *fadedViewNow   = [self getFadedViewWithIndexType:CRFadeViewIndexType_Now];
    CRFadedView *fadedViewNext  = [self getFadedViewWithIndexType:CRFadeViewIndexType_Next];
    
    fadedViewLast.animationDuration = duration;
    fadedViewLast.layer.opacity = 0;
    
    fadedViewNow.animationDuration = duration;
    fadedViewNow.layer.opacity = 0;
    
    fadedViewNext.animationDuration = duration;
    fadedViewNext.layer.opacity = 0;
    
    fadedViewLast.label.text = _strings[[self caculateIndex:self.currentIndex - 1]];
    [fadedViewLast relayUI];
    [fadedViewLast fadedViewAnimationWithType:CRFadedViewAnimationType_BigToNormal];
    
    fadedViewNow.label.text = _strings[[self caculateIndex:self.currentIndex]];
    [fadedViewNow fadedViewAnimationWithType:CRFadedViewAnimationType_NormalToSmall];
    
    fadedViewNext.label.text = _strings[[self caculateIndex:self.currentIndex + 1]];
    
    [self insertSubview:fadedViewNext aboveSubview:fadedViewLast];
    
    [self setDelegateOfFadedView:fadedViewLast];
    [_fadedViews removeAllObjects];
    [_fadedViews addObjectsFromArray:self.subviews];
//    [_fadedViews addObjectsFromArray:@[fadedViewNext, fadedViewLast, fadedViewNow]];
    
    self.currentIndex = self.currentIndex - 1;
}

- (void)showToIndex:(int)toIndex
{
    _toIndex = toIndex;
    
    if (_toIndex != _currentIndex) {
        [self caculateSpeedAndScroll];
    }
}

- (void)caculateSpeedAndScroll
{
    int overAndFastSpeed = 3;
    int overAndNormalSpeed = 2;
    int overAndSlowSpeed = 1;
    
    CRFadeViewDirType direction = CRFadeViewDirType_Null;
    if (_toIndex > _currentIndex) {
        direction = CRFadeViewDirType_Next;
    }else if (_toIndex < _currentIndex){
        direction = CRFadeViewDirType_Last;
    }
    
    int D_value = abs(_toIndex - _currentIndex);
    if (D_value >= overAndFastSpeed) {
        
        if (direction == CRFadeViewDirType_Next) {
            [self showNextViewWithDuratin:@0.2];
        }else if (direction == CRFadeViewDirType_Last){
            [self showLastViewWithDuratin:@0.2];
        }
        
    }else if (D_value >= overAndNormalSpeed) {
    
        if (direction == CRFadeViewDirType_Next) {
            [self showNextViewWithDuratin:@0.2];
        }else if (direction == CRFadeViewDirType_Last){
            [self showLastViewWithDuratin:@0.2];
        }
        
    }else if (D_value >= overAndSlowSpeed) {
    
        if (direction == CRFadeViewDirType_Next) {
            [self showNextViewWithDuratin:@0.2];
        }else if (direction == CRFadeViewDirType_Last){
            [self showLastViewWithDuratin:@0.2];
        }
        
    }
}

#pragma mark - SetDelegate
- (void)setDelegateOfFadedView:(CRFadedView *)fadedView
{
    for (CRFadedView *tempFadedView in _fadedViews) {
        tempFadedView.delegate = nil;
    }
    
    fadedView.delegate = self;
}

#pragma mark - CRFadedViewDelegate
- (void)animationDidFinishedInFadedView:(CRFadedView *)fadedView
{
    [self caculateSpeedAndScroll];
}

#pragma mark - Setter & Getter
- (void)setStrings:(NSArray *)strings
{
    _strings = strings;
    [self generateFadedViews];
}

@synthesize currentIndex = _currentIndex;
- (void)setCurrentIndex:(int)currentIndex
{
    _currentIndex = [self caculateIndex:currentIndex];
}

- (int)caculateIndex:(int)index
{
    int stringsCount = (int)[_strings count];
    
    if (index < 0) {
        int deltaValue = - index;
        deltaValue = deltaValue % stringsCount;
        index = stringsCount - deltaValue;
    }else if (index >= stringsCount){
        int deltaValue = index - stringsCount;
        deltaValue = deltaValue % stringsCount;
        index = deltaValue;
    }
    
    return index;
}

- (CRFadedView *)getFadedViewWithIndexType:(CRFadeViewIndexType)indexType
{
    int index;
    switch (indexType) {
        case CRFadeViewIndexType_Last: index = 2; break;
        case CRFadeViewIndexType_Now: index = 1; break;
        case CRFadeViewIndexType_Next: index = 0; break;
            
        default:
            break;
    }
    CRFadedView *fadedView = _fadedViews[index];
    
    return fadedView;
}

@end
