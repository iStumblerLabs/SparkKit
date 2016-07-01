@import SparkKit;

@interface SparkyDelegate : NSObject <ILApplicationDelegate, ILSparkLineDataSource>
@property(nonatomic, retain) NSTimer* updateTimer;
@property(nonatomic, assign) IBOutlet ILSparkLine* sparkline;
@property(nonatomic, strong) IBOutlet ILWindow *window;

@end

