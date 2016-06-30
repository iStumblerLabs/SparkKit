@import SparkKit;

@interface SparkyDelegate : NSObject <ILApplicationDelegate, ILSparkLineDataSource>
@property(nonatomic, assign) NSTimer* updateTimer;
@property(nonatomic, assign) IBOutlet ILSparkLine* sparkline;

@end

