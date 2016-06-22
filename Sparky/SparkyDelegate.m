#import "SparkyDelegate.h"

@interface SparkyDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation SparkyDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.sparkline.dataSource = self;
    [self.sparkline updateView];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - ILSparkLineDataSource

-(NSArray<NSDate*>*) sampleDates {
    static NSArray<NSDate*>* dates = nil;
    if (!dates) {
        NSMutableArray* dateArray = [NSMutableArray new];
        for (NSInteger index = 0; index < 1024; index++) {
            [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:-(index)]];
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
