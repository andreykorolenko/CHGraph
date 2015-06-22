//
//  CHGraphView.m
//  CHGraph
//
//  Created by Andrey Korolenko on 08.06.15.
//  Copyright (c) 2015 Oleg Chulakov Studio LLC. All rights reserved.
//

#import "CHGraphView.h"
#import "CHGraphLine.h"
#import "CHGraphPoint.h"
#import "CHGraphBottomPoint.h"
#import "CHGraphBottomMonth.h"

static CGFloat const kDefaultBottomHeight = 60.0;
static dispatch_once_t *once_token_debug;

@interface CHGraphView ()

@property (nonatomic, strong) NSArray *lines;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *bottomView;

// максимальные значения на графике
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, strong) NSDate *maxDate;

// bottom
@property (nonatomic, strong) CAShapeLayer *bottomDatesLayer;
@property (nonatomic, strong) CAShapeLayer *bottomMonthsLayer;
@property (nonatomic, strong) NSArray *bottomPoints;
@property (nonatomic, assign) NSInteger countDays;
@property (nonatomic, strong) UIView *monthView;
@property (nonatomic, strong) NSMutableArray *bottomMonths;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) CGFloat newWidth;
@property (nonatomic, assign) CGFloat oldWidth;

@property (nonatomic, assign) BOOL enableZoom;
@property (nonatomic, assign) BOOL monthsShowing;

@end

@implementation CHGraphView

- (instancetype)initWithLines:(NSArray *)lines frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(lines, @"CHGraphView: lines array cannot be nil!");
        self.lines = lines;
        
        // reset dispatch_once
        if (once_token_debug) {
            *once_token_debug = 0;
        }
        
        [self saveAllDates];
        
        if (lines.count > 0) {
            [self createGraph];
        }
    }
    return self;
}

#pragma mark - All Graph

- (void)createGraph {
    
    self.showsHorizontalScrollIndicator = NO;
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 10.0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kDefaultBottomHeight)];
    [self addSubview:self.backgroundView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backgroundView.bounds) + 10.0, CGRectGetWidth(self.bounds), kDefaultBottomHeight)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bottomView];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = [UIColor whiteColor];
    [self.bottomView addSubview:separator];
    
    NSDictionary *views = @{@"separator": separator};
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-500)-[separator]-(-500)-|" options:0 metrics:nil views:views]];
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[separator(1)]" options:0 metrics:nil views:views]];
    
    [self sortedAllPointsByDate];
    
    [self drawBottomView];
    
    [self setMaxValuesInGraph];
    for (CHGraphLine *line in self.lines) {
        [self drawLine:line];
    }
    
    UIPinchGestureRecognizer *panGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:panGesture];
    
    self.enableZoom = YES;
}

// зум графика
- (void)zoomGraphIn:(BOOL)zoomIn touchPoint:(CGPoint)touchPoint {
    
    if (!self.enableZoom && zoomIn) {
        return;
    }
    
    self.oldWidth = self.contentSize.width;
    
    CGFloat difference = 20.0;
    
    CGRect newFrameForBackground = CGRectMake(CGRectGetMinX(self.backgroundView.frame), CGRectGetMinY(self.backgroundView.frame), zoomIn ? CGRectGetWidth(self.backgroundView.frame) + difference : CGRectGetWidth(self.backgroundView.frame) - difference, CGRectGetHeight(self.backgroundView.bounds));
    CGRect newFrameForBottom = CGRectMake(CGRectGetMinX(self.bottomView.frame), CGRectGetMinY(self.bottomView.frame), zoomIn ? CGRectGetWidth(self.bottomView.frame) + difference : CGRectGetWidth(self.bottomView.frame) - difference, CGRectGetHeight(self.bottomView.bounds));
    
    // не даем уменьшать, если график становится меньше ширины экрана
    if (CGRectGetWidth(newFrameForBackground) > CGRectGetWidth(self.bounds)) {
        self.backgroundView.frame = newFrameForBackground;
        self.bottomView.frame = newFrameForBottom;
        [self showAllDates:YES];
    } else {
        [self showAllDates:NO];
    }
    
    self.contentSize = self.backgroundView.frame.size;
    [self updateBottomView];
    [self updateAllLines];
   
    self.newWidth = self.contentSize.width;
    
    // скроллим, в зависимости от положения пальца
    CGRect visibleRect = CGRectMake(self.contentOffset.x + ((self.newWidth - self.oldWidth) / (CGRectGetWidth(self.frame) / touchPoint.x)), self.contentOffset.y, self.frame.size.width, self.frame.size.height);
    [self scrollRectToVisible:visibleRect animated:NO];
}

