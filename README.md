# CHGraph

[![Version](https://img.shields.io/cocoapods/v/CHGraph.svg?style=flat)](http://cocoadocs.org/docsets/CHGraph)
[![License](https://img.shields.io/cocoapods/l/CHGraph.svg?style=flat)](http://cocoadocs.org/docsets/CHGraph)
[![Platform](https://img.shields.io/cocoapods/p/CHGraph.svg?style=flat)](http://cocoadocs.org/docsets/CHGraph)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CHGraph is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "CHGraph"

## Usage

CHGraphLine *line = [CHGraphLine new];
line.points = @[
                     [CHGraphPoint pointWithDate:date1 value:@20.0],
                     [CHGraphPoint pointWithDate:date2 value:@30.0],
                     [CHGraphPoint pointWithDate:date3 value:@40.0],
                     [CHGraphPoint pointWithDate:date4 value:@170.0],
                     [CHGraphPoint pointWithDate:date5 value:@200.0],
                     [CHGraphPoint pointWithDate:date6 value:@320.0],
                     ];
CHGraphView *graphView = [[CHGraphView alloc] initWithLines:@[line1] frame:CGRectMake(0, 0, 500, 220)];
[self.view addSubview:graphView];

## Author

Andrey Korolenko, ak@chulakov.ru

## License

CHGraph is available under the MIT license. See the LICENSE file for more info.

