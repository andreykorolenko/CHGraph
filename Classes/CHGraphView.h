//
//  CHGraphView.h
//  CHGraph
//
//  Created by Andrey Korolenko on 08.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHGraphView : UIScrollView

- (instancetype)initWithLines:(NSArray *)lines frame:(CGRect)frame;

@end
