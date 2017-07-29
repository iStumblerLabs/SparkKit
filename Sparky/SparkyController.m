#import "SparkyController.h"

@interface SparkyController ()

@end

#pragma mark -

@implementation SparkyController

#pragma mark - ILViews

- (void) initView
{
    [self loadView];
    
    self.sparkText.gaugeStyle = ILSparkGaugeTextStyle;
    self.sparkVert.gaugeStyle = ILSparkGaugeVerticalStyle;
    self.sparkHorz.gaugeStyle = ILSparkGaugeHorizontalStyle;
    self.sparkSquare.gaugeStyle = ILSparkGaugeSquareStyle;
    self.sparkCircle.gaugeStyle = ILSparkGaugeCircleStyle;
    self.sparkRing.gaugeStyle = ILSparkGaugeRingStyle;
    self.sparkPie.gaugeStyle = ILSparkGaugePieStyle;
    self.sparkDial.gaugeStyle = ILSparkGaugeDialStyle;
    
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
    self.sparkGrid.xAxisLabels = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    self.sparkGrid.yAxisLabels = @[@"a", @"b", @"c"];
    
#if TARGET_OS_TV
    [ILSparkStyle defaultStyle].width = 0;
    [ILSparkStyle defaultStyle].font = [ILFont fontWithName:@"Helvetica" size:48];
    [ILSparkStyle defaultStyle].background = [ILColor lightGrayColor];
    [ILSparkStyle defaultStyle].border = [ILColor clearColor];
    [ILSparkStyle defaultStyle].stroke = [ILColor clearColor];
    [[ILSparkStyle defaultStyle] addHints:@{
        ILSparkGaugeRingWidthHint: @36,
        ILSparkGaugeDialWidthHint: @8,
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
}

#pragma mark - ILSparkGaugeDataSource

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
