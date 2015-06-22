//
//  CHGraphPoint.m
//  CHGraph
//
//  Created by Andrey Korolenko on 09.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import "CHGraphPoint.h"

@implementation CHGraphPoint

+ (instancetype)pointWithDate:(NSDate *)date value:(NSNumber *)value {
    return [[self alloc] initWithDate:date value:value];
}

- (instancetype)initWithDate:(NSDate *)date value:(NSNumber *)value
{
    self = [super init];
    if (self) {
        self.date = date;
        self.value = value;
    }
    return self;
}

@end
