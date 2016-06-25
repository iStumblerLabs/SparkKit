@import Cocoa;
@import SparkKit;

@interface SparkyDelegate : NSObject <NSApplicationDelegate, ILSparkLineDataSource>
@property(nonatomic, assign) NSTimer* updateTimer;
@property(nonatomic, assign) IBOutlet ILSparkLine* sparkline;

@end

