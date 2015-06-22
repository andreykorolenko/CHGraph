//
//  CHGraphBottomPoint.h
//  CHGraph
//
//  Created by Andrey Korolenko on 10.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHGraphBottomPoint : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) CGFloat xCoorinate;
@property (nonatomic, strong) UIView *dateView;

@end