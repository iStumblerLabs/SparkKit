@import KitBridge;
@import SparkKit;

#ifdef IL_UI_KIT
@interface SparkyController : UIViewController <ILSparkGaugeDataSource, ILSparkLineDataSource, ILViews>
#else
@interface SparkyController : NSViewController <ILSparkGaugeDataSource, ILSparkLineDataSource, ILViews>
#endif

#pragma mark - Properties
@property(nonatomic, retain) ILGridData* gridData;
@property(nonatomic, retain) ILStreamData* streamData;
@property(nonatomic, retain) ILBucketData* bucketData;

#pragma mark - IBOutlets
@property(nonatomic, retain) IBOutlet ILSparkLine* sparkLine;
@property(nonatomic, retain) IBOutlet ILSparkGrid* sparkGrid;

@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkText;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkVert;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkHorz;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkSquare;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkCircle;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkRing;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkPie;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkDial;

@end
