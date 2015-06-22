//
//  CHGraphPoint.h
//  CHGraph
//
//  Created by Andrey Korolenko on 09.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHGraphPoint : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *value;

+ (instancetype)pointWithDate:(NSDate *)date value:(NSNumber *)value;

@end