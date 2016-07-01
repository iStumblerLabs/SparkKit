@import SparkKit;

@interface SparkyDelegate : NSObject <ILApplicationDelegate, ILSparkViewDataSource, ILSparkLineDataSource>
@property(nonatomic, retain) NSTimer* updateTimer;
@property(nonatomic, assign) IBOutlet ILSparkLine* sparkline;
@property(nonatomic, assign) IBOutlet ILSparkPie* sparkpie;
@property(nonatomic, strong) IBOutlet ILWindow *window;

@end

