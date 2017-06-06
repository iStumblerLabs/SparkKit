#import "SparkyDelegate.h"

#ifdef IL_APP_KIT
@interface SparkyDelegate ()

@end
#endif

@implementation SparkyDelegate

- (void) update
{
    [self.sparkLine updateView];

    [self.sparkText updateView];
    [self.sparkVert updateView];
    [self.sparkHorz updateView];
    [self.sparkSquare updateView];

    [self.sparkCircle updateView];
    [self.sparkRing updateView];
    [self.sparkPie updateView];
    [self.sparkDial updateView];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ILSparkStyle* defaultStyle = [ILSparkStyle defaultStyle];
    defaultStyle.falloff = 50;
    defaultStyle.bordered = YES;
    defaultStyle.filled = YES;
    
    self.sparkText.indicatorStyle = ILIndicatorStyleText;
    self.sparkText.dataSource = self;
    
    self.sparkVert.indicatorStyle = ILIndicatorStyleVertical;
    self.sparkVert.dataSource = self;
    
    self.sparkHorz.indicatorStyle = ILIndicatorStyleHorizontal;
    self.sparkHorz.dataSource = self;
    
    self.sparkSquare.indicatorStyle = ILIndicatorStyleSquare;
    self.sparkSquare.dataSource = self;
    
    self.sparkCircle.indicatorStyle = ILIndicatorStyleCircle;
    self.sparkCircle.dataSource = self;
    
    self.sparkRing.indicatorStyle = ILIndicatorStyleRing;
    self.sparkRing.dataSource = self;
    
    self.sparkPie.indicatorStyle = ILIndicatorStylePie;
    self.sparkPie.dataSource = self;
    
    self.sparkDial.indicatorStyle = ILIndicatorStyleDial;
    self.sparkDial.dataSource = self;

    self.sparkLine.dataSource = self;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self.updateTimer fire];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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
    for (NSInteger index = 0; index < 500; index = index+10) {
        if (index < 100 || index > 200) { // 100 second gap
            [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:-(index)]];
        }
    }
    return [NSArray arrayWithArray:dateArray];
}

- (CGFloat) sampleValueAtIndex:(NSUInteger) index {
    NSTimeInterval interval = [self.sampleDates[index] timeIntervalSinceReferenceDate];
    CGFloat sine = (sin(interval/25)/2)+0.5;
    // NSLog(@"sampleValueAtIndex: %lu interval: %f -> %f", (unsigned long)index, interval, sine);
    return sine;
}

@end

#pragma mark -

int main(int argc, const char * argv[]) {
#ifdef IL_APP_KIT
    return NSApplicationMain(argc, argv);
#elif IL_UI_KIT
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SparkyDelegate class]));
    }
#endif
}
