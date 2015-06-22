//
//  CHGraphLine.h
//  CHGraph
//
//  Created by Andrey Korolenko on 08.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHGraphLine : NSObject

@property (nonatomic, strong) NSArray *points;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *pointFillColor;
@property (nonatomic, strong) UIColor *pointStrokeColor;
@property (nonatomic, assign) CGFloat pointStrokeWidth;
@property (nonatomic, assign) CGFloat pointSize;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CAShapeLayer *tintLayer;
@property (nonatomic, strong) CAShapeLayer *pointsLayer;

@end
