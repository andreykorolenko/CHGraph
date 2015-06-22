//
//  CHGraphBottomMonth.h
//  CHGraph
//
//  Created by Andrey Korolenko on 10.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CHGraphBottomPoint;

@interface CHGraphBottomMonth : NSObject

@property (nonatomic, strong) CHGraphBottomPoint *startPoint;
@property (nonatomic, strong) CHGraphBottomPoint *endPoint;
@property (nonatomic, assign) NSInteger numberOfMonth;

@property (nonatomic, strong) UIView *monthView;

@end
