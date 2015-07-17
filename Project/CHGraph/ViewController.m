//
//  ViewController.m
//  CHGraph
//
//  Created by Andrey Korolenko on 08.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import "ViewController.h"

#import "CHGraph.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:1 green:0.36 blue:0.36 alpha:1];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // создаем даты
    NSDateComponents *components = [NSDateComponents new];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    [components setDay:12];
    [components setMonth:05];
    [components setYear:2015];
    NSDate *date1 = [currentCalendar dateFromComponents:components];
    
    [components setDay:13];
    [components setMonth:05];
    [components setYear:2015];
    NSDate *date2 = [currentCalendar dateFromComponents:components];
    
    [components setDay:14];
    [components setMonth:05];
    [components setYear:2015];
    NSDate *date3 = [currentCalendar dateFromComponents:components];
    
    [components setDay:25];
    [components setMonth:06];
    [components setYear:2015];
    NSDate *date4 = [currentCalendar dateFromComponents:components];
    
    [components setDay:27];
    [components setMonth:06];
    [components setYear:2015];
    NSDate *date5 = [currentCalendar dateFromComponents:components];
    
    [components setDay:29];
    [components setMonth:06];
    [components setYear:2015];
    NSDate *date6 = [currentCalendar dateFromComponents:components];
    
    [components setDay:17];
    [components setMonth:05];
    [components setYear:2015];
    NSDate *date7 = [currentCalendar dateFromComponents:components];
    
    // первая линия
    CHGraphLine *line1 = [[CHGraphLine alloc] init];
    line1.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    line1.pointSize = 10.0;
    line1.points = @[
                       [CHGraphPoint pointWithDate:date1 value:@10.0],
                       [CHGraphPoint pointWithDate:date2 value:@30.0],
                       [CHGraphPoint pointWithDate:date3 value:@40.0],
                       [CHGraphPoint pointWithDate:date4 value:@170.0],
                       [CHGraphPoint pointWithDate:date5 value:@200.0],
                       [CHGraphPoint pointWithDate:date6 value:@320.0],
                       ];
    
    // вторая линия
    CHGraphLine *line2 = [[CHGraphLine alloc] init];
    line2.color = [UIColor blackColor];
    line2.pointFillColor = [UIColor blackColor];
    line2.pointSize = 10.0;
    line2.points = @[
                       [CHGraphPoint pointWithDate:date1 value:@50.0],
                       [CHGraphPoint pointWithDate:date2 value:@80.0],
                       [CHGraphPoint pointWithDate:date7 value:@90.0],
                       [CHGraphPoint pointWithDate:date3 value:@120.0],
                       [CHGraphPoint pointWithDate:date4 value:@200.0],
                       [CHGraphPoint pointWithDate:date5 value:@250.0],
                       [CHGraphPoint pointWithDate:date6 value:@360.0]
                       ];
    
    // график
    CHGraphView *graphView = [[CHGraphView alloc] initWithLines:@[line1, line2] frame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 20.0)];
    [self.view addSubview:graphView];
}

@end
