@import KitBridge;
@import SparkKit;

#ifdef IL_UI_KIT
@interface SparkyController : UIViewController <ILSparkMeterDataSource, ILSparkLineDataSource, ILViews>
#else
@interface SparkyController : NSViewController <ILSparkMeterDataSource, ILSparkLineDataSource, ILViews>
#endif

#pragma mark - Properties
@property(nonatomic, retain) ILGridData* gridData;
@property(nonatomic, retain) ILStreamData* streamData;
@property(nonatomic, retain) ILBucketData* bucketData;

#pragma mark - IBOutlets
@property(nonatomic, retain) IBOutlet ILSparkBars* sparkBars;
@property(nonatomic, retain) IBOutlet ILSparkLine* sparkLine;
@property(nonatomic, retain) IBOutlet ILSparkGrid* sparkGrid;

#pragma mark - Gauges
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkText;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkVert;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkHorz;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkSquare;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkCircle;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkRing;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkPie;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkDial;

@end
