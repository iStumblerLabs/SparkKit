#import "SparkyViewController.h"

@interface SparkyViewController ()

@end

@implementation SparkyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sparkline = [[ILSparkLine alloc] initWithFrame:self.view.frame];
    self.sparkline.dataSource = self;
    [self.view addSubview:self.sparkline];
    [self.sparkline updateView];
    // Do any additional setup after loading the view, typically from a nib.
}

#ifdef IL_UI_KIT
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#endif

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
