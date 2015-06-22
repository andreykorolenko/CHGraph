//
//  CHGraphLine.m
//  CHGraph
//
//  Created by Andrey Korolenko on 08.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import "CHGraphLine.h"

@implementation CHGraphLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.color = [UIColor whiteColor];
        self.width = 1.5;
        self.tintColor = [UIColor clearColor];
        self.pointFillColor = [UIColor whiteColor];
        self.pointStrokeColor = [UIColor clearColor];
        self.pointStrokeWidth = 0.0;
        self.pointSize = 5.0;
    }
    return self;
}

@end
