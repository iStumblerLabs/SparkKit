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
    
    self.gridData = [ILGridData floatGridWithRows:10 columns:0];
    self.sparkGrid.grid = self.gridData;
    self.sparkGrid.xAxisLabels = @[@"1", @"", @"3", @"", @"5", @"", @"7", @"", @"9", @""];
    self.sparkGrid.yAxisLabels = @[@"a", @"b", @"c", @"d", @"e"];
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
    
    for (int index = 0; index < 5; index++) {
        
    }
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
