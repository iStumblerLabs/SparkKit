@import SparkKit;

@interface SparkyDelegate : NSObject <ILApplicationDelegate, ILSparkIndicatorDataSource, ILSparkLineDataSource>
@property(nonatomic, retain) NSTimer* updateTimer;
@property(nonatomic, assign) IBOutlet ILSparkLine* sparkLine;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkText;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkVert;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkHorz;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkSquare;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkCircle;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkRing;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkPie;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkDial;
@property(nonatomic, strong) IBOutlet ILWindow *window;

@end