- (void)sortedAllPointsByDate {
    for (CHGraphLine *line in self.lines) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSArray *sortedPoints = [line.points sortedArrayUsingDescriptors:@[sortDescriptor]];
        line.points = sortedPoints;
    }
}

#pragma mark - Lines and Points

- (void)drawLine:(CHGraphLine *)line {
    
    // line
    line.lineLayer = [CAShapeLayer layer];
    line.lineLayer.frame = self.bounds;
    line.lineLayer.fillColor = [UIColor clearColor].CGColor;
    line.lineLayer.strokeColor = line.color.CGColor;
    line.lineLayer.lineWidth = line.width;
    [self.backgroundView.layer addSublayer:line.lineLayer];
    
    // line
    line.tintLayer = [CAShapeLayer layer];
    line.tintLayer.frame = self.bounds;
    line.tintLayer.fillColor = line.tintColor.CGColor;
    [self.backgroundView.layer addSublayer:line.tintLayer];
    
    // points
    line.pointsLayer = [CAShapeLayer layer];
    line.pointsLayer.frame = self.bounds;
    line.pointsLayer.fillColor = line.pointFillColor.CGColor;
    line.pointsLayer.strokeColor = line.pointStrokeColor.CGColor;
    line.pointsLayer.lineWidth = line.pointStrokeWidth;
    [self.backgroundView.layer addSublayer:line.pointsLayer];
    
    [self updateDrawPathInLine:line];
}

// рисует или перерисовывает линию и точки на ней
- (void)updateDrawPathInLine:(CHGraphLine *)line {
    
    CGMutablePathRef linePath = CGPathCreateMutable();
    CGMutablePathRef tintPath = CGPathCreateMutable();
    CGMutablePathRef pointsPath = CGPathCreateMutable();
    
    CHGraphPoint *firstPoint = [line.points firstObject];
    CHGraphPoint *lastPoint = nil;
    
    CGPathMoveToPoint(linePath, NULL, [self xCoordinateForPoint:firstPoint], [self yCoordinateForPoint:firstPoint]);
    CGPathMoveToPoint(tintPath, NULL, [self xCoordinateForPoint:firstPoint], [self yCoordinateForPoint:firstPoint]);
    for (CHGraphPoint *point in line.points) {
        CGPathAddLineToPoint(linePath, NULL, [self xCoordinateForPoint:point], [self yCoordinateForPoint:point]);
        CGPathAddLineToPoint(tintPath, NULL, [self xCoordinateForPoint:point], [self yCoordinateForPoint:point]);
        CGPathAddEllipseInRect(pointsPath, NULL, CGRectMake([self xCoordinateForPoint:point] - line.pointSize / 2, [self yCoordinateForPoint:point] - line.pointSize / 2, line.pointSize, line.pointSize));
        lastPoint = point;
    }
    
    CGPathAddLineToPoint(tintPath, NULL, [self xCoordinateForPoint:lastPoint], CGRectGetHeight(self.backgroundView.frame));
    CGPathAddLineToPoint(tintPath, NULL, [self xCoordinateForPoint:firstPoint], CGRectGetHeight(self.backgroundView.frame));
    
    line.lineLayer.path = linePath;
    line.tintLayer.path = tintPath;
    line.pointsLayer.path = pointsPath;
}

// перерисовывает все линии
- (void)updateAllLines {
    for (CHGraphLine *line in self.lines) {
        [self updateDrawPathInLine:line];
    }
}

- (CGFloat)xCoordinateForPoint:(CHGraphPoint *)point {
    for (CHGraphBottomPoint *bottomPoint in self.bottomPoints) {
        if ([point.date isEqual:bottomPoint.date]) {
            return bottomPoint.xCoorinate;
        }
    }
    return 0.0;
}

- (CGFloat)yCoordinateForPoint:(CHGraphPoint *)point {
    return CGRectGetHeight(self.backgroundView.bounds) - (CGRectGetHeight(self.backgroundView.bounds) / (self.maxValue / [point.value floatValue]));
}

// устанавливает максимальные значения графика
- (void)setMaxValuesInGraph {
    
    self.maxValue = 0.0;
    self.maxDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    for (CHGraphLine *line in self.lines) {
        for (CHGraphPoint *point in line.points) {
            if ([point.value floatValue] > self.maxValue) {
                self.maxValue = [point.value floatValue];
            }
            if ([point.date compare:self.maxDate] == NSOrderedDescending) {
                self.maxDate = point.date;
            }
        }
    }
}

