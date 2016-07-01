#import "SparkyDelegate.h"

#ifdef IL_APP_KIT
@interface SparkyDelegate ()

@end
#endif

@implementation SparkyDelegate

- (void) update
{
    [self.sparkpie updateView];
    [self.sparkline updateView];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.sparkpie.dataSource = self;
    
    self.sparkline.dataSource = self;
    self.sparkline.style.falloff = 50;
    self.sparkline.style.filled = YES;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self.updateTimer fire];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - ILSParkViewDataSource

- (CGFloat) data
{
    return 0.33;
}

#pragma mark - ILSparkLineDataSource

-(NSArray<NSDate*>*) sampleDates {
    static NSArray<NSDate*>* dates = nil;
    if (!dates) {
        NSMutableArray* dateArray = [NSMutableArray new];
        for (NSInteger index = 0; index < 500; index = index+10) {
            if (index < 100 || index > 200) { // 100 second gap
                [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:-(index)]];
            }
        }
        dates = [NSArray arrayWithArray:dateArray];
    }
    return dates;
}

- (CGFloat) sampleValueAtIndex:(NSUInteger) index {
    NSTimeInterval interval = [self.sampleDates[index] timeIntervalSinceNow];
    CGFloat sine = (sin(interval/25)/2)+0.5;
    // NSLog(@"sampleValueAtIndex: %lu interval: %f -> %f", (unsigned long)index, interval, sine);
    return sine;
}

@end

#pragma mark -

#ifdef IL_APP_KIT
int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}
#endif

#ifdef IL_UI_KIT
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SparkyDelegate class]));
    }
}
#endif
