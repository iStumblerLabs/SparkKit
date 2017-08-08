#import "SparkyController.h"


@implementation SparkyController

#pragma mark - ILViews

- (void) initView
{
    [self loadView];
    
    self.sparkText.gaugeStyle = ILSparkMeterTextStyle;
    self.sparkVert.gaugeStyle = ILSparkMeterVerticalStyle;
    self.sparkHorz.gaugeStyle = ILSparkMeterHorizontalStyle;
    self.sparkSquare.gaugeStyle = ILSparkMeterSquareStyle;
    self.sparkCircle.gaugeStyle = ILSparkMeterCircleStyle;
    self.sparkRing.gaugeStyle = ILSparkMeterRingStyle;
    self.sparkPie.gaugeStyle = ILSparkMeterPieStyle;
    self.sparkDial.gaugeStyle = ILSparkMeterDialStyle;
    
    self.sparkLine.dataSource = self;
    self.sparkText.dataSource = self;
    self.sparkVert.dataSource = self;
    self.sparkHorz.dataSource = self;
    self.sparkSquare.dataSource = self;
    self.sparkCircle.dataSource = self;
    self.sparkRing.dataSource = self;
    self.sparkPie.dataSource = self;
    self.sparkDial.dataSource = self;
    
    self.gridData = [ILGridData floatGridWithRows:0 columns:10];
    self.sparkGrid.grid = self.gridData;
    self.sparkGrid.xAxisLabels = @[@"1", @"2", @"3", @"4", @"5"];
    self.sparkGrid.yAxisLabels = @[@"a", @"b", @"c", @"d", @"e"];
    
    self.bucketData = [ILBucketData new];
    self.sparkBars.dataSource = self.bucketData;
    self.bucketData.buckets = @[@(0.0), @(0.25), @(0.5), @(.75), @(1.0), @(0.3), @(0.6), @(0.9), @(0.0)];
    
    
#if TARGET_OS_TV
    [ILSparkStyle defaultStyle].width = 0;
    [ILSparkStyle defaultStyle].font = [ILFont fontWithName:@"Helvetica" size:48];
    [ILSparkStyle defaultStyle].background = [ILColor lightGrayColor];
    [ILSparkStyle defaultStyle].border = [ILColor clearColor];
    [ILSparkStyle defaultStyle].stroke = [ILColor clearColor];
    [[ILSparkStyle defaultStyle] addHints:@{
        ILSparkMeterRingWidthHint: @36,
        ILSparkMeterDialWidthHint: @8,
        ILSparkLineScaleFactor: @0.5
    }];
#endif
}

- (void) updateView
{
    [self.sparkLine updateView];

    // square indicators
    [self.sparkText updateView];
    [self.sparkVert updateView];
    [self.sparkHorz updateView];
    [self.sparkSquare updateView];

    // circular indicators
    [self.sparkCircle updateView];
    [self.sparkRing updateView];
    [self.sparkPie updateView];
    [self.sparkDial updateView];
    
    /* append some grid data */
    NSMutableData* blankRow = [NSMutableData dataWithLength:self.gridData.sizeOfRow]; // start small
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];

    int index = 0;
    while (index < self.gridData.columns) {
        CGFloat sine = (sin(interval / 5) / 2) + 0.5;
        void* valueAddress = (blankRow.mutableBytes + (index * sizeof(CGFloat)));
        memcpy(valueAddress, &sine, sizeof(CGFloat));
        index++;
    }
    [self.gridData appendData:blankRow];
    [self.sparkGrid updateView];
    
    [self.sparkBars updateView];
}

#pragma mark - ILSparkMeterDataSource

- (CGFloat) datum
{
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    CGFloat sine = (sin(interval / 5) / 2) + 0.5;
    // NSLog(@"sampleValueAtIndex: %lu interval: %f -> %f", (unsigned long)index, interval, sine);
    return sine;
}

#pragma mark - ILSparkLineDataSource

-(NSArray<NSDate*>*) sampleDates {
    NSMutableArray* dateArray = [NSMutableArray new];
    for (NSInteger index = 0; index < 1000; index = index+1) {
        if (index < 100 || index > 200) { // 100 second gap
            [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:-(index)]];
        }
    }
    return [NSArray arrayWithArray:dateArray];
}

- (CGFloat) sampleValueAtIndex:(NSUInteger) index {
    NSTimeInterval interval = [self.sampleDates[index] timeIntervalSinceReferenceDate];
    CGFloat sine = (sin(interval/5)/2)+0.5;
    // NSLog(@"sampleValueAtIndex: %lu interval: %f -> %f", (unsigned long)index, interval, sine);
    return sine;
}

@end
