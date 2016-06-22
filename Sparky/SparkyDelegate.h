@import Cocoa;
@import SparkKit;

@interface SparkyDelegate : NSObject <NSApplicationDelegate, ILSparkLineDataSource>
@property(nonatomic, assign) IBOutlet ILSparkLine* sparkline;

@end