#pragma mark - Bottom

- (void)drawBottomView {
    
    // дни
    self.bottomDatesLayer = [CAShapeLayer layer];
    self.bottomDatesLayer.frame = self.bounds;
    self.bottomDatesLayer.fillColor = [UIColor whiteColor].CGColor;
    self.bottomDatesLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.bottomDatesLayer.zPosition = 1;
    self.bottomDatesLayer.opacity = 0.0;
    [self.bottomView.layer addSublayer:self.bottomDatesLayer];
    
    for (CHGraphBottomPoint *bottomPoint in self.bottomPoints) {
        UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        bottomPoint.dateView = dateView;
        [self.bottomDatesLayer addSublayer:dateView.layer];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(dateView.frame), CGRectGetHeight(dateView.frame))];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.numberOfLines = 0;
        dateLabel.textColor = [UIColor whiteColor];
        
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [currentCalendar components:NSCalendarUnitDay fromDate:bottomPoint.date];
        dateLabel.text = [NSString stringWithFormat:@"%ld %@", (long)components.day, [self shortStringMonthFromDate:bottomPoint.date]];
        
        dateLabel.textAlignment = NSTextAlignmentCenter;
        [dateView addSubview:dateLabel];
    }
    
    // месяцы
    self.bottomMonthsLayer = [CAShapeLayer layer];
    self.bottomMonthsLayer.frame = self.bounds;
    self.bottomMonthsLayer.fillColor = [UIColor whiteColor].CGColor;
    self.bottomMonthsLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.bottomMonthsLayer.zPosition = 1;
    [self.bottomView.layer addSublayer:self.bottomMonthsLayer];
    
    self.bottomMonths = [NSMutableArray array];
    
    [self updateBottomView];
}

- (void)updateBottomView {
    
    // days
    CGMutablePathRef bottomDatesPath = CGPathCreateMutable();
    
    CHGraphBottomPoint *lastPoint;
    CGFloat xCoordinate = 20.0;
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    for (CHGraphBottomPoint *bottomPoint in self.bottomPoints) {
        
        if (lastPoint) {
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:lastPoint.date toDate:bottomPoint.date options:0];
            xCoordinate += [self marginForDifferenceBetweenDays:components.day];
            
            // show months or days
            if (xCoordinate - lastPoint.xCoorinate < 50) {
                 [self showAllDates:NO];
                self.enableZoom = YES;
            }
        }
        
        [self drawVerticalLinePath:bottomDatesPath xCoordinate:xCoordinate];
        bottomPoint.dateView.center = CGPointMake(xCoordinate, 30);
        bottomPoint.xCoorinate = xCoordinate;
        lastPoint = bottomPoint;
    }
    
    // months
    CGMutablePathRef bottomMonthsPath = CGPathCreateMutable();
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    lastPoint = nil;
    NSInteger countPoints = 0;
    __block CHGraphBottomPoint *startPoint = nil;
    for (CHGraphBottomPoint *bottomPoint in self.bottomPoints) {
        
        if (!lastPoint) {
            [self drawVerticalLinePath:bottomMonthsPath xCoordinate:bottomPoint.xCoorinate];
            startPoint = bottomPoint;
        } else {
            
            NSDateComponents *componentsLastDate = [currentCalendar components:NSCalendarUnitMonth fromDate:lastPoint.date];
            NSDateComponents *componentsCurrentDate = [currentCalendar components:NSCalendarUnitMonth fromDate:bottomPoint.date];
            
            // конец месяца
            if (componentsLastDate.month != componentsCurrentDate.month) {
                [self drawVerticalLinePath:bottomMonthsPath xCoordinate:bottomPoint.xCoorinate];
                
                static dispatch_once_t onceToken;
                once_token_debug = &onceToken;
                dispatch_once(&onceToken, ^{
                    
                    CHGraphBottomMonth *bottomMonth = [CHGraphBottomMonth new];
                    bottomMonth.startPoint = startPoint;
                    bottomMonth.endPoint = bottomPoint;
                    bottomMonth.numberOfMonth = componentsLastDate.month;
                    
                    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomMonth.startPoint.xCoorinate, 10, bottomMonth.endPoint.xCoorinate - bottomMonth.startPoint.xCoorinate, 40)];
                    monthLabel.text = [self fullStringMonth:componentsLastDate.month];
                    monthLabel.textAlignment = NSTextAlignmentCenter;
                    monthLabel.font = [UIFont systemFontOfSize:14.0];
                    monthLabel.textColor = [UIColor whiteColor];
                    [self.bottomMonthsLayer addSublayer:monthLabel.layer];
                    [self.bottomMonths addObject:bottomMonth];
                    bottomMonth.monthView = monthLabel;
                    startPoint = bottomPoint;
                });
                
            // конец графика
            } else if (countPoints == self.bottomPoints.count - 1) {
                [self drawVerticalLinePath:bottomMonthsPath xCoordinate:bottomPoint.xCoorinate];
                
                static dispatch_once_t onceToken;
                once_token_debug = &onceToken;
                dispatch_once(&onceToken, ^{

                    CHGraphBottomMonth *bottomMonth = [CHGraphBottomMonth new];
                    bottomMonth.startPoint = startPoint;
                    bottomMonth.endPoint = bottomPoint;
                    bottomMonth.numberOfMonth = componentsCurrentDate.month;
                    
                    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomMonth.startPoint.xCoorinate, 10, bottomMonth.endPoint.xCoorinate - bottomMonth.startPoint.xCoorinate, 40)];
                    monthLabel.text = [self fullStringMonth:componentsCurrentDate.month];
                    monthLabel.textAlignment = NSTextAlignmentCenter;
                    monthLabel.font = [UIFont systemFontOfSize:14.0];
                    monthLabel.textColor = [UIColor whiteColor];
                    [self.bottomMonthsLayer addSublayer:monthLabel.layer];
                    [self.bottomMonths addObject:bottomMonth];
                    bottomMonth.monthView = monthLabel;
                });
            }
        }
        
        lastPoint = bottomPoint;
        countPoints++;
    }
    
    for (CHGraphBottomMonth *bottomMonth in self.bottomMonths) {
        UIView *monthView = bottomMonth.monthView;
        monthView.center = CGPointMake(((bottomMonth.endPoint.xCoorinate - bottomMonth.startPoint.xCoorinate) / 2) + bottomMonth.startPoint.xCoorinate, 25);
    }
    
    self.bottomDatesLayer.path = bottomDatesPath;
    self.bottomMonthsLayer.path = bottomMonthsPath;
}

