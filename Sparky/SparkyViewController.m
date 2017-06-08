#import "SparkyViewController.h"

@interface SparkyViewController ()

@end

@implementation SparkyViewController

#pragma mark - ILViews

- (void) initView
{
    [self loadView];
    
    self.sparkText.indicatorStyle = ILIndicatorStyleText;
    self.sparkVert.indicatorStyle = ILIndicatorStyleVertical;
    self.sparkHorz.indicatorStyle = ILIndicatorStyleHorizontal;
    self.sparkSquare.indicatorStyle = ILIndicatorStyleSquare;
    self.sparkCircle.indicatorStyle = ILIndicatorStyleCircle;
    self.sparkRing.indicatorStyle = ILIndicatorStyleRing;
    self.sparkPie.indicatorStyle = ILIndicatorStylePie;
    self.sparkDial.indicatorStyle = ILIndicatorStyleDial;
    
    self.sparkLine.dataSource = self;
    self.sparkText.dataSource = self;
    self.sparkVert.dataSource = self;
    self.sparkHorz.dataSource = self;
    self.sparkSquare.dataSource = self;
    self.sparkCircle.dataSource = self;
    self.sparkRing.dataSource = self;
    self.sparkPie.dataSource = self;
    self.sparkDial.dataSource = self;
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
}

#pragma mark - ILSparkIndicatorDataSource

- (CGFloat) datum
{
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    CGFloat sine = (sin(interval/25)/2)+0.5;
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
