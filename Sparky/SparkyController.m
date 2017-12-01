#import "SparkyController.h"


@interface SparkyController ()
@property(nonatomic, retain) NSTimer* dataTimer;

@end

@implementation SparkyController

#pragma mark - ILViews

- (void) initView
{
    [self loadView];
    
    self.sparkText.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterTextStyle)}];
    self.sparkVert.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterVerticalStyle)}];
    self.sparkHorz.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterHorizontalStyle)}];
    self.sparkSquare.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterSquareStyle)}];
    self.sparkCircle.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterCircleStyle)}];
    self.sparkRing.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterRingStyle)}];
    self.sparkPie.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterPieStyle)}];
    self.sparkDial.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterDialStyle)}];

    self.stackText.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterTextStyle)}];
    self.stackVert.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterVerticalStyle)}];
    self.stackHorz.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterHorizontalStyle)}];
    self.stackSquare.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterSquareStyle)}];
    self.stackCircle.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterCircleStyle)}];
    self.stackRing.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterRingStyle)}];
    self.stackPie.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterPieStyle)}];
    self.stackDial.style = [[ILSparkStyle defaultStyle] copyWithHints:@{ILSparkMeterStyleHint: @(ILSparkMeterDialStyle)}];

    self.sparkLine.dataSource = self;
    
    self.sparkText.dataSource = self;
    self.sparkVert.dataSource = self;
    self.sparkHorz.dataSource = self;
    self.sparkSquare.dataSource = self;
    self.sparkCircle.dataSource = self;
    self.sparkRing.dataSource = self;
    self.sparkPie.dataSource = self;
    self.sparkDial.dataSource = self;

    self.stackText.stackDataSource = self;
    self.stackVert.stackDataSource = self;
    self.stackHorz.stackDataSource = self;
    self.stackSquare.stackDataSource = self;
    self.stackCircle.stackDataSource = self;
    self.stackRing.stackDataSource = self;
    self.stackPie.stackDataSource = self;
    self.stackDial.stackDataSource = self;

    self.gridData = [ILGridData floatGridWithRows:0 columns:100];
    self.sparkGrid.grid = self.gridData;
    self.sparkGrid.xAxisLabels = @[@"1", @"2", @"3", @"4", @"5"];
    self.sparkGrid.yAxisLabels = @[@"a", @"b", @"c", @"d", @"e"];
    
    self.bucketData = [ILBucketData new];
    self.sparkBars.dataSource = self.bucketData;
    
    self.dataTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(dataTimer:) userInfo:nil repeats:YES];
    [self.dataTimer fire];
    
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
    [self.sparkBars updateView];

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

    // stacks
    [self.stackText updateView];
    [self.stackVert updateView];
    [self.stackHorz updateView];
    [self.stackSquare updateView];
    [self.stackCircle updateView];
    [self.stackRing updateView];
    [self.stackPie updateView];
    [self.stackDial updateView];
}

#pragma mark - NSTimer

- (void) dataTimer:(NSTimer*) timer;
{
    /* append some grid data */
    NSMutableData* blankRow = [NSMutableData dataWithLength:self.gridData.sizeOfRow]; // start small
    NSMutableArray* dataArray = [NSMutableArray array];
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    
    int index = 0;
    while (index < self.gridData.columns) {
        CGFloat percent = ((index + 1) / (CGFloat)self.gridData.columns);
        // CGFloat integral = 0;
        CGFloat sine = (sin(interval * percent) / 2) + 0.5;
        // NSLog( @"interval %f percent %f sine %f", interval, percent, sine);
        [dataArray addObject:@(sine)];
        void* valueAddress = (blankRow.mutableBytes + (index * sizeof(CGFloat)));
        memcpy(valueAddress, &sine, sizeof(CGFloat));
        index++;
    }
    self.bucketData.buckets = dataArray;
    [self.gridData appendData:blankRow];
    [self.sparkGrid updateView];
}

#pragma mark - ILSparkMeterDataSource

- (CGFloat) datum
{
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    CGFloat sine = (sin(interval) / 2) + 0.5;
    // NSLog(@"sampleValueAtIndex: %lu interval: %f -> %f", (unsigned long)index, interval, sine);
    return sine;
}

#pragma mark - ILSparkStackDataSource

- (NSArray<NSNumber*>*) data
{
    static NSArray<NSNumber*>* squares = nil;
    if (!squares) {
        squares = @[@(1), @(4), @(9), @(16)];
    }
    return squares;
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