- (void)showAllDates:(BOOL)show {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomDatesLayer.opacity = show ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomMonthsLayer.opacity = show ? 0.0 : 1.0;
        }];
        self.enableZoom = show ? NO : YES;
    }];
}

- (void)drawVerticalLinePath:(CGMutablePathRef)path xCoordinate:(CGFloat)xCoordinate {
    CGPathMoveToPoint(path, NULL, xCoordinate, 0);
    CGPathAddLineToPoint(path, NULL, xCoordinate, 10);
}

// собирает все даты со всех точек, создает объекты CHGraphBottomPoint и сортирует их по возрастанию
- (void)saveAllDates {
    
    NSMutableSet *datesSet = [NSMutableSet set];
    for (CHGraphLine *line in self.lines) {
        for (CHGraphPoint *point in line.points) {
            [datesSet addObject:point.date];
        }
    }
    
    NSArray *datesArray = [NSArray arrayWithArray:datesSet.allObjects];
    datesArray = [datesArray sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *bottomPoints = [NSMutableArray array];
    for (NSDate *date in datesArray) {
        CHGraphBottomPoint *point = [CHGraphBottomPoint new];
        point.date = date;
        [bottomPoints addObject:point];
    }
    
    self.bottomPoints = [NSArray arrayWithArray:bottomPoints];
    
    // узнаем количество дней в графике
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:[datesArray firstObject] toDate:[datesArray lastObject] options:0];
    self.countDays = components.day;
}

- (CGFloat)marginForDifferenceBetweenDays:(NSInteger)days {
    return ((CGRectGetWidth(self.bottomView.bounds) - 40) / self.countDays) * days;
}

#pragma mark - Gestures

- (void)pinchGesture:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint touchPoint = [sender locationInView:nil];
        [self zoomGraphIn:(sender.velocity > 0) ? YES : NO touchPoint:touchPoint];
    }
}

#pragma mark - Date Formatter

- (NSString *)shortStringMonthFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM"];
    
    NSString *nameOfMonth = [[dateFormatter stringFromDate:date] lowercaseString];
    return (nameOfMonth.length > 3) ? [[nameOfMonth substringToIndex:3] stringByAppendingString:@"."] : nameOfMonth;
}

- (NSString *)fullStringMonth:(NSInteger)month {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *nameOfMonth = [dateFormatter standaloneMonthSymbols][month - 1];
    return [nameOfMonth lowercaseString];
}

@end
