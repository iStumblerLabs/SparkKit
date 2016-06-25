#import "SparkyDelegate.h"

@interface SparkyDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation SparkyDelegate

- (void) update
{
    [self.sparkline updateView];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.sparkline.dataSource = self;
    self.sparkline.style.falloff = 50;
    self.sparkline.style.filled = YES;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self.updateTimer fire];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}
